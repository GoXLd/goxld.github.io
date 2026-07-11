---
title: Cloudflare Workers - passer de Tail Logs à quatre niveaux de logs structurés
description: Comment j'ai remplacé une commande de tail manuelle par un mode Debug contrôlé depuis le dashboard, avec des exécutions corrélées par run_id.
date: 2026-07-11
categories: [DevOps]
tags: [cloudflare, workers, observabilite, debug, logging, dashboard]
author: GoXLd
pin: false
toc: true
published: true
ads: true
mermaid: false
---

# Cloudflare Workers : arrêter de chercher une commande, commencer par lire une exécution

Bonjour à tous !

Le 8 mai, mon problème n'était pas l'absence de logs sur mes Workers Cloudflare. J'avais déjà `wrangler tail`. Le problème était le chemin pour y arriver : ouvrir une modale dans le dashboard, copier une commande, aller dans un terminal, fournir un token, lancer le stream, puis essayer de relier des lignes de texte à une exécution précise.

Ce flux est acceptable pour une intervention exceptionnelle. Il devient pénible dès que la question est simple : *pourquoi ce worker a-t-il sauté son cycle ?* ou *à quel stade cet échec est-il arrivé ?*

> En une phrase : j'ai remplacé le raccourci « Tail Logs » par un bouton `Debug` par worker, **quatre niveaux** de logs et un `run_id` qui relie début, étapes, skip, succès et erreur d'une même exécution.
{: .prompt-info }

## Le point de départ : des logs disponibles, mais sans parcours de diagnostic

| Zone | État initial |
|---|---|
| Dashboard | Une action `Tail Logs` copie une commande `wrangler` |
| Terminal | Le token doit être saisi avant de démarrer le stream |
| Worker | Niveaux `silent`, `error` et `info` |
| Exécution | Des messages utiles, mais pas de corrélation systématique entre leurs étapes |

Le vrai défaut était le découpage de la responsabilité. Le dashboard connaissait déjà le worker sélectionné, son compte et son état. Pourtant, il renvoyait l'opérateur dans un shell avant la première information exploitable.

La commande CLI reste indispensable pour certains cas — notamment un tail en direct depuis une machine d'administration — mais elle ne devait plus être le premier outil pour comprendre un état courant.

## La règle : le debug doit être temporaire et explicite

J'ai conservé un principe très simple : le niveau de log est une configuration du déploiement, pas une case qui ne fait qu'affecter l'interface. Activer le debug redéploie le worker avec `LOG_LEVEL=debug`; le désactiver le redéploie avec `LOG_LEVEL=error`.

>Les règles appliquées au flux :
>1. **Un worker, un interrupteur** — l'action ne concerne jamais un groupe implicite.
>2. **Le niveau est lu dans les bindings** — le dashboard affiche l'état réellement configuré, pas une préférence locale.
>3. **Le debug reste temporaire** — il sert à une investigation, puis revient à `error`.
>4. **Les secrets ne passent pas dans le dashboard** — la commande CLI conserve une saisie silencieuse du token lorsque le tail terminal est nécessaire.
{: .prompt-danger }

Côté API, la liste des Workers expose `log_level`, `debug_enabled` et une URL vers les événements d'observabilité. Le dashboard peut donc afficher `ON` ou `OFF`, appliquer la bascule, puis proposer le lien `Logs` seulement quand le debug est actif.

```js
// L'état affiché reflète la configuration réellement déployée.
function workerDebugEnabled(worker) {
  return worker?.debug_enabled === true
    || String(worker?.log_level || '').trim().toLowerCase() === 'debug';
}
```

## Quatre niveaux au lieu d'un flux binaire

Le changement dans les deux templates de Workers ne consiste pas à imprimer plus de texte partout. Il introduit une hiérarchie qui permet de choisir le bruit acceptable.

| Niveau `LOG_LEVEL` | Contenu |
|---|---|
| `silent` | Aucun log |
| `error` | Les erreurs uniquement |
| `info` | Les étapes principales et la synthèse d'exécution |
| `debug` | Les détails supplémentaires utiles à l'investigation |

