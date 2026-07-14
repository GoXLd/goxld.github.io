---
title: 'Du ticket Lidl à Hermes : un Cloudflare Worker et une file D1'
description: "J'ai transformé des tickets HTML en contexte fiable pour Hermes : OAuth sans navigateur, parsing structuré, D1 et livraison rejouable quand le webhook est indisponible."
date: 2026-07-12
categories: [DevOps]
tags: [cloudflare, workers, hermes, d1, oauth, telegram]
author: GoXLd
pin: false
toc: true
published: true
ads: true
language: fr-FR
translation_key: ticket-lidl-hermes-cloudflare-worker
---

# Du ticket de caisse à un agent : ne jamais perdre la liste de courses

Je voulais que mon agent puisse proposer un repas à partir de ce que j'avais réellement acheté, sans photographier un ticket ni recopier une liste dans Telegram. La source existe déjà : les tickets numériques de mon compte de fidélité. Le problème, ce n'est pas de les afficher une fois. C'est de les récupérer sans session navigateur fragile, de les transformer en données propres, puis de garantir qu'une panne temporaire de l'agent ne fasse pas disparaître un achat.

J'ai donc construit un petit service sur Cloudflare Workers. Il s'exécute **deux fois par jour**, lit au plus les **10 tickets** les plus récents, stocke les nouveaux dans D1 et livre séparément leur contenu à Hermes. Le premier commit représente **13 fichiers** et **744 lignes ajoutées** : assez petit pour être relu entièrement, mais avec une vraie frontière entre collecte, persistance et notification.

> En une phrase : le ticket est écrit dans D1 avant toute livraison ; un webhook indisponible crée du retard, pas une perte de données.
{: .prompt-info }

## Le point de départ

| Zone | État avant |
|---|---|
| Liste de courses pour l'agent | saisie manuelle ou contexte absent |
| Ticket numérique | HTML pensé pour l'affichage, pas une API métier stable |
| Authentification | ne pas rejouer un login et ne pas piloter un navigateur en production |
| Livraison à l'agent | impossible à faire directement de bot Telegram à bot Telegram |
| Échec du webhook | ne devait jamais faire perdre un ticket |

Le piège initial était Telegram. Deux bots ne peuvent pas s'écrire directement : le service qui lit les tickets ne peut donc pas « envoyer un message à Hermes » comme il le ferait à un humain. La livraison vers l'agent passe par un webhook HTTP signé ; Telegram reste réservé aux alertes destinées à une personne.

## La méthode : authentifier, stocker, puis livrer

Le site et l'application mobile du programme de fidélité s'appuient sur le même fournisseur d'identité. Le Worker conserve un `refresh_token` comme secret et l'échange à chaque exécution contre un `access_token` court. Celui-ci permet d'appeler l'API des tickets sans stocker de mot de passe, sans CAPTCHA et sans automatisation de navigateur.

Le flux complet tient dans une idée simple : chaque étape a son état durable.

```text
cron
  → refresh_token → access_token
  → liste des tickets récents
  → détail HTML de chaque ticket inconnu
  → parsing des articles
  → INSERT dans D1 avec notified_at = NULL
  → POST webhook Hermes
  → notified_at = horodatage de livraison
```

La table principale sépare notamment l'identifiant du ticket, sa date, son total, le JSON des articles, la version du parseur et `notified_at`. Cette dernière colonne est le contrat de reprise : un ticket enregistré mais non livré reste sélectionnable au prochain passage.

>Les règles non négociables :
>1. **Persister avant de notifier** — l'agent ne devient jamais l'unique copie de l'achat.
>2. **Marquer livré uniquement après succès** — une réponse en erreur laisse le ticket en attente.
>3. **Arrêter la livraison à la première erreur** — les tickets suivants conservent aussi leur ordre et leur statut en attente.
{: .prompt-danger }

## Extraire des données de HTML sans faire confiance au HTML

Le détail d'un ticket arrive sous forme de `htmlPrintedReceipt`. Le texte visible ressemble à un reçu monospacé : pratique pour un humain, mauvais contrat pour un parseur. Heureusement, chaque ligne d'article porte des attributs `data-*` pour l'identifiant, le prix unitaire et la quantité.

