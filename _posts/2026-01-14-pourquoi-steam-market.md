---
title: Pourquoi Steam Market est un excellent terrain d'apprentissage
description: Un marché mondial piloté par les utilisateurs, utile pour progresser en scraping, en data et en logique économique.
date: 2026-01-14
tags: [steam, scraping, economie, data]
author: GoXLd
pin: false
toc: false
published: true
ads: true
image:
  path: img/steam/steammarket.jpg
  lqip: data:image/jpeg;base64,/9j/4QDKRXhpZgAATU0AKgAAAAgABgESAAMAAAABAAEAAAEaAAUAAAABAAAAVgEbAAUAAAABAAAAXgEoAAMAAAABAAIAAAITAAMAAAABAAEAAIdpAAQAAAABAAAAZgAAAAAAAABIAAAAAQAAAEgAAAABAAeQAAAHAAAABDAyMjGRAQAHAAAABAECAwCgAAAHAAAABDAxMDCgAQADAAAAAQABAACgAgAEAAAAAQAAABKgAwAEAAAAAQAAAAmkBgADAAAAAQAAAAAAAAAAAAD/4gHYSUNDX1BST0ZJTEUAAQEAAAHIAAAAAAQwAABtbnRyUkdCIFhZWiAH4AABAAEAAAAAAABhY3NwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAA9tYAAQAAAADTLQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAlkZXNjAAAA8AAAACRyWFlaAAABFAAAABRnWFlaAAABKAAAABRiWFlaAAABPAAAABR3dHB0AAABUAAAABRyVFJDAAABZAAAAChnVFJDAAABZAAAAChiVFJDAAABZAAAAChjcHJ0AAABjAAAADxtbHVjAAAAAAAAAAEAAAAMZW5VUwAAAAgAAAAcAHMAUgBHAEJYWVogAAAAAAAAb6IAADj1AAADkFhZWiAAAAAAAABimQAAt4UAABjaWFlaIAAAAAAAACSgAAAPhAAAts9YWVogAAAAAAAA9tYAAQAAAADTLXBhcmEAAAAAAAQAAAACZmYAAPKnAAANWQAAE9AAAApbAAAAAAAAAABtbHVjAAAAAAAAAAEAAAAMZW5VUwAAACAAAAAcAEcAbwBvAGcAbABlACAASQBuAGMALgAgADIAMAAxADb/2wCEAAEBAQEBAQIBAQIDAgICAwQDAwMDBAUEBAQEBAUGBQUFBQUFBgYGBgYGBgYHBwcHBwcICAgICAkJCQkJCQkJCQkBAQEBAgICBAICBAkGBQYJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCf/dAAQAAv/AABEIAAkAEgMBIgACEQEDEQH/xAGiAAABBQEBAQEBAQAAAAAAAAAAAQIDBAUGBwgJCgsQAAIBAwMCBAMFBQQEAAABfQECAwAEEQUSITFBBhNRYQcicRQygZGhCCNCscEVUtHwJDNicoIJChYXGBkaJSYnKCkqNDU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6g4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2drh4uPk5ebn6Onq8fLz9PX29/j5+gEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoLEQACAQIEBAMEBwUEBAABAncAAQIDEQQFITEGEkFRB2FxEyIygQgUQpGhscEJIzNS8BVictEKFiQ04SXxFxgZGiYnKCkqNTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqCg4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2dri4+Tl5ufo6ery8/T19vf4+fr/2gAMAwEAAhEDEQA/APuqD4ifETwV4um+C/iS3hvhp2m2GpTTXMIjjhW4VzHDIkW8M0flHCKMgAAnPJ5vxpN4yufCEcNvrVzYaLCjXJuLiP8A1dkMZDAKjRN5jbinLCMYNfQf7N3/ACXb4o/9ddJ/9EPWr+3r/wAmofED/sGW/wD6NFeFQoxliIQirX5fxS6H7FLHxhio4fk/l/FLpbzPzpl+EHhe3laC+8DzXkyErJPBLcrFKw4LoobhWPKjsKj/AOFTeDf+ifXX/f65/wDiq+/9C/5Aln/1wj/9BFatcn9t1j2edn//2Q==
---

# Pourquoi Steam Market est un excellent terrain d'apprentissage

Quand je fais des tests de scraping et d'analyse de données, je reviens souvent vers Steam Market.
Pas parce que c'est "du jeu", mais parce que c'est un **véritable système économique distribué**, avec des contraintes techniques bien réelles.

À première vue, la plateforme peut sembler réservée aux joueurs et aux geeks.
En pratique, c'est plutôt un marché de collection moderne: rareté, liquidité, spéculation, arbitrage.
Autrement dit, on est beaucoup plus proche d'une logique "monde réel" que d'un simple mini-jeu.

> Steam Market n'est pas qu'un lieu d'échange d'objets virtuels: c'est un laboratoire grandeur nature pour l'ingénierie data.
{: .prompt-info }

---

## Pourquoi ce marché est intéressant

Steam Market fonctionne comme une place de marché mondiale :

- les prix bougent en continu,
- les acheteurs et vendeurs sont des utilisateurs réels,
- plusieurs monnaies coexistent,
- les fuseaux horaires changent les rythmes de trafic,
- via des plateformes secondaires, certains objets virtuels peuvent être monétisés.

Ce n'est donc **pas** un dataset statique.
Valve a même exploité très tôt des mécaniques proches des actifs numériques "rares": certains objets ont une forte valeur de collection, parfois liée à leur disponibilité limitée.
Avec des millions d'utilisateurs actifs, l'échelle devient vite massive.

