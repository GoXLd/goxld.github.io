---
title: 'Hermes behind a tunnel: a signed webhook rather than a bot talking to a bot'
description: "How I exposed a Hermes webhook through a Cloudflare Tunnel, kept the HMAC signature at the boundary and verified the delivery of 10 events without opening up my personal machine."
date: 2026-07-13
categories: [DevOps]
tags: [hermes, cloudflare, tunnel, webhook, hmac, automatisation]
author: GoXLd
pin: false
toc: true
published: true
ads: true
mermaid: false
language: en
translation_key: hermes-webhook-cloudflare-tunnel
permalink: /posts/en/hermes-webhook-cloudflare-tunnel/
---

# Hermes behind a tunnel: don't confuse exposure with delivery

I wanted to deliver purchases, already structured by a remote Worker, to Hermes. The first idea sounds trivial: expose an HTTP URL, do a `POST`, then wait for the confirmation message. In practice, the agent runs on a machine that must not become a public server, and the sender and the receiver can each go down separately.

The trap was also in the channel: a Telegram bot cannot be a reliable transport to another bot. So I separated the roles: the Worker produces the event, a signed webhook hands it to Hermes, and Telegram remains a channel meant for humans.

> In one sentence: a Cloudflare Tunnel makes Hermes reachable without opening up the personal machine; the HMAC signature decides whether a request may enter, and the durable state on the Worker side decides whether it must be replayed.
{: .prompt-info }

## The starting point

| Area | Initial state |
|---|---|
| Hermes agent | Service reachable locally, not a public API to expose directly |
| Event producer | Cloudflare Worker able to make HTTP calls |
| Transport initially imagined | Telegram notification between two bots |
| Main risk | A lost or forged request had to be distinguishable from a success |
| Available validation | Test route answering `202 Accepted` when the webhook is healthy |

A named tunnel runs on the host that executes Hermes — not on my Mac. It relays only the webhook route to the local service. That distinction matters: I neither opened an inbound port on my personal machine, nor made the entire Hermes interface available on the Internet.

## A minimal boundary: tunnel, route, signature

The flow doesn't need to be complicated to be verifiable: the producer prepares the body, computes a signature with a shared secret, then calls the tunnel's public URL. Hermes verifies the signature before processing the event.

```text
Cloudflare Worker
  → POST signed with HMAC
  → Cloudflare Tunnel
  → /webhooks/… route on the Hermes host
  → signature verification
  → event processing
  → 202 Accepted
```

>The rules adopted at the boundary:
>1. **A secret is never placed in the URL** — the body and the signature travel separately.
>2. **The tunnel publishes only one useful route** — it is not a shortcut for exposing the agent's local interface.
>3. **A `202` is not proof of persistence on the producer side** — the producer keeps its own recovery state.
{: .prompt-danger }

The webhook test uses the same route as the Worker and did return `202 Accepted`. It is an availability check: the tunnel reaches the service and the route accepts an authenticated request. It is deliberately not a full business-content test.

## Why the tunnel does not replace a queue

The tunnel answers a single question: *how do I reach a local service without exposing it directly?* It does not answer the next one: *what happens if Hermes is momentarily unavailable after an event has been collected?*

The answer stays on the Worker side: the event is recorded before the delivery attempt, and its status is only updated after a successful response. In the current pipeline, the **10 tickets** of the first page were delivered to Hermes; that figure confirms the first pass, not a magic guarantee for every future incident.

| Situation | What the tunnel solves | What the producer must solve |
|---|---|---|
| Hermes reachable locally | HTTPS URL without an open port on the personal machine | Nothing more |
| Request without a valid signature | Nothing: it reaches the boundary | Hermes rejects it |
| Tunnel or service unavailable | Nothing: the call fails | Keep the event and retry |
| `202 Accepted` response | The route accepted the handoff | Mark the event delivered only per the defined contract |

This separation prevents a common confusion: a reachable endpoint is not a queue. The tunnel carries an attempt; persistence and delivery status are what make the attempt replayable.

## The honest part: one more network surface

The tunnel avoids opening an inbound port, but it still creates a public URL. A configuration mistake can therefore widen the exposed surface well beyond the intended webhook. I kept the dedicated route and the HMAC signature precisely so that "knowing the URL" is not enough to inject an event.

Another limitation: the `202` test demonstrates neither the quality of the parsing on the Worker side, nor the final effect produced by Hermes. It verifies the plumbing. Data tests and the recovery mechanism remain distinct responsibilities; conflating them would have given a false impression of reliability.

## Summary

| Element | Result |
|---|---|
| Network exposure | Cloudflare Tunnel to a dedicated webhook route |
| Entry protection | HMAC signature, no secret in the URL |
| Health check | `202 Accepted` |
| Tunnel host | The Hermes machine, not the personal machine |
| First observed delivery | **10 tickets** from the first page |
| Recovery guarantee | Persistence and status on the Worker side, not the tunnel |

The result is not "Hermes open to the Internet". It is a narrow boundary between a remote producer and a local agent: accessible enough to receive an event, controlled enough to reject a request that doesn't carry the right signature.

The useful question is no longer "how do I reach my agent from a Worker?", but "which part of the system proves that an event was accepted, processed and, if needed, replayed?". The tunnel cleanly answers the first part; the rest must remain explicit in the delivery contract.
