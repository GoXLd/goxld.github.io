---
title: ASN — the scraping highway
description: Lessons learned from building a robust scraper without blowing up the proxy budget.
date: 2026-02-04
tags: [scraping, proxy, asn, reseau, automatisation]
author: GoXLd
pin: false
toc: false
published: true
image:
  path: img/asn/asn.jpg
  lqip: data:image/jpeg;base64,/9j/4QDKRXhpZgAATU0AKgAAAAgABgESAAMAAAABAAEAAAEaAAUAAAABAAAAVgEbAAUAAAABAAAAXgEoAAMAAAABAAIAAAITAAMAAAABAAEAAIdpAAQAAAABAAAAZgAAAAAAAABIAAAAAQAAAEgAAAABAAeQAAAHAAAABDAyMjGRAQAHAAAABAECAwCgAAAHAAAABDAxMDCgAQADAAAAAQABAACgAgAEAAAAAQAAABOgAwAEAAAAAQAAAAqkBgADAAAAAQAAAAAAAAAAAAD/2wCEAAEBAQEBAQIBAQIDAgICAwQDAwMDBAUEBAQEBAUGBQUFBQUFBgYGBgYGBgYHBwcHBwcICAgICAkJCQkJCQkJCQkBAQEBAgICBAICBAkGBQYJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCf/dAAQAAv/AABEIAAoAEwMBIgACEQEDEQH/xAGiAAABBQEBAQEBAQAAAAAAAAAAAQIDBAUGBwgJCgsQAAIBAwMCBAMFBQQEAAABfQECAwAEEQUSITFBBhNRYQcicRQygZGhCCNCscEVUtHwJDNicoIJChYXGBkaJSYnKCkqNDU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6g4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2drh4uPk5ebn6Onq8fLz9PX29/j5+gEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoLEQACAQIEBAMEBwUEBAABAncAAQIDEQQFITEGEkFRB2FxEyIygQgUQpGhscEJIzNS8BVictEKFiQ04SXxFxgZGiYnKCkqNTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqCg4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2dri4+Tl5ufo6ery8/T19vf4+fr/2gAMAwEAAhEDEQA/AP0W+FExXW9G8J+N7u10mKPTriS9uJZhE0bxwL5TGVz8mZZUDKBt4AIHUY/7Zlv8JPAHwCvvihqi3f8AaFpc2Bitllsbq8Ed2Yo03wybYSquWeceeVCEMhZdor5q8SgW3izWdKth5drvmTyV4j2+VaDbtHGMMwxjufWuW8eeD/CUfi34YXsel2izano0Ed44gjDXCG2dysp25cF/mw2RnnrX5dgvZRs5R/q1z+gpU6nt41VNpK2npqfC5+D2q6skeq6LqdubS5jjliyTFhXUMBslO/5c4yc5xkEgg03/AIUd4o/6CNt/3+T/ABrxDxcq6h4p1C6vwJ5TcSKXk+ZsKdqjJ7AAAegGK537BY/88Y/++R/hX6BSjLlWv4HymNT9tL1Z/9k=
ads: true
language: en
translation_key: asn-autoroute-scraping
permalink: /posts/en/asn-autoroute-scraping/
---
# ASN — the scraping highway

## How I cut my proxy costs and stopped fighting 429s

> <b>Disclaimer:</b> this article documents technical research and market analysis.
> Some screenshots may contain historically sensitive data, but it is no longer exploitable in production.
> The choice not to blur is deliberate, to share a real, verifiable method.
> Critical feedback is welcome.
{: .prompt-info }

In computing, many problems become simpler once you find a good real-world analogy. For me, that analogy was: the highway = the ASN.

![Webshare](img/asn/forfait_webshare.png){: .shadow }
*Visible result on the proxy bill after optimization.*

