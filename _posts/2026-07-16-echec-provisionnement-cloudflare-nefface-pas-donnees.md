---
title: Un échec de provisionnement Cloudflare ne doit pas effacer les données déjà créées
description: Comment j’ai remplacé un rollback destructif par un succès avec avertissement et une compensation explicite lorsqu’un déploiement Cloudflare échoue à mi-chemin
date: 2026-07-16
categories: [DevOps]
tags: [cloudflare, workers, directus, api, fiabilite, rollback]
author: GoXLd
pin: false
toc: true
published: true
ads: true
mermaid: false
language: fr-FR
translation_key: echec-provisionnement-cloudflare-nefface-pas-donnees
---

# Un Worker peut échouer sans faire disparaître le reste

Le 20 mai, j’ai ajouté le provisionnement automatique d’un Cloudflare Worker quand je crée un nouvel élément dans mon application. L’idée était pratique : une seule action dans le dashboard créait la donnée, préparait sa collection et déployait le Worker qui allait l’exploiter.

Le problème est apparu dans le chemin d’erreur. Si le déploiement Cloudflare échouait après la création des données, l’API supprimait l’élément et, quand elle venait d’être créée, sa collection. On traitait une erreur d’infrastructure comme si la demande métier entière n’avait jamais existé.

> En une phrase : le 28 mai, j’ai remplacé un rollback qui supprimait les données métier par un succès avec avertissement, plus une tentative de nettoyage explicite du Worker partiellement créé.
{: .prompt-info }

## Le point de départ : une seule action, plusieurs systèmes

Une création dans le dashboard enchaînait plusieurs opérations dont les garanties ne sont pas les mêmes : une base applicative, une collection de données et l’API Cloudflare. La transaction SQL n’existait pas à cette frontière : chaque étape pouvait réussir alors que la suivante échouait.

| Zone | Comportement avant le correctif |
|---|---|
| Élément métier | Supprimé si l’auto-déploiement du Worker échouait |
| Collection créée pendant la requête | Supprimée elle aussi |
| Worker créé partiellement | Aucun nettoyage dédié dans ce chemin |
| Réponse API | Erreur : la création semblait avoir entièrement échoué |

Ce comportement avait l’air propre sur le papier : « si tout n’est pas déployé, on annule tout ». En réalité, il mélangeait deux niveaux de responsabilité. La création de la donnée est durable et rejouable ; le déploiement d’un Worker est une dépendance externe qui peut échouer pour des raisons transitoires ou de configuration.

Le pire scénario n’était donc pas seulement un Worker absent. C’était une donnée que l’utilisateur venait de créer, puis que le backend supprimait à sa place pour masquer l’échec d’un appel externe.

## La règle : compenser uniquement ce qui appartient au déploiement

J’ai posé une règle simple : une erreur de provisionnement ne doit pas annuler une création métier déjà valide. En revanche, si l’appel externe a laissé un Worker derrière lui, l’API doit tenter de le supprimer et expliquer précisément le résultat au client.

>Les règles devenues non négociables :
>1. **Ne pas supprimer l’élément ni sa collection** après un échec de déploiement externe.
>2. **Nettoyer seulement la ressource Cloudflare potentiellement orpheline**.
>3. **Renvoyer une réponse réussie avec avertissement** : le client doit savoir que la donnée existe, mais que le Worker demande une intervention.
{: .prompt-danger }

Ce n’est pas une transaction distribuée magique. C’est une compensation ciblée : je ne prétends pas pouvoir remettre plusieurs services dans un état atomique, mais je limite explicitement la ressource qui a pu être créée par le dernier effet de bord.

## Le correctif : conserver la donnée, tracer la compensation

Le commit du **28 mai 2026** modifie un seul fichier backend : **49 ajouts** et **18 suppressions**. Le bloc de rollback qui effaçait l’élément et la collection a été remplacé par un état de nettoyage du Worker.

```js
const cleanupState = {
  attempted: false,
  deleted: false,
  skipped: false,
  error: null
};

// Le seul effet de bord à compenser est le Worker externe.
await cloudflareApiRequest({
  method: 'DELETE',
  path: `/accounts/${accountId}/workers/scripts/${workerId}`,
  token,
  timeout: 45000
});
cleanupState.deleted = true;
```

La compensation porte aussi une nuance importante : une réponse `404` pendant le `DELETE` est considérée comme un nettoyage réussi. Dans ce contexte, l’objectif n’est pas de prouver que le Worker a existé ; l’objectif est de garantir qu’il n’existe plus après le traitement.

La réponse finale distingue ensuite trois cas lisibles : nettoyage fait, nettoyage ignoré parce qu’il manque le contexte nécessaire, ou nettoyage tenté mais en erreur. L’API conserve cette information dans un champ d’avertissement dédié, au lieu de l’enfouir dans une erreur générique.

| Situation après l’échec Cloudflare | Réponse au dashboard |
|---|---|
| Worker supprimé, y compris si l’API répond `404` | Création réussie avec avertissement de nettoyage effectué |
| Identifiant ou configuration insuffisants | Création réussie avec avertissement de nettoyage ignoré |
| Suppression Cloudflare en erreur | Création réussie avec avertissement de nettoyage échoué |

Le front peut donc afficher une action claire : la donnée créée est utilisable et le déploiement doit être relancé ou vérifié. Surtout, une erreur temporaire chez le fournisseur ne transforme plus une création réussie en disparition silencieuse.

## La partie honnête : le premier rollback était trop agressif

Le coupable, c’était mon raccourci initial. J’avais vu « provisionnement automatique » comme une opération indivisible et choisi le rollback total pour éviter les états incomplets. C’était rassurant, mais faux : une collection et un élément applicatif ne sont pas le même objet qu’un Worker distant.

Le nouveau code ne promet pas non plus le zéro état intermédiaire. Si le nettoyage du Worker échoue, il peut rester une ressource à traiter. La différence est que cet état est maintenant **signalé**, conservé côté métier et donc récupérable sans demander à l’utilisateur de recréer sa donnée.

Autre limite volontaire : je n’ai pas ajouté de suppression automatique différée ni de retry en arrière-plan dans ce correctif. Le commit reste concentré sur la réponse à la requête : ne rien détruire par erreur, tenter la compensation immédiatement, puis exposer le résultat.

## Bilan : une compensation est plus honnête qu’un faux rollback

| Mesure vérifiable | Résultat |
|---|---|
| Fichier modifié | `gXd.node/config-api.js` |
| Diff du correctif | **49 ajouts, 18 suppressions** |
| Données métier supprimées après un échec de déploiement | **0** après le correctif |
| États de nettoyage exposés | supprimé, ignoré ou en erreur |
| Date du correctif | 28 mai 2026 |

Dans les workflows qui appellent plusieurs services, la vraie question n’est pas « comment tout annuler ? ». C’est : **quelle étape est réellement sûre à annuler, et quel état doit rester visible quand elle ne l’est pas ?**

Ici, conserver la donnée et rendre l’échec du Worker observable est plus fiable que de faire semblant que l’ensemble était transactionnel. Le rollback le plus sûr n’est pas toujours celui qui supprime le plus de choses : c’est celui qui ne détruit que l’effet de bord dont il est responsable.
