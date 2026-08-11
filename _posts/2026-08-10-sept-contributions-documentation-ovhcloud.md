---
title: Sept contributions acceptées dans la documentation OVHcloud
description: Comment j'ai transformé sept défauts vérifiables en corrections acceptées par OVHcloud, de l'accessibilité du thème aux commandes Docker, OpenStack et Node.js.
date: 2026-08-10
categories: [DevOps]
tags: [devops, open-source, documentation, accessibilite, docker, nodejs, openstack]
author: GoXLd
pin: false
toc: true
published: true
ads: true
mermaid: false
media_subpath: /img/ovhcloud-contributions/
image:
  path: cover.png
language: fr-FR
translation_key: sept-contributions-documentation-ovhcloud
---

# Sept corrections OVHcloud : prouver d'abord, proposer ensuite

Bonjour à tous !

À la fin de juillet, je me suis donné un objectif simple : contribuer à la documentation publique d'OVHcloud sans fabriquer de travail pour remplir un profil GitHub. Pas de quota quotidien de pull requests, pas de correction cosmétique présentée comme un incident majeur. Je voulais trouver des défauts techniques que je pouvais démontrer avec des sources officielles, corriger dans mon domaine de compétence et vérifier avant de solliciter les mainteneurs.

Le premier cycle est maintenant terminé : **sept ensembles de corrections ont été acceptés**, dont quatre directement depuis mes pull requests et trois après migration vers des branches internes au dépôt. Ils couvrent **55 fichiers** et sept langues, avec des changements allant de l'accessibilité React à Apache, Docker Compose, OpenStack et Node.js.

> En une phrase : sept contributions acceptées, 55 fichiers corrigés, quatre merges directs et trois migrations internes — avec une règle constante : une preuve reproductible avant chaque modification.
{: .prompt-info }

<!-- TODO: créer une couverture montrant les sept PR acceptées sans informations privées. -->

## Le point de départ

Le dépôt `ovh/ovhcloud-docs` n'est pas une simple collection de pages Markdown. Il contient les guides publiés dans plusieurs langues, mais aussi le thème React du site, les scripts de génération et les contrôles de contenu. Une correction apparemment minuscule peut donc toucher sept variantes linguistiques ou modifier le comportement clavier de plusieurs layouts.

| Zone | État observé avant correction |
|---|---|
| Filtres de recherche | regroupement visuel sans élément HTML sémantique natif |
| Navigation latérale | une touche sans rapport pouvait fermer le panneau ; `Enter` ou `Space` pouvait provoquer une `TypeError` |
| Exemples Apache | un `Require not host` négatif sans fournisseur positif dans `RequireAll` |
| Guides OpenStack | liens vers Newton EOL et commande `nova boot` dépréciée |
| Tutoriel WordPress | mélange de Docker Compose v1 et v2, avec un champ `version` obsolète |
| Guide Lovable | installation de Node.js 18 après sa fin de vie |

Le but n'était pas de chercher des fautes au hasard. Je me suis limité aux domaines que je pouvais défendre publiquement : JavaScript et TypeScript, Shell, commandes d'infrastructure, documentation technique et accessibilité web.

## La méthode : l'autorité avant l'intuition

Pour chaque candidat, j'ai suivi la même boucle : chercher le défaut dans la branche courante, vérifier toutes ses copies, consulter la documentation officielle du produit concerné, rechercher les issues et pull requests similaires, puis construire un invariant mesurable avant/après.

>Mes règles non négociables :
>1. **Pas de PR sans effet concret** — une commande obsolète, un comportement clavier cassé ou une contradiction avec une spécification officielle.
>2. **Pas de supposition produit** — si un comportement nécessite un accès privé à OVHcloud Manager, je ne le présente pas comme un bug vérifié.
>3. **Toutes les variantes concernées** — quand un guide existe en sept langues, je contrôle les sept fichiers et leurs relations de fallback.
>4. **Validation proportionnée** — tests et navigateur pour le thème ; lint, parsing et invariants exacts pour les guides.
{: .prompt-danger }

Cette méthode évite deux pièges opposés : lancer une compilation multi-locale coûteuse pour une simple URL, ou considérer qu'une modification de commande est correcte parce qu'elle « ressemble » à la syntaxe actuelle.

## Accessibilité : deux défauts dans le thème React