Le niveau `debug` est supérieur à `info` : les étapes indispensables restent lisibles sans ouvrir les détails, et les détails ciblés n'apparaissent que pendant la recherche d'un problème. Les nouveaux Workers sont provisionnés avec `LOG_LEVEL=error`; un mass redeploy conserve le niveau déjà défini au lieu de le réinitialiser.

## Une exécution devient une séquence lisible

Le deuxième changement est plus important que le bouton. Chaque exécution reçoit un identifiant créé au démarrage. Les deux templates écrivent ensuite des événements structurés autour de cet identifiant : `run_start`, `run_skip`, `run_stage`, `run_end` et `run_error`.

```js
const runId = createRunId();
ctx.logInfo(`[run_start] id=${runId} trigger=${ctx.trigger}`);

// Une ligne de fin permet de relier durée et compteurs au même run_id.
ctx.logInfo(`[run_end] id=${runId} ok=true duration_ms=${durationMs}`);
```

La conséquence est opérationnelle : un `run_skip` ne ressemble plus à une absence mystérieuse. Il porte une raison — par exemple `trigger_interval`, `cooldown`, `no_items` ou `sleep_window`. Une erreur conserve le même identifiant et ajoute les compteurs disponibles au moment de l'échec. Pour un run terminé, la synthèse contient notamment la durée et les compteurs de fetch et de réponses `429`.

## Le parcours après le changement

| Étape | Avant | Après |
|---|---|---|
| Choisir un worker | Ouvrir une modale et copier une commande | Cliquer sur `Debug` dans sa ligne |
| Activer les détails | Lancer manuellement `wrangler tail` | Redéployer ce worker avec `LOG_LEVEL=debug` |
| Lire les événements | Stream terminal sans corrélation uniforme | Lien `Logs` et événements associés par `run_id` |
| Revenir au calme | Changer manuellement le déploiement | Désactiver `Debug`, redéploiement en `error` |

Le CLI n'a pas disparu. Lorsqu'il est nécessaire, la documentation garde une commande qui demande le token avec `read -s`, donc sans l'ajouter à l'historique du shell. Le dashboard ne remplace pas un accès d'administration : il réduit simplement le nombre d'étapes avant le diagnostic.

## La partie honnête : le debug n'est pas une télémétrie gratuite

Le piège aurait été de laisser `debug` actif par défaut. Les détails sont utiles quand on cherche une transition précise — une liste de liens extraite, une étape de parsing, une raison de skip — mais ils augmentent aussi le volume de logs à lire. C'est pourquoi le provisioning part de `error`, et pourquoi le bouton `Debug` est un choix explicite par worker.

Autre limite : ce travail structure les logs applicatifs, il ne garantit pas à lui seul que la cause d'un incident se trouve dans le Worker. Un `run_error` peut montrer le moment et les compteurs, mais une dépendance externe ou une mauvaise configuration demande encore les vérifications habituelles.

## Bilan

| Élément | Résultat |
|---|---|
| Niveaux de logs | **4** : `silent`, `error`, `info`, `debug` |
| Ciblage | Un interrupteur `Debug` par worker |
| Corrélation | Un `run_id` par exécution |
| Événements structurés | `run_start`, `run_skip`, `run_stage`, `run_end`, `run_error` |
| Retour au niveau nominal | Redéploiement avec `LOG_LEVEL=error` |

Le progrès n'est pas d'avoir « plus de logs ». C'est de faire correspondre le niveau de détail à la question posée, puis de rendre une exécution complète consultable comme une seule histoire.

Pour des Workers qui tournent régulièrement, la bonne question n'est donc plus « comment lancer le tail ? ». C'est : *quelle exécution est en cours, où s'est-elle arrêtée, et quel niveau d'information faut-il activer pour le prouver ?* Quand cette réponse commence dans le dashboard et se termine par un `run_id`, le diagnostic devient nettement moins mécanique.
