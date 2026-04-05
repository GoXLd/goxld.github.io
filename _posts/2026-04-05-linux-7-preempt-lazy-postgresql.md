---
title: Linux 7.0 et PostgreSQL sur ARM64 - analyse d'une régression
description: Pourquoi pgbench chute presque de moitié sur Linux 7.0-rc avec ARM64, et quoi vérifier avant la mise en production.
date: 2026-04-05
tags: [linux, postgresql, arm64, performance, kernel]
author: GoXLd
pin: false
toc: false
published: true
ads: true
image:
  path: img/linux-amazon/linux-postgressql.png
---

# Linux 7.0 et PostgreSQL sur ARM64 - analyse d'une régression

Dans la branche de test Linux 7.0, une régression importante a été observée par Salvatore Dipietro (Amazon): sur PostgreSQL (`pgbench simple-update`), la performance sur ARM64 chute presque de moitié ([LKML](https://lore.kernel.org/lkml/20260403191942.21410-1-dipiets@amazon.it/)).

D'après les chiffres publiés, le résultat passe d'environ **98 565** à **50 751** opérations.
Comme Linux 7.0 est en phase finale de validation (`v7.0-rc6`), ce sujet concerne directement les admins et les équipes dev ([kernel.org](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/?h=v7.0-rc6)).

![Comparaison des performances PostgreSQL sur Linux 7.0](img/linux-amazon/compare.png){: .shadow }

## Ce qui a cassé

La cause principale est liée à l'ordonnanceur ([commit](https://web.git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=7dadeaa6e851), [analyse LKML](https://lore.kernel.org/lkml/yr3inlzesdb45n6i6lpbimwr7b25kqkn37qzlvvzgad5hfd7ut@xv4cihno76wu/)):

- le mode de préemption par défaut est passé de `PREEMPT_NONE` à `PREEMPT_LAZY` sur les architectures concernées,
- PostgreSQL en user space passe alors beaucoup plus de CPU dans `s_lock()` (jusqu'à 55% du temps CPU selon l'analyse publiée),
- la conséquence est une baisse nette du débit et de la réactivité sous charge OLTP typique.

C'est un exemple classique: un changement kernel peut impacter fortement une application, même sans modification du code applicatif.

## Pistes de correction discutées

Deux approches ressortent des échanges:

1. Revenir à un comportement par défaut proche de `PREEMPT_NONE` pour corriger la régression côté noyau ([proposition de patch](https://lore.kernel.org/lkml/20260403191942.21410-2-dipiets@amazon.it/)).
2. Adapter PostgreSQL aux mécanismes récents du noyau (dont `rseq slice`) pour réduire la probabilité de préemption en section critique ([réponse de Peter Zijlstra](https://lore.kernel.org/lkml/20260403213207.GF2872@noisy.programming.kicks-ass.net/), [thread rseq slice](https://lore.kernel.org/all/20251215155615.870031952@linutronix.de/T/#u)).

En clair: rollback côté kernel ou adaptation côté user space. Le même arbitrage est aussi souligné côté OpenNET, avec la décision finale attendue côté mainteneur principal ([OpenNET](https://www.opennet.ru/opennews/art.shtml?num=65143)).

![Échanges entre développeurs Linux et Amazon](img/linux-amazon/conversation.png){: .shadow }

## Pourquoi c'est important en production

- PostgreSQL est l'un des SGBD les plus déployés en production.
- ARM64 n'est plus un segment de niche: cloud, edge et serveurs généralistes.
- Une chute proche de x2 en fin de cycle de release est un vrai risque prod, pas une micro-variation.

## Ce que je recommande avant migration

Avant de passer à Linux 7.0 (ou à une distribution qui l'intègre):

- exécutez votre profil `pgbench` réel sur ARM64,
- comparez les résultats entre votre noyau actuel et 7.0-rc,
- surveillez les workloads lock-heavy et la latence p95/p99,
- n'acceptez pas la migration prod sans benchmark direct sur votre charge.

> Il n'existe pas de réponse universelle du type "on met à jour partout".
> La bonne séquence est: mesurer sur votre workload, puis déploiement progressif.
{: .prompt-warning }

## Sources

- [Article sur Habr](https://habr.com/ru/news/1019386/)
- [Message LKML depuis Amazon](https://lore.kernel.org/lkml/20260403191942.21410-1-dipiets@amazon.it/)
- [Branche Linux v7.0-rc6](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/?h=v7.0-rc6)
- [Commit discuté](https://web.git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=7dadeaa6e851)
- [Discussion complémentaire LKML](https://lore.kernel.org/lkml/yr3inlzesdb45n6i6lpbimwr7b25kqkn37qzlvvzgad5hfd7ut@xv4cihno76wu/)
- [Proposition de retour vers PREEMPT_NONE](https://lore.kernel.org/lkml/20260403191942.21410-2-dipiets@amazon.it/)
- [Réponse de Peter Zijlstra](https://lore.kernel.org/lkml/20260403213207.GF2872@noisy.programming.kicks-ass.net/)
- [Discussion sur `rseq slice`](https://lore.kernel.org/all/20251215155615.870031952@linutronix.de/T/#u)
- [Analyse OpenNET](https://www.opennet.ru/opennews/art.shtml?num=65143)