*Exemple de valorisation du marché CS2 :*
![Exemple de valorisation du marché des objets CS2](img/steam/cs2_market_cap.png){: .shadow }

C'est un environnement vivant, parfait pour tester des hypothèses de collecte et de qualité de données.

---

## Un point historique utile

On comprend encore mieux le sujet en regardant l'histoire du service.

Valve a recruté en 2012 l'économiste Yanis Varoufakis comme *Economist-In-Residence* pour analyser les économies virtuelles liées à Steam.

> "Yanis Varoufakis is an academic economist, an author..."
> Né à Athènes (1961), formé en mathématiques, statistiques et économie (PhD, University of Essex), il a enseigné dans plusieurs universités majeures en Europe et en Australie.
> Cette trajectoire académique explique pourquoi son passage chez Valve a été pris au sérieux bien au-delà du monde du jeu.
{: .prompt-info }

Dès 2013, le *Financial Times* évoquait déjà la réalité économique des marchés virtuels du jeu vidéo.
![Financial Times - économie des jeux vidéo](img/steam/ft.png){: .shadow }

Même si l'article est ancien, il reste utile pour comprendre pourquoi ce sujet dépasse largement le simple divertissement.

> Franchement, de quoi parle-t-on encore ?
> Quand, pour suivre cette plateforme, il faut lire des journaux comme le *Financial Times* et *Forbes*, l'argument est déjà pratiquement clos.
{: .prompt-tip }

- [Financial Times (archive)](https://archive.is/20230729204017/https://www.ft.com/content/151b8794-750f-11e2-a9f3-00144feabdc0)

Il deviendra ensuite ministre des Finances de la Grèce en 2015.

Références complémentaires :
![Blog de Yanis Varoufakis sur Valveconomics](img/steam/yanis_blog.png){: .shadow }

- [Introducing Valveconomics](https://www.yanisvaroufakis.eu/2012/06/22/introducing-valveconomics-my-new-blog-with-research-notes-on-digital-economies/)
- [Interview on becoming Economist-In-Residence at Valve](https://www.yanisvaroufakis.eu/2012/07/11/interviewed-by-doug-henwood-on-my-new-position-as-economist-in-residence-at-valve-software/)
- [Valveconomics (archive Web, 2020)](https://web.archive.org/web/20200210025523/http://blogs.valvesoftware.com/economics)

Le blog historique Valveconomics est aujourd'hui partiellement indisponible selon les pages et la zone d'accès.
![Exemple de page inaccessible](img/steam/access_denied.png){: .shadow }

> Les archives web restent donc essentielles pour documenter l'historique technique et économique du sujet.
{: .prompt-warning }

---

## Ce que Steam Market apprend côté ingénierie

Pour un scraper, Steam Market est une bonne "salle de sport" :

- il faut gérer la variabilité de prix et de disponibilité,
- il faut gérer plusieurs devises et intégrer des conversions fiables pour suivre la liquidité réelle,
- il faut suivre les effets de volume et de volatilité: une simple mise à jour peut provoquer des mouvements très brutaux.

Par exemple, après une mise à jour de Valve, la communauté CS2 a connu une forte turbulence sur la valorisation des skins.

> "The Counter-Strike 2 community has been thrown into turmoil..."  
> Source: [Forbes (archive)](https://web.archive.org/web/20251204062315/https://www.forbes.com/sites/danidiplacido/2025/10/23/the-counter-strike-2-skins-market-crash-explained/)

- il faut travailler avec des endpoints parfois anciens et une API qui évolue lentement.
- l'écosystème repose aussi sur beaucoup de code legacy: cela complique l'automatisation, mais c'est très formateur.

![Exemple de code legacy visible côté client](img/steam/codestyle.webp ){: .shadow }

- il faut distinguer les erreurs de blocage, de quota, de latence et de données.

Et surtout, la "bonne" architecture ne dépend pas seulement du code, mais aussi du **coût d'acquisition de la donnée**.
Si vous aimez les jeux, la boucle d'apprentissage est encore plus motivante.

---

## Pourquoi je continue à l'utiliser comme terrain de test

Sur ce type de marché, on peut progresser en même temps sur :

- la **robustesse de la collecte** (volumes énormes, objets très hétérogènes),
- l'**observabilité** (*logs*, erreurs, retries, délais) pour piloter à la fois le scraper et l'infrastructure,
- l'**analyse économique** (offre, demande, spreads, dérives), qui reste un terrain complexe.

![Exemple de complexité économique](img/steam/economy_forest.jpg ){: .shadow }

- la **discipline produit**: quelles données valent réellement leur coût d'acquisition ?

Mon objectif personnel est de passer vite de l'état "*j'apprends*" à l'état "*j'applique*".
Un résultat positif (ici, des opérations réellement exécutables) motive bien plus qu'un simple `Hello, World`.

En bref, Steam Market reste un excellent bac à sable pour renforcer à la fois la partie technique et la partie décisionnelle.

![Bac à sable d'expérimentation](img/steam/sandbox.png ){: .shadow }

Bonus concret : certaines stratégies bien maîtrisées permettent aussi de générer un gain réel, car beaucoup d'objets sont monétisés sur des marchés secondaires[^money].

> Ce potentiel existe, mais il faut toujours respecter les règles de la plateforme, la fiscalité locale et le niveau de risque accepté.
{: .prompt-danger }

---

## Respect pour l'écosystème

Cette approche est aussi une façon de saluer le travail des équipes Steam et de sa communauté :
sans cet écosystème, beaucoup d'expérimentations data ne seraient pas aussi formatrices.

[^money]: Le niveau de revenu dépend fortement de la liquidité des objets, des frais de transaction, des écarts de prix et de la volatilité du marché.