> The figure is deliberately striking, but the important thing is the method.
> Yes, going straight to premium residential proxies (or another service, e.g. Bright Data) can often raise the success rate faster[^residential].
> But that comfort has a high cost and masks the real cause of the errors.
> Here, I mostly share a synthesis of three months of adjustments across several worldwide pools to keep performance without depending solely on budget.
> In practice, many "scraper-as-a-service" solutions remain expensive and unreliable on specific targets (e.g. Leboncoin or Steam Market), hence the value of building a chain adapted to your own use case.
{: .prompt-tip }

The decisive argument was the **detection of "decoy" responses**.
You bypass Cloudflare, the server answers `200`, you receive HTML... but it is just an empty page or fake content.
For a *pay as you go* service, the request is billed as "successful", while the business result is nil.
It is the equivalent of a delivered envelope with no letter inside.

![Example of an empty response despite a 200 status](img/asn/small_reponse.png){: .shadow }

> Delivering a response does not mean delivering the useful data.
{: .prompt-warning }

In this article, I explain how and why it worked.
---

## Quick summary

- [How it all started](#comment-tout-a-commence)
- [My defense baseline](#ma-base-de-defense)
- [A strange observation](#observation-etrange)
- [The ASN hypothesis](#hypothese-asn)
- [How I verified it](#comment-je-l-ai-verifie)
- [The "Traffic light" system](#le-systeme-feu-tricolore)
- [The ASN's role in the "Traffic light"](#role-de-l-asn-dans-le-feu-tricolore)
- [Result](#resultat)
- [Why the road analogy works](#pourquoi-l-analogie-routiere-fonctionne)
- [Conclusion - ASNRank.com](#conclusion-asnrank-com)
- [What you can do right now](#ce-que-vous-pouvez-faire-des-maintenant)

---

## How it all started {#comment-tout-a-commence}

For the business context behind my tests, I also published a dedicated article:
[Why Steam Market is a great learning playground]({% post_url en/2026-01-14-pourquoi-steam-market %}).

I worked almost continuously (a three-month marathon, no days off) on my own scraper. I wasn't starting completely from scratch: I already had Google Apps Script (`.gs`) scripts in production.
`gXd.node/scripts`
{: .filepath}
![Terminal Logs - local.node - scripts](img/asn/parsing_terminal.webp){: .shadow }
But over time, the success rate of `urlFetch` could fall to around 15% on some targets, which became critical.
Even with a high theoretical daily limit (often quoted around 20k requests/day[^urlfetch]), the real usage limits remain more complex.
In practice, in my scenario, I observed a stability zone around **10k requests/day** with `urlFetch`, but that threshold remains dynamic:
when raising the frequency, I have already seen errors appear before that volume.

![Example of Apps Script limitation](img/asn/appscript_limits.webp){: .shadow }

So I progressively made the architecture more sophisticated.

Before, everything was simple:

- add jitter,
- limit the frequency,
- enable IP rotation,
- change country (in rare cases)

But in recent years (notably with the rise of AI), the backends of large services have grown much more complex. The simple methods stopped working.

**429** errors started appearing even with a cautious load, including when applying old workaround methods.

> Yet I never exceeded 1 request/second and I wasn't using aggressive multi-threading.
> On average, each script stayed around 1 request/minute toward the target service.
> The rest of the traffic went over priority channels (internal APIs, database, system services), i.e. outside the classic scraping flow.
{: .prompt-danger }

---

## My defense baseline (hardened anti-blocking version) {#ma-base-de-defense}

At the time of the tests, I already had a fairly elaborate system:

- no more than one request per second across 100+ proxies,
- dynamic timing + 15% jitter
```js
function withJitter(baseDelayMs = 1000, jitterPercent = 0.15) {
  const delta = baseDelayMs * jitterPercent;
  return Math.round(baseDelayMs + (Math.random() * 2 - 1) * delta);
}
```
{: file="scripts/jitter.js"}

- automatic address switching
```js
class ProxyRotator {
  constructor(proxies) {
    this.proxies = proxies;
    this.index = 0;
  }

  next() {
    const proxy = this.proxies[this.index % this.proxies.length];
    this.index += 1;
    return proxy;
  }
}
```
{: file="scripts/proxy-rotator.js"}

- fallback chain: Google → Proxy → Node
The logic is deliberately progressive:
first try the Google addresses (best latency/cost),
then move to the rotating proxies,
and finally to dedicated IPv4 instances (a private pool used only by me) when the target becomes too restrictive.

![Success rate per chain AppScript -> Proxy -> Node](img/asn/success_rate_appscript_proxy_node.webp){: .shadow }
- my own servers in several datacenters with "clean" IPv4s

The nodes are currently spread across France, Germany, the Netherlands and the United States.
Expansion to Singapore, Switzerland and new US locations is planned, but it is not a priority for now.

![Current node distribution](img/asn/nodes.png){: .right .shadow }

The current availability rate holds globally between **98% and 99%**, which allows prioritizing software optimization before geographic expansion.
![Node availability](img/asn/nodes_success_rate.png){:.left .shadow }

Logs on the gXd.node server
`gXd.node/logs/scraper-traffic.log`
{: .filepath}
![Webshare](img/asn/logs.webp){: .shadow }
- a "Traffic light" rotation system,
- emulation of different devices and browsers.

Simplified excerpts of the logic (pedagogical version):


```js
async function fetchWithFallback(request) {
  try {
    return await fetchViaGoogle(request);
  } catch {
    try {
      return await fetchViaProxy(request);
    } catch {
      return await fetchViaNode(request);
    }
  }
}
```
{: file="scripts/fetch-with-fallback.js"}

On paper, everything was correct.
But the results still varied heavily by country and by pool.

---

## A strange observation {#observation-etrange}

Over time, I noticed an interesting regularity.
In the same country, different proxies showed:

- 90% success rate,
- 70%,
- sometimes less than 50%.

The screenshot below confirms the idea: for the same country, the success rate varies strongly by ASN and by the associated address blocks.

![Success differences by ASN](img/asn/be_replaced_ips.webp){: .shadow }

You will also notice the "weak" ASN has fewer requests.
That is not a measurement bias: it is the direct effect of the optimization.

As soon as a proxy shows drift (429, timeout, unstable latency), it is replaced quickly. The goal is not to accumulate 1000 failures on a dead proxy, but to cut the loss as early as possible.

The replacement threshold remains deliberately individual: it depends on the pool's cost, the error tolerance and the collection pace.

<b>And yet:</b>
- the load was identical,
- the behavior identical,
- the timing identical.

The difference boiled down to a single parameter: **the ASN**.

> The servers stay online, but the quality of passage can degrade brutally.
> The goal is therefore to pick the least saturated "ASN highways" to keep traffic stable and profitable.
{: .prompt-tip }

![Pick the least saturated ASN highways](img/asn/traffic_scrapper.png){: .shadow }

---

## Hypothesis: the limits are not per IP, but per ASN {#hypothese-asn}

<b>One hypothesis imposed itself:</b>

<i>Modern services increasingly rate-limit not isolated IPs, but address blocks of **entire autonomous systems (ASN)**.</i>

The logic is simple:
If an ASN block contains a lot of suspicious activity, it is simpler to slow down the whole block than to filter address by address.

Consequences:
- even "clean" IPs start receiving 429s,
- the success rate drops,
- costs increase.

If, in the same ASN block (/24 /23 /22 etc.), someone else is scraping aggressively, you suffer the effects.

---

## How I verified it {#comment-je-l-ai-verifie}
I started collecting statistics per ASN:

- success rate,
- number of 429s,
- degradation time,
- recovery.

After a few weeks, a clear trend appeared:

- as soon as an ASN "drops",
- all the IPs within it fall,
- changing address doesn't help (changing ASN — yes).

It is not formal proof, but the correlation was too stable to be a coincidence.

<b>An important point:</b> some performance drops come from global incidents outside local control.
During large-scale Cloudflare disruptions, several pools can drop in parallel, even with good scraping hygiene.

![Impact of a global incident on proxy statistics](img/asn/proxy_stats.png)

> At Internet scale, the incidents of large operators quickly become shared problems.
{: .prompt-warning }

---

## The "Traffic light" system {#le-systeme-feu-tricolore}

To automate proxy quality, I set up a "Traffic light" system.
The principle is simple, as in logistics.

| State | Condition | Action |
| ---- | --------- | ------ |
| **Green** | Stable address, success above the threshold | Active use in the rotation |
| **Yellow** | Streak of 10 consecutive errors | Paused for a few hours |
| **Red** | New drift after the rest phase | Excluded from the pool |

!["Traffic light" workflow for controlling ASN highways](img/asn/feu_tricolor.png){: .shadow }

This workflow illustrates the continuous checking of the "road" (the ASN) and not just an isolated IP.

---

## The ASN's role in the "Traffic light" {#role-de-l-asn-dans-le-feu-tricolore}

Over time, I added an aggregation level:

Address → ASN → Pool.

If several IPs of the same ASN start generating errors, the priority of the whole range drops.

In practice, the system learns to avoid the problematic highways.

In parallel, a server job checks the new network masks several times a day and compares them to the internal history.
This building block is not provided natively by Webshare: it is a homemade layer that improves proactive pool selection.

![Automatic network mask updates](img/asn/update_masks.png){: .shadow }

> Without an exploitable endpoint, even a very good AI assistant cannot guess the real flow.
> You first have to understand how the page generates its dynamic hypertext to automate cleanly.
{: .prompt-info }

---

## Why it is useful

Imagine:

- a proxy has a 99% success rate,
- then it degrades,
- because of the rotation, the system only notices several days later.

During that time, thousands of requests go into the void, at real cost.

The "Traffic light" filters out bad addresses within hours, not weeks.

---

## Result {#resultat}

After integrating the ASN analysis and the "Traffic light":

- the 429s dropped severalfold,
- the success rate increased,
- the proxies are used more efficiently,
- part of the pools was entirely replaced.

Financial result:

| Period | Spend |
| ------ | -------- |
| Before  | $68     |
| After  | $5.50   |

For the same load.

---

## Why the road analogy works {#pourquoi-l-analogie-routiere-fonctionne}

An ASN is a highway.

- IPs are the cars.
- Proxies are the drivers.
- Traffic is the cargo.

You can change cars, but if the road is saturated, you stay stuck.
I stopped fighting with individual cars and started choosing roads.

---

## Conclusion - ASNRank.com {#conclusion-asnrank-com}

After this work, I launched **ASNRank.com** to industrialize this network-scoring logic.
The service centralizes ASN ranking, drift tracking and route prioritization based on real quality.

![Overview of the ASNRank platform](img/asn/asnrank.webp){: .shadow }

A dedicated article is in preparation:
- *ASNRank.com — article draft in progress (publication coming).*

The central point is simple:
In 2025, fighting blocks only at the IP level no longer makes sense.

You have to work:

- with ASNs,
- with network reputation,
- with dynamic degradation,
- with automatic quality control.

Otherwise, you simply burn your budget.

---

## What you can do right now {#ce-que-vous-pouvez-faire-des-maintenant}

If you do scraping:

1. Start logging ASNs.
2. Compare success rates by ranges.
3. Disable problematic networks in blocks.
4. Automate the selection.
5. Don't trust "cheap" pools without statistics.

It pays for itself very quickly.

<b>Thank you for your attention!</b>

---
[^residential]: Premium residential proxies often improve deliverability, but their monthly cost can quickly exceed that of a technical ASN optimization.
[^urlfetch]: The "20k/day" limit is a frequent reference depending on configurations, but the useful limit also depends on the script type, the target and the quotas actually applied.
