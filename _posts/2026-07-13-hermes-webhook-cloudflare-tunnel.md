---
title: 'Hermes derrière un tunnel : un webhook signé plutôt qu’un bot qui parle à un bot'
description: "Comment j’ai exposé un webhook Hermes via un Cloudflare Tunnel, gardé la signature HMAC à la frontière et vérifié la livraison de 10 événements sans ouvrir mon poste personnel."
date: 2026-07-13
categories: [DevOps]
tags: [hermes, cloudflare, tunnel, webhook, hmac, automatisation]
author: GoXLd
pin: false
toc: true
published: true
ads: true
mermaid: false
---

# Hermes derrière un tunnel : ne pas confondre exposition et livraison

Je voulais faire parvenir à Hermes des achats déjà structurés par un Worker distant. La première idée paraît banale : exposer une URL HTTP, faire un `POST`, puis attendre le message de confirmation. En pratique, l’agent tourne sur une machine qui ne doit pas devenir un serveur public, et l’émetteur comme le destinataire peuvent tomber séparément.

Le piège venait aussi du canal : un bot Telegram ne peut pas être un transport fiable vers un autre bot. J’ai donc séparé les rôles : le Worker produit l’événement, un webhook signé le remet à Hermes, et Telegram reste un canal destiné à l’humain.

> En une phrase : un Cloudflare Tunnel rend Hermes joignable sans ouvrir le poste personnel ; la signature HMAC décide si une requête peut entrer, et l’état durable côté Worker décide si elle doit être rejouée.
{: .prompt-info }

## Le point de départ

| Zone | État initial |
|---|---|
| Agent Hermes | Service accessible localement, pas une API publique à exposer directement |
| Producteur d’événements | Cloudflare Worker pouvant appeler HTTP |
| Transport imaginé au départ | Notification Telegram entre deux bots |
| Risque principal | Une requête perdue ou forgée devait être distinguée d’un succès |
| Validation disponible | Route de test répondant `202 Accepted` lorsque le webhook est sain |

Un tunnel nommé tourne sur l’hôte qui exécute Hermes — pas sur mon Mac. Il relaie uniquement la route de webhook vers le service local. Cette distinction est importante : je n’ai ni ouvert un port entrant sur ma machine personnelle, ni rendu l’interface Hermes entière disponible sur Internet.

## Une frontière minimale : tunnel, route, signature

Le flux n’a pas besoin d’être compliqué pour être vérifiable : le producteur prépare le corps, calcule une signature avec un secret partagé, puis appelle l’URL publique du tunnel. Hermes vérifie la signature avant de traiter l’événement.

```text
Cloudflare Worker
  → POST signé par HMAC
  → Cloudflare Tunnel
  → route /webhooks/… sur l’hôte Hermes
  → vérification de signature
  → traitement de l’événement
  → 202 Accepted
```

>Les règles retenues à la frontière :
>1. **Un secret n’est jamais placé dans l’URL** — le corps et la signature voyagent séparément.
>2. **Le tunnel ne publie qu’une route utile** — ce n’est pas un raccourci pour exposer l’interface locale de l’agent.
>3. **Un `202` n’est pas une preuve de persistance côté producteur** — celui-ci conserve son propre état de reprise.
{: .prompt-danger }

Le test du webhook utilise la même route que le Worker et a bien retourné `202 Accepted`. C’est une vérification de disponibilité : le tunnel arrive au service et la route accepte une requête authentifiée. Ce n’est volontairement pas un test de contenu métier complet.

## Pourquoi le tunnel ne remplace pas une file

Le tunnel répond à une seule question : *comment atteindre un service local sans l’exposer directement ?* Il ne répond pas à la question suivante : *que faire si Hermes est momentanément indisponible après la collecte d’un événement ?*

La réponse reste du côté du Worker : l’événement est enregistré avant la tentative de livraison, puis son statut n’est mis à jour qu’après une réponse réussie. Dans le pipeline actuel, les **10 tickets** de la première page ont été livrés à Hermes ; ce chiffre confirme le premier passage, pas une garantie magique pour tous les incidents futurs.

| Situation | Ce que résout le tunnel | Ce que doit résoudre le producteur |
|---|---|---|
| Hermes accessible localement | URL HTTPS sans port ouvert sur le poste personnel | Rien de plus |
| Requête sans signature valide | Rien : elle atteint la frontière | Hermes la refuse |
| Tunnel ou service indisponible | Rien : l’appel échoue | Garder l’événement et réessayer |
| Réponse `202 Accepted` | La route a accepté la remise | Marquer l’événement livré seulement selon le contrat défini |

Cette séparation empêche une confusion fréquente : un endpoint joignable n’est pas une queue. Le tunnel transporte une tentative ; la persistance et le statut de livraison rendent la tentative rejouable.

## La partie honnête : une surface réseau de plus

Le tunnel évite d’ouvrir un port entrant, mais il crée tout de même une URL publique. Une erreur de configuration peut donc élargir la surface exposée bien au-delà du webhook prévu. J’ai gardé la route dédiée et la signature HMAC précisément pour que « connaître l’URL » ne suffise pas à injecter un événement.

Autre limite : le test `202` ne démontre ni la qualité du parsing côté Worker, ni l’effet final produit par Hermes. Il vérifie la plomberie. Les tests de données et le mécanisme de reprise restent des responsabilités distinctes ; les confondre aurait donné une fausse impression de fiabilité.

## Bilan

| Élément | Résultat |
|---|---|
| Exposition réseau | Cloudflare Tunnel vers une route de webhook dédiée |
| Protection d’entrée | Signature HMAC, sans secret dans l’URL |
| Test de santé | `202 Accepted` |
| Hôte du tunnel | Machine Hermes, pas le poste personnel |
| Première livraison observée | **10 tickets** de la première page |
| Garantie de reprise | Persistance et statut côté Worker, pas le tunnel |

Le résultat n’est pas « Hermes ouvert sur Internet ». C’est une frontière étroite entre un producteur distant et un agent local : assez accessible pour recevoir un événement, assez contrôlée pour refuser une requête qui n’a pas la bonne signature.

La question utile n’est plus « comment joindre mon agent depuis un Worker ? », mais « quelle partie du système prouve qu’un événement a été accepté, traité et, si besoin, rejoué ? ». Le tunnel répond proprement à la première partie ; le reste doit rester explicite dans le contrat de livraison.