La première contribution acceptée, [PR #473](https://github.com/ovh/ovhcloud-docs/pull/473), remplace les wrappers génériques des filtres Pagefind par des éléments `fieldset`. Le changement tient dans deux fichiers : quatre ajouts CSS, puis quatre ajouts et six suppressions dans le composant React. L'objectif n'était pas de modifier le rendu, mais de donner aux technologies d'assistance un regroupement natif.

La vérification a combiné Biome, les tests du projet, les contrôles de contenu et de sidebar, les sept sorties locales, puis une comparaison navigateur des dimensions calculées avant/après. Le commit final a été fusionné en conservant mon commit original comme parent du merge.

La [PR #474](https://github.com/ovh/ovhcloud-docs/pull/474) concernait un défaut plus visible. Cinq boutons natifs fermaient la sidebar sur n'importe quel `keyup`. En parallèle, un groupe personnalisé `div[role="button"]` appelait un handler de souris sans lui transmettre d'événement. Le handler tentait ensuite d'exécuter `stopPropagation()` sur `undefined`.

La reproduction navigateur était déterministe : avant le patch, `Enter` produisait une `TypeError` et le groupe restait fermé. Après le patch, `Enter` l'ouvre, `Space` le referme sans faire défiler la page, une touche comme `A` ne ferme plus le panneau et le clic sur le masque reste fonctionnel. Sept fichiers du thème ont été corrigés, puis la contribution a été fusionnée avec mon attribution.

## Apache : une négation qui n'autorisait personne

Dans les guides de blocage par domaine, le même exemple apparaissait dans sept langues :

```apache
<RequireAll>
  Require not host domain.tld
</RequireAll>
```

La documentation Apache 2.4 précise qu'une directive `Require` négative ne peut pas autoriser seule une requête et que `RequireAll` a besoin d'au moins un fournisseur positif. Pour exprimer « autoriser tout le monde sauf ce domaine », il manquait donc `Require all granted`.

La [PR #481](https://github.com/ovh/ovhcloud-docs/pull/481) a corrigé **14 blocs** dans sept fichiers. Mon invariant est passé de 0/14 à 14/14 blocs contenant le fournisseur positif immédiatement avant `Require not host`. Après approbation, le changement a été migré vers la [PR interne #545](https://github.com/ovh/ovhcloud-docs/pull/545), puis fusionné avec un trailer `Co-authored-by` préservant mon attribution.

## OpenStack : sortir de Newton et de `nova boot`

Deux contributions distinctes ont traité le même problème de fond : des guides actuels renvoyaient encore vers des outils historiques.

La [PR #482](https://github.com/ovh/ovhcloud-docs/pull/482) a remplacé **18 liens** vers la documentation OpenStack Newton de 2016 par le guide OVHcloud actuel de préparation de l'environnement OpenStack. L'ancienne page recommandait encore Python 2.7, `easy_install` et un client ne prenant pas en charge Python 3. Le remplacement utilise Python 3, un environnement virtuel et `python-openstackclient`. La correction a été fusionnée via la [PR #515](https://github.com/ovh/ovhcloud-docs/pull/515).

La [PR #493](https://github.com/ovh/ovhcloud-docs/pull/493) a ensuite remplacé `nova boot` par `openstack server create` dans sept variantes du guide de lancement de script à la création d'une instance. Elle corrige aussi `--key_name` en `--key-name` et une variante mal formée de `--user-data`. La syntaxe a été comparée à la référence actuelle d'OpenStackClient, sans prétendre avoir exécuté une création d'instance réelle : le CLI et un cloud de test n'étaient pas disponibles localement. Le patch a été fusionné via la [PR #516](https://github.com/ovh/ovhcloud-docs/pull/516).

## Docker Compose : rendre le tutoriel cohérent

Le tutoriel WordPress installait Docker Compose 1.29.2 comme binaire autonome, puis mélangeait `docker-compose` et `docker compose`. Sur une machine propre, les paquets indiqués ne fournissaient pas nécessairement le plugin attendu par les commandes v2 du même guide.

La [PR #483](https://github.com/ovh/ovhcloud-docs/pull/483) a migré les sept variantes vers le paquet `docker-compose-plugin`, supprimé le téléchargement standalone, normalisé les commandes v2 et retiré le champ Compose `version`, désormais obsolète.

J'ai extrait et parsé **14 fragments YAML**, contrôlé la structure des services `db` et `wordpress`, puis vérifié l'absence du binaire legacy, de l'ancienne URL et du champ obsolète. Docker n'était pas installé sur la machine de validation : je n'ai donc pas présenté ce travail comme un test runtime de conteneurs. Le mainteneur a confirmé en review que le patch corrigeait la dépendance cassée à Compose v1 et nettoyait les commandes dans toutes les langues avant de l'approuver.

## Node.js : remplacer une LTS arrivée en fin de vie

La [PR #496](https://github.com/ovh/ovhcloud-docs/pull/496) est la plus petite par son diff : deux lignes modifiées dans chacune des sept langues. Le guide d'import d'un site Lovable utilisait le script NodeSource `setup_18.x`, alors que Node.js 18 avait atteint sa fin de vie le 27 mars 2025.

Le remplacement par `setup_24.x` a été vérifié dans les sept fichiers, ainsi que sur l'endpoint NodeSource. Le mainteneur a explicitement validé l'intérêt de la mise à jour : les lecteurs installent désormais une version LTS supportée plutôt qu'un runtime ne recevant plus de correctifs upstream.

## La partie honnête : le code n'était pas toujours le blocage

Trois contributions n'ont pas été fusionnées depuis mes branches de fork. Le système CDS interne ne se déclenchait pas correctement sur celles-ci ; les mainteneurs ont donc recréé les changements sur des branches du dépôt principal. Les PR originales #481, #482 et #493 apparaissent comme fermées, mais leurs remplacements #545, #515 et #516 sont bien fusionnés.

Cette distinction compte : une PR fermée n'est pas nécessairement refusée, et une approbation n'est pas encore un merge. Pour suivre une contribution externe correctement, il faut remonter les liens de remplacement jusqu'au commit final.

Le premier transfert m'a aussi appris une leçon sur l'attribution. Le commit final de #516 ne conservait ni mon auteur original ni un trailer `Co-authored-by`. La mainteneuse a expliqué avoir retiré le trailer par prudence envers une adresse personnelle déjà publique dans les commits, sans réaliser que cela supprimait aussi le crédit GitHub. Réécrire l'historique partagé n'était pas raisonnable. Depuis, j'ajoute une demande d'attribution dans chaque PR susceptible d'être migrée ; les merges suivants ont conservé mon commit original ou un trailer de co-auteur.

> Le résultat technique et son attribution sont deux contrôles différents. Une fois le patch fusionné, je vérifie le commit final — pas seulement le badge « Merged » de la PR originale.
{: .prompt-warning }

## Résultats

| Contribution | Périmètre | Résultat upstream |
|---|---:|---|
| [#473](https://github.com/ovh/ovhcloud-docs/pull/473) — filtres sémantiques | 2 fichiers | merge direct |
| [#474](https://github.com/ovh/ovhcloud-docs/pull/474) — clavier de la sidebar | 7 fichiers | merge direct |
| [#481](https://github.com/ovh/ovhcloud-docs/pull/481) → [#545](https://github.com/ovh/ovhcloud-docs/pull/545) — Apache | 7 fichiers | migration interne, merge |
| [#482](https://github.com/ovh/ovhcloud-docs/pull/482) → [#515](https://github.com/ovh/ovhcloud-docs/pull/515) — liens OpenStack | 18 fichiers | migration interne, merge |
| [#483](https://github.com/ovh/ovhcloud-docs/pull/483) — Docker Compose v2 | 7 fichiers | merge direct, approved |
| [#493](https://github.com/ovh/ovhcloud-docs/pull/493) → [#516](https://github.com/ovh/ovhcloud-docs/pull/516) — commande OpenStack | 7 fichiers | migration interne, merge |
| [#496](https://github.com/ovh/ovhcloud-docs/pull/496) — Node.js 24 LTS | 7 fichiers | merge direct, approved |
| **Total** | **55 fichiers** | **7 corrections acceptées** |

Sur les diffs originaux, ce cycle représente **157 additions et 246 suppressions**. Ces chiffres décrivent le périmètre Git, pas une mesure de valeur : la correction Node.js ne change que 14 lignes au total, mais évite de recommander un runtime EOL ; les deux fichiers de #473 ont un impact direct sur la sémantique du moteur de recherche.

## Ce que je retiens

Contribuer à une documentation technique sérieuse ressemble moins à « corriger du texte » qu'à une petite enquête d'ingénierie. Il faut distinguer une page simplement ancienne d'une instruction réellement dangereuse, une préférence stylistique d'une contradiction avec la documentation officielle, et une vérification ciblée d'un test runtime que l'on n'a pas exécuté.

Le point le plus utile n'est pas le nombre de PR. C'est la méthode qui permet de dire non à une idée insuffisamment prouvée, puis de défendre précisément celle que l'on soumet : source upstream, portée complète, invariant avant/après et limites de validation explicites.

Ce premier cycle est accepté, mais le travail continue. Trois autres contributions restent ouvertes ; elles ne feront partie d'un bilan que si elles atteignent réellement la branche upstream. La question n'est donc plus « combien de PR puis-je ouvrir ? », mais **« quelle amélioration puis-je prouver sans demander au mainteneur de me croire sur parole ? »**
