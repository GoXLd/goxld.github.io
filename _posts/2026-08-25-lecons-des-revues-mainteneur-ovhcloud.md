---
title: Le guide de revue d'un mainteneur OVHcloud, transformé en méthode
description: Les revues détaillées du mainteneur Y0Coss sur mes récents PR de documentation OVHcloud, transformées en méthode concrète de maintenance documentaire et de gestion des LTS — choix des versions de remplacement, sorties console authentiques et discipline de preuve.
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
language: fr-FR
translation_key: lecons-revues-mainteneur-ovhcloud
---

# Quand un mainteneur devient mentor : les leçons des revues OVHcloud

Bonjour à tous !

Dans mon [précédent billet](/posts/sept-contributions-documentation-ovhcloud/), je racontais mes sept premières contributions acceptées dans la documentation OVHcloud. Depuis, une deuxième vague a suivi : huit nouveaux merges (#620 à #625, #627 et #643 — 62 fichiers), trois PR approuvées en attente de migration interne, et surtout **une série de revues si détaillées qu'elles méritent mieux que la corbeille à notifications**.

Le mainteneur qui les signe, Y0Coss, justifie chaque demande par des faits vérifiables : un ETag nginx décodé, les fenêtres de support PHP et Debian, les conventions de nommage des ancres. Chaque revue est une petite leçon d'ingénierie documentaire — je les ai donc rassemblées en méthode de travail, et ce billet en est la version publique.

> En une phrase : huit merges supplémentaires (62 fichiers, toutes les langues), aucun refus sec — et une méthode de maintenance née directement des revues. Une bonne revue enseigne plus que le merge lui-même.
{: .prompt-info }

## Deuxième vague : le tableau d'abord

| Contribution | Périmètre | Résultat upstream |
|---|---:|---|
| [#620](https://github.com/ovh/ovhcloud-docs/pull/620) — marqueur `mdstat` restauré | 7 fichiers | merge direct |
| [#621](https://github.com/ovh/ovhcloud-docs/pull/621) — ancres TOC IPsec | 7 fichiers | reprise selon revue, merge |
| [#622](https://github.com/ovh/ovhcloud-docs/pull/622) — ancre « Go further » HA-NAS | 7 fichiers | merge direct |
| [#623](https://github.com/ovh/ovhcloud-docs/pull/623) — référence morte Kafka/OpenSearch | 2 fichiers | merge direct |
| [#624](https://github.com/ovh/ovhcloud-docs/pull/624) — coquilles d'ancres | 14 fichiers | merge direct |
| [#625](https://github.com/ovh/ovhcloud-docs/pull/625) — placeholders français résiduels | 11 fichiers | merge direct |
| [#627](https://github.com/ovh/ovhcloud-docs/pull/627) — images EOL WordPress Docker | 7 fichiers | merge direct |
| [#643](https://github.com/ovh/ovhcloud-docs/pull/643) — image mariadb:10.6 EOL | 7 fichiers | merge direct |
| **Total** | **62 fichiers** | **8 corrections acceptées** |

Les PR #628 (PHP 8.4) et #629 (Python/Wagtail) sont approuvées et attendent leur migration ; #640, #641 et #644 sont en cours de revue. Comme la première fois, j'ai vérifié chaque commit final : mon auteur d'origine (`goxld@ya.ru`) est préservé sur toute la ligne.

## La règle n° 1 : « pleinement supporté », pas juste « plus récent »

Ma première version de #644 remplaçait `debian:9-slim` par `debian:12-slim`. Raisonnement classique : stretch est mort, bookworm est stable, next. La revue a déplacé la ligne de départ :

> Debian 12 est passée *oldstable* quand trixie est devenue stable, sa sécurité standard s'est terminée en juillet. `13-slim` est un changement d'un seul token qui achète trois ans de support de plus.
>
> C'est le même schéma que la discussion PHP 8.3 sur #628 : il faut vérifier que la version de remplacement est en support **complet**, pas seulement plus récente que celle qu'elle remplace.
{: .prompt-tip }

PHP 8.3 avait quitté le support actif fin 2025 ; c'est donc 8.4 qui est entré dans #628. MySQL visait la ligne LTS 8.4 plutôt que le train 9.x. La règle généralisée : un remplacement EOL doit acheter des années, sinon on ne fait que déplacer la dette.

Deuxième réflexe à ancrer : vérifier les tags Docker par digest, pas par nom. `stable-slim` ne correspondait ni à `bookworm-slim` ni à `trixie-slim` — les alias flottants se déplacent silencieusement d'une version à l'autre.

## La règle n° 2 : ne jamais inventer une sortie console

C'est la leçon qui m'est restée la plus vivement en mémoire — d'autant qu'elle est arrivée par deux chemins. Sur #641, j'avais remplacé `Server: nginx/1.7.9` par `nginx/1.27.3` dans un exemple `curl -I`, pour que la transcription colle au nouveau tag. Mais j'avais laissé l'ancien `Last-Modified` et l'ancien `ETag` — et la revue a démonté cet ETag pièce par pièce :

```text
ETag = hex(mtime)-hex(size)
54999765 → 2014-12-23 16:25:09 UTC  = le Last-Modified annoncé
     108 → 264 octets                 = le Content-Length annoncé
```

Une empreinte parfaitement cohérente de la page d'accueil par défaut de la version 1.7.9, et d'elle seule. Un en-tête `Server: 1.27.3` à côté de ces valeurs décrivait une réponse HTTP qui ne peut pas exister. Même verdict pour la sortie `SHOW DATABASES;` de l'époque MySQL 5.6 dans #640 : ne pas la reconstruire à la main — « une transcription périmée vaut mieux qu'une inventée ».

La procédure est maintenant claire :

>Mes règles sur les transcriptions :
>1. **Un exemple de sortie est une donnée, pas de la décoration** — il doit rester une capture authentique et datée.
>2. **Jamais retoucher à la main** pour « rajeunir » : cohérence interne vérifiable oblige.
>3. **Rafraîchir = exécuter pour de vrai** — sur le cluster MKS réel, pas dans son tête.
>4. **Séparer les scopes** : le PR prouve ce qu'il peut prouver (le bump de tag) et déclare explicitement ce qui attend un run réel.
{: .prompt-danger }

J'ai poussé un commit de revert (`01d30e62a`) qui remettait les lignes `Server:` d'origine tout en gardant les bumps d'image — accepté sans discussion.

## La règle n° 3 : les ancres ont une mémoire et une grammaire

Sur #621, mon premier réflexe a été d'ajouter des ancres `<a name="changepassworden">` là où des liens TOC pointaient dans le vide. La revue a fait demi-tour : ces sections portaient déjà des ancres `-fr` (France !), et les miennes les auraient laissées orphelines. Onze autres ancres du même guide confirmaient que le suffixe est **géographique**, pas linguistique. Le bon fix : repointer les six autres locales vers les ancres existantes — zéro nouvelle définition, convention respectée.

Règle généralisée : avant d'ajouter quoi que ce soit, examiner ce qui existe déjà près de la cible ; compter les usages pour lire la convention ; puis faire converger toutes les variantes vers la forme déjà correcte.

## La règle n° 4 : lier, ne pas reformuler

Dans #629, ma phrase « Wagtail nécessite Python 3.10 ou supérieur » répétait mot pour mot la documentation officielle — et aurait vieilli à la prochaine release de Wagtail. Conclusion de la revue : lier la source primaire plutôt que copier une liste de versions promise au vieillissement. En bonus, il s'est avéré qu'aucune URL localisée n'existe : la documentation Wagtail est uniquement anglophone, et `/fr/stable/...` renvoyait un 404.

## L'étiquette de revue, vue du côté revué

Ce qui m'a marqué ces derniers jours, c'est autant la forme que le fond :

1. Chaque revue **commence par valider** ce qui est correct avant toute correction.
2. Les demandes sont **graduées** explicitement : « blocking » / « not blocking but worth taking while the PR is open » / « wording tweak ».
3. Les contre-arguments sont portés par des preuves (un digest décodé, une date de fin de support), jamais par l'autorité.
4. Quand une direction est infirmée, la réponse propre tient en deux lignes : « reworked as suggested » + SHA du commit.

J'ai publié sous #641 un remerciement public pour cette qualité de revue — c'est rare, et ça mérite d'être dit là où le travail a été fait.

## Bilan

| Métrique | Résultat |
|---|---|
| Nouveaux merges (2ᵉ vague) | 8 PR, 62 fichiers, +104/−104 |
| Attribution | commit original préservé sur les 8 |
| En attente | #628/#629 approuvées, #640/#641/#644 en revue |
| Guide produit | règles de versioning, transcriptions, ancres, preuves |

Le vrai gain de ce cycle n'est ni le nombre de fichiers ni le nombre de merges. C'est la méthode qui reste une fois les revues individuelles terminées : comment choisir une version de remplacement, quand ne PAS toucher une transcription, comment lire la convention d'un dépôt avant de commencer à la changer. Une contribution qui survit à une bonne revue forme deux fois : pendant qu'on la corrige, puis quand on comprend pourquoi elle devait l'être.
