---
title: A maintainer's review guide, turned into a method
description: Detailed reviews from OVHcloud maintainer Y0Coss on my recent documentation PRs, reworked into a working guide for documentation maintenance and LTS management — choosing replacement versions, authentic sample output and evidence discipline.
date: 2026-08-25
categories: [DevOps]
tags: [devops, open-source, documentation, ovhcloud, lts, revue-code]
author: GoXLd
pin: false
toc: true
published: true
ads: true
mermaid: false
media_subpath: /img/y0coss-guidelines/
language: en
translation_key: lecons-revues-mainteneur-ovhcloud
permalink: /posts/en/lecons-des-revues-mainteneur-ovhcloud/
---

# When a maintainer becomes a mentor: lessons from the OVHcloud reviews

Hi everyone!

In my [previous post](/posts/en/sept-contributions-documentation-ovhcloud/), I told the story of my first seven accepted contributions to the OVHcloud documentation. Since then a second wave has landed: eight new merges (#620–#625, #627 and #643 — 62 files), three approved PRs waiting on an internal migration, and above all **a series of reviews so detailed they deserve better than the notification trash bin**.

The maintainer behind them, Y0Coss, justifies every request with verifiable facts: a decoded nginx ETag, PHP and Debian support windows, anchor naming conventions. Each review is a miniature lesson in documentation engineering — so I compiled them into a working guide, and this post is its public version.

> In one sentence: eight additional merges (62 files, every language), zero blunt rejections, and a maintenance guide that grew directly out of the reviews. A good review teaches more than the merge itself.
{: .prompt-info }

## Second wave: the table first

| Contribution | Scope | Upstream result |
|---|---:|---|
| [#620](https://github.com/ovh/ovhcloud-docs/pull/620) — restored `mdstat` marker | 7 files | direct merge |
| [#621](https://github.com/ovh/ovhcloud-docs/pull/621) — IPsec TOC anchors | 7 files | reworked per review, merge |
| [#622](https://github.com/ovh/ovhcloud-docs/pull/622) — "Go further" HA-NAS anchor | 7 files | direct merge |
| [#623](https://github.com/ovh/ovhcloud-docs/pull/623) — dead Kafka/OpenSearch reference | 2 files | direct merge |
| [#624](https://github.com/ovh/ovhcloud-docs/pull/624) — anchor typos | 14 files | direct merge |
| [#625](https://github.com/ovh/ovhcloud-docs/pull/625) — leftover French placeholders | 11 files | direct merge |
| [#627](https://github.com/ovh/ovhcloud-docs/pull/627) — EOL WordPress Docker images | 7 files | direct merge |
| [#643](https://github.com/ovh/ovhcloud-docs/pull/643) — EOL mariadb:10.6 image | 7 files | direct merge |
| **Total** | **62 files** | **8 accepted fixes** |

PRs #628 (PHP 8.4) and #629 (Python/Wagtail) are approved and awaiting migration; #640, #641 and #644 are under review. As the first time around, I verified each final commit: my original author identity (`goxld@ya.ru`) is preserved across the board.

## Rule #1: "fully supported", not just "newer"

My first version of #644 replaced `debian:9-slim` with `debian:12-slim`. The reasoning felt airtight: stretch is dead, bookworm is the current stable, done. The review raised the bar:

> Debian 12 became *oldstable* when trixie went stable, its standard security support ended in July. `13-slim` is a one-token change that buys three more years of security support.
>
> This is the same pattern as the PHP 8.3 discussion in #628: it's worth checking whether the replacement version is in **full** support rather than just newer than what it replaces.
{: .prompt-tip }

PHP 8.3 had left active support at the end of 2025; so #628 moved to 8.4. MySQL targeted the 8.4 LTS line rather than the 9.x innovation train. The generalized rule: an EOL replacement must buy years, otherwise you are merely relocating the debt.

A second reflex worth locking in: verify Docker tags by digest, not by name. `stable-slim` matched neither `bookworm-slim` nor `trixie-slim` — floating aliases drift between versions silently.

## Rule #2: never invent console output

This lesson stuck with me the most — not least because it arrived from two directions at once. On #641 I replaced `Server: nginx/1.7.9` with `nginx/1.27.3` inside a `curl -I` example, wanting the transcript to match the new tag. But I left the old `Last-Modified` and old `ETag` in place — and the review took that ETag apart:

```text
ETag = hex(mtime)-hex(size)
54999765 → 2014-12-23 16:25:09 UTC  = the stated Last-Modified
     108 → 264 bytes                 = the stated Content-Length
```

A perfectly self-consistent fingerprint of the 1.7.9 default index page and nothing else. A `Server: 1.27.3` header next to those values described an HTTP response that cannot exist. The same verdict reached #640's `SHOW DATABASES;` transcript from the MySQL 5.6 era: do not reconstruct it by hand — "a stale transcript beats an invented one".

The procedure is now clear:

>My rules for transcripts:
>1. **A sample output is data, not decoration** — it must remain an authentic, dated capture.
>2. **Never retouch by hand** to make it look fresher: internal consistency is verifiable.
>3. **Refreshing means actually running it** — on the real MKS cluster, not in your head.
>4. **Separate scopes**: the PR proves what it can prove (the tag bump) and explicitly declares what awaits a live run.
{: .prompt-danger }

I pushed a revert commit (`01d30e62a`) restoring the original `Server:` lines while keeping the image bumps — accepted without a single question.

## Rule #3: anchors have memory and grammar

On #621, my first instinct was to add `<a name="changepassworden">` anchors where TOC links pointed into the void. The review reversed that 180 degrees: those sections already carried `-fr` (France!) anchors, and adding mine would have orphaned them. Eleven other anchors in the same guide confirmed the suffix is **geographic**, not linguistic. The right fix: repoint the six other locales to the existing anchors — zero new definitions, convention respected.

The generalized rule: before adding anything, study what already exists near the target; count usages to read the convention; then converge every variant onto the form that is already correct.

## Rule #4: link, don't restate

In #629 my sentence "Wagtail requires Python 3.10 or later" repeated the official documentation word for word — and would go stale at Wagtail's next release. The review's conclusion: link the primary source instead of copying a version list destined to age. As a bonus, it turned out no localized URL exists: the Wagtail docs are English-only, and `/fr/stable/...` returned a 404.

## Review etiquette, from the reviewed side

What impressed me over these days is as much the form as the substance:

1. Every review **opens by validating** what is correct before any correction.
2. Requests are explicitly **graded**: "blocking" / "not blocking but worth taking while the PR is open" / "wording tweak".
3. Counter-arguments are carried by evidence (a decoded digest, an end-of-support date), never by authority.
4. When a direction is overruled, the clean reply fits in two lines: "reworked as suggested" + the commit SHA.

I published a public thank-you under #641 for that level of review quality — it is rare, and it deserves to be acknowledged where the work happened.

## Summary

| Metric | Result |
|---|---|
| New merges (2nd wave) | 8 PRs, 62 files, +104/−104 |
| Attribution | original commit preserved on all 8 |
| In the pipeline | #628/#629 approved, #640/#641/#644 under review |
| Produced | rules for versioning, transcripts, anchors, evidence |

The real gain from this cycle is neither the file count nor the merge count. It is the method that stays with you after the individual reviews are over: how to choose a replacement version, when NOT to touch a transcript, how to read a repository's convention before you start changing it. A contribution that survives a good review teaches twice: once while you fix it, and again when you work out why it needed fixing in the first place.