```js
// Les attributs donnent les nombres ; le texte visible donne le nom lisible.
const name = visible.split(/\s{2,}/u)[0].trim();
const unitPrice = parseDecimal(attr(tag, 'data-unit-price'));
const quantity = parseDecimal(attr(tag, 'data-art-quantity')) ?? 1;
const lineTotal = parseDecimal(decimals.at(-1));
```

Le détail important est le nom. L'attribut de description du produit contient parfois des octets encodés de travers ; le parseur prend donc le libellé du texte visible, dont les entités HTML sont décodées. Il réconcilie ensuite le total avec la ligne « À payer » du ticket.

| Élément | Source retenue | Raison |
|---|---|---|
| Quantité | attribut `data-art-quantity` | valeur structurée |
| Prix unitaire | attribut `data-unit-price` | valeur structurée |
| Nom du produit | texte visible décodé | évite les caractères mal encodés |
| Total | ligne « À payer » | contrôle de cohérence du reçu |

Le test de parsing s'appuie sur un ticket réel anonymisé : il vérifie qu'il contient au moins **30 articles**, que chaque ligne possède un nom et un total numérique, qu'un lot conserve sa quantité, et qu'un libellé avec accent est correctement décodé. Un second test impose le retour `null` pour une page qui n'est pas un ticket.

## Le morceau qui compte : la livraison rejouable

Dans le Worker, la collecte et la livraison sont deux boucles distinctes. La première insère uniquement les tickets inconnus. La seconde demande à D1 tous ceux dont `notified_at` vaut `NULL`, les poste un par un au webhook, puis les marque seulement quand l'appel a réussi.

```js
for (const row of pendingReceipts) {
  const ok = await notifyHermes(env, row);
  if (!ok) break; // le ticket reste en attente pour le prochain run
  await markNotified(env, row.id);
}
```

C'est volontairement moins sophistiqué qu'une queue complète, mais le comportement est clair : webhook absent, timeout, ou agent momentanément indisponible — le prochain cron reprend là où le précédent s'est arrêté. Le service ne déclare pas un succès imaginaire et ne met pas à jour `notified_at` par optimisme.

## La partie honnête : les fausses pistes

Le premier réflexe aurait été d'utiliser Telegram partout. Il échoue par conception pour un échange bot-à-bot. Le webhook est moins visible, mais c'est le bon canal machine-à-machine ; le bot de notification reste utile, lui, pour avertir un humain qu'une authentification a expiré.

Deuxième limite : le parseur dépend encore de la structure HTML et des attributs que le fournisseur expose aujourd'hui. J'ai isolé ce risque dans `parseReceiptHtml()` et enregistré une `parser_version` avec chaque ticket. Si le HTML change, je peux corriger le parseur et savoir avec quelle version chaque donnée a été produite, plutôt que de disperser une expression régulière dans le Worker.

Enfin, un `refresh_token` n'est pas éternel. S'il est invalidé, l'exécution alerte l'administrateur et exige de rejouer le flux OAuth. Ce n'est pas une panne silencieuse, mais ce n'est pas non plus de l'autonomie magique.

## Bilan

| Métrique | Résultat |
|---|---|
| Fréquence de synchronisation | **2 fois par jour** |
| Fenêtre de lecture | **10 tickets** récents |
| Livraison | webhook HTTP signé, rejouable |
| Persistance | D1 avant notification |
| Tests de parsing | ticket réel anonymisé + HTML non conforme |
| Point de reprise | `notified_at = NULL` |

Le résultat n'est pas une « IA qui lit mes courses ». C'est un pipeline modeste qui donne à l'agent un contexte dont je connais la provenance : un ticket, des articles structurés, une date et un statut de livraison.

La bonne question n'est plus « comment envoyer une liste à un bot ? », mais « quelle preuve garde-t-on lorsqu'un système intermédiaire tombe ? ». Dans ce cas, une colonne `notified_at` et l'ordre persistance → livraison font plus pour la fiabilité qu'une intégration spectaculaire. Hermes peut alors raisonner sur le dernier achat, tandis que le Worker garde la responsabilité plus terre-à-terre de ne rien oublier.
