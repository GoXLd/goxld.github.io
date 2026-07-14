---
title: Linux 7.0 and PostgreSQL on ARM64 - dissecting a regression
description: Why pgbench drops by almost half on Linux 7.0-rc with ARM64, and what to check before going to production.
date: 2026-04-05
tags: [linux, postgresql, arm64, performance, kernel]
author: GoXLd
pin: false
toc: false
published: true
ads: true
image:
  path: img/linux-amazon/linux-postgressql.webp
  lqip: data:image/jpg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAA4KCw0LCQ4NDA0QDw4RFiQXFhQUFiwgIRokNC43NjMuMjI6QVNGOj1OPjIySGJJTlZYXV5dOEVmbWVabFNbXVn/2wBDAQ8QEBYTFioXFypZOzI7WVlZWVlZWVlZWVlZWVlZWVlZWVlZWVlZWVlZWVlZWVlZWVlZWVlZWVlZWVlZWVlZWVn/wAARCAAJABIDASIAAhEBAxEB/8QAGQAAAgMBAAAAAAAAAAAAAAAAAAUBAwQG/8QAIxAAAgICAQIHAAAAAAAAAAAAAQIAAwQFESFyFDEyMzRxsf/EABUBAQEAAAAAAAAAAAAAAAAAAAEE/8QAGxEAAgIDAQAAAAAAAAAAAAAAAAECEQMEITH/2gAMAwEAAhEDEQA/AOx2G+qwMo470u5ABJBHHWKNznXeMRqbbK0epXChuOORG+x+WfoSMn1V9i/kNiKeNVxkmRSlas2Ybs2HQzMSTWpJJ8+kJdT7KdohBeFCXD//2Q==
language: en
translation_key: linux-7-preempt-lazy-postgresql
permalink: /posts/en/linux-7-preempt-lazy-postgresql/
---

# Linux 7.0 and PostgreSQL on ARM64 - dissecting a regression

In the Linux 7.0 test branch, a significant regression was reported by Salvatore Dipietro (Amazon): on PostgreSQL (`pgbench simple-update`), ARM64 performance drops by almost half ([LKML](https://lore.kernel.org/lkml/20260403191942.21410-1-dipiets@amazon.it/)).

According to the published figures, the result falls from roughly **98,565** to **50,751** operations.
Since Linux 7.0 is in its final validation phase (`v7.0-rc6`), the topic directly concerns admins and dev teams ([kernel.org](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/?h=v7.0-rc6)).

![PostgreSQL performance comparison on Linux 7.0](img/linux-amazon/compare.png){: .shadow }

## What broke

The root cause lies in the scheduler ([commit](https://web.git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=7dadeaa6e851), [LKML analysis](https://lore.kernel.org/lkml/yr3inlzesdb45n6i6lpbimwr7b25kqkn37qzlvvzgad5hfd7ut@xv4cihno76wu/)):

- the default preemption mode switched from `PREEMPT_NONE` to `PREEMPT_LAZY` on the affected architectures,
- PostgreSQL in user space then spends far more CPU in `s_lock()` (up to 55% of CPU time according to the published analysis),
- the consequence is a clear drop in throughput and responsiveness under a typical OLTP load.

It is a classic example: a kernel change can heavily impact an application even without a single change in the application code.

## Fixes under discussion

Two approaches emerge from the discussions:

1. Return to a default behavior close to `PREEMPT_NONE` to fix the regression on the kernel side ([patch proposal](https://lore.kernel.org/lkml/20260403191942.21410-2-dipiets@amazon.it/)).
2. Adapt PostgreSQL to the recent kernel mechanisms (including `rseq slice`) to reduce the likelihood of preemption inside a critical section ([Peter Zijlstra's reply](https://lore.kernel.org/lkml/20260403213207.GF2872@noisy.programming.kicks-ass.net/), [rseq slice thread](https://lore.kernel.org/all/20251215155615.870031952@linutronix.de/T/#u)).

In short: rollback on the kernel side, or adaptation on the user-space side. The same trade-off is also highlighted on OpenNET, with the final decision expected from the main maintainer ([OpenNET](https://www.opennet.ru/opennews/art.shtml?num=65143)).

![Exchanges between Linux and Amazon developers](img/linux-amazon/conversation.png){: .shadow }

## Why it matters in production

- PostgreSQL is one of the most widely deployed DBMS in production.
- ARM64 is no longer a niche segment: cloud, edge and general-purpose servers.
- A near-2x drop at the end of a release cycle is a real production risk, not a micro-variation.

## What I recommend before migrating

Before moving to Linux 7.0 (or a distribution that ships it):

- run your real `pgbench` profile on ARM64,
- compare results between your current kernel and 7.0-rc,
- watch lock-heavy workloads and p95/p99 latency,
- do not accept a production migration without a direct benchmark on your workload.

> There is no universal answer along the lines of "just update everywhere".
> The right sequence is: measure on your workload, then roll out progressively.
{: .prompt-warning }

## Sources

- [LKML message from Amazon](https://lore.kernel.org/lkml/20260403191942.21410-1-dipiets@amazon.it/)
- [Linux v7.0-rc6 branch](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/?h=v7.0-rc6)
- [Commit under discussion](https://web.git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=7dadeaa6e851)
- [Additional LKML discussion](https://lore.kernel.org/lkml/yr3inlzesdb45n6i6lpbimwr7b25kqkn37qzlvvzgad5hfd7ut@xv4cihno76wu/)
- [Proposal to return to PREEMPT_NONE](https://lore.kernel.org/lkml/20260403191942.21410-2-dipiets@amazon.it/)
- [Peter Zijlstra's reply](https://lore.kernel.org/lkml/20260403213207.GF2872@noisy.programming.kicks-ass.net/)
- [`rseq slice` discussion](https://lore.kernel.org/all/20251215155615.870031952@linutronix.de/T/#u)
- [OpenNET analysis](https://www.opennet.ru/opennews/art.shtml?num=65143)
