---
title: 'From a Lidl receipt to Hermes: a Cloudflare Worker and a D1 queue'
description: "I turned HTML receipts into reliable context for Hermes: browserless OAuth, structured parsing, D1 and replayable delivery when the webhook is unavailable."
date: 2026-07-12
categories: [DevOps]
tags: [cloudflare, workers, hermes, d1, oauth, telegram]
author: GoXLd
pin: false
toc: true
published: true
ads: true
language: en
translation_key: ticket-lidl-hermes-cloudflare-worker
permalink: /posts/en/ticket-lidl-hermes-cloudflare-worker/
---

# From a checkout receipt to an agent: never lose the shopping list

I wanted my agent to be able to suggest a meal based on what I had actually bought, without photographing a receipt or retyping a list into Telegram. The source already exists: the digital receipts of my loyalty account. The problem is not displaying them once. It is fetching them without a fragile browser session, turning them into clean data, then guaranteeing that a temporary agent outage doesn't make a purchase disappear.

So I built a small service on Cloudflare Workers. It runs **twice a day**, reads at most the **10 most recent receipts**, stores the new ones in D1 and delivers their content to Hermes separately. The first commit is **13 files** and **744 added lines**: small enough to be reviewed in full, but with a real boundary between collection, persistence and notification.

> In one sentence: the receipt is written to D1 before any delivery; an unavailable webhook creates delay, not data loss.
{: .prompt-info }

## The starting point

| Area | State before |
|---|---|
| Shopping list for the agent | manual input or missing context |
| Digital receipt | HTML designed for display, not a stable business API |
| Authentication | no replaying logins and no driving a browser in production |
| Delivery to the agent | impossible to do directly from Telegram bot to Telegram bot |
| Webhook failure | must never lose a receipt |

The initial trap was Telegram. Two bots cannot message each other directly: the service that reads receipts therefore cannot "send a message to Hermes" the way it would to a human. Delivery to the agent goes through a signed HTTP webhook; Telegram remains reserved for alerts aimed at a person.

## The method: authenticate, store, then deliver

The loyalty program's website and mobile app rely on the same identity provider. The Worker keeps a `refresh_token` as a secret and exchanges it on every run for a short-lived `access_token`. That token allows calling the receipts API without storing a password, without CAPTCHA and without browser automation.

The whole flow fits in one simple idea: every step has its durable state.

```text
cron
  → refresh_token → access_token
  → list of recent receipts
  → HTML detail of each unknown receipt
  → item parsing
  → INSERT into D1 with notified_at = NULL
  → POST to the Hermes webhook
  → notified_at = delivery timestamp
```

The main table separates, among other things, the receipt identifier, its date, its total, the items JSON, the parser version and `notified_at`. That last column is the recovery contract: a recorded but undelivered receipt remains selectable on the next pass.

>The non-negotiable rules:
>1. **Persist before notifying** — the agent never becomes the only copy of the purchase.
>2. **Mark delivered only after success** — an error response leaves the receipt pending.
>3. **Stop delivery at the first error** — subsequent receipts also keep their order and their pending status.
{: .prompt-danger }

## Extracting data from HTML without trusting the HTML

A receipt's detail arrives as `htmlPrintedReceipt`. The visible text looks like a monospaced receipt: convenient for a human, a bad contract for a parser. Fortunately, each item line carries `data-*` attributes for the identifier, the unit price and the quantity.

```js
// The attributes give the numbers; the visible text gives the readable name.
const name = visible.split(/\s{2,}/u)[0].trim();
const unitPrice = parseDecimal(attr(tag, 'data-unit-price'));
const quantity = parseDecimal(attr(tag, 'data-art-quantity')) ?? 1;
const lineTotal = parseDecimal(decimals.at(-1));
```

The important detail is the name. The product description attribute sometimes contains badly encoded bytes; the parser therefore takes the label from the visible text, with its HTML entities decoded. It then reconciles the total against the receipt's "À payer" line.

| Element | Chosen source | Reason |
|---|---|---|
| Quantity | `data-art-quantity` attribute | structured value |
| Unit price | `data-unit-price` attribute | structured value |
| Product name | decoded visible text | avoids badly encoded characters |
| Total | "À payer" line | receipt consistency check |

The parsing test relies on a real anonymized receipt: it verifies it contains at least **30 items**, that each line has a name and a numeric total, that a multipack keeps its quantity, and that a label with an accent is correctly decoded. A second test enforces a `null` return for a page that is not a receipt.

## The part that matters: replayable delivery

In the Worker, collection and delivery are two distinct loops. The first inserts only unknown receipts. The second asks D1 for all rows whose `notified_at` is `NULL`, posts them one by one to the webhook, then marks them only when the call has succeeded.

```js
for (const row of pendingReceipts) {
  const ok = await notifyHermes(env, row);
  if (!ok) break; // the receipt stays pending for the next run
  await markNotified(env, row.id);
}
```

It is deliberately less sophisticated than a full queue, but the behavior is clear: missing webhook, timeout, or a momentarily unavailable agent — the next cron picks up where the previous one stopped. The service does not declare imaginary success and does not update `notified_at` out of optimism.

## The honest part: the dead ends

The first reflex would have been to use Telegram everywhere. It fails by design for bot-to-bot exchange. The webhook is less visible, but it is the right machine-to-machine channel; the notification bot remains useful for warning a human that an authentication has expired.

Second limitation: the parser still depends on the HTML structure and the attributes the provider exposes today. I isolated that risk inside `parseReceiptHtml()` and recorded a `parser_version` with each receipt. If the HTML changes, I can fix the parser and know which version produced each piece of data, rather than scattering a regular expression across the Worker.

Finally, a `refresh_token` is not eternal. If it is invalidated, the run alerts the administrator and requires replaying the OAuth flow. It is not a silent failure, but it is not magic autonomy either.

## Summary

| Metric | Result |
|---|---|
| Sync frequency | **twice a day** |
| Read window | **10 most recent** receipts |
| Delivery | signed HTTP webhook, replayable |
| Persistence | D1 before notification |
| Parsing tests | real anonymized receipt + non-conforming HTML |
| Recovery point | `notified_at = NULL` |

The result is not an "AI that reads my groceries". It is a modest pipeline that gives the agent context whose provenance I know: a receipt, structured items, a date and a delivery status.

The right question is no longer "how do I send a list to a bot?", but "what proof do we keep when an intermediate system goes down?". In this case, a `notified_at` column and the persistence → delivery order do more for reliability than any spectacular integration. Hermes can then reason about the latest purchase, while the Worker keeps the more down-to-earth responsibility of forgetting nothing.
