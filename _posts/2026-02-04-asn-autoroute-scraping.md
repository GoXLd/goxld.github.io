---
title: ASN — l'autoroute du scraping
description: Comment j'ai réduit mes coûts de proxy de 68$ à 5.50$ par mois en analysant les ASN et en automatisant la qualité.
date: 2026-02-04
tags: [scraping, proxy, asn, reseau, automatisation]
author: GoXLd
pin: false
toc: false
published: true
image:
  path: img/asn/asn.jpg
  lqip: data:image/jpeg;base64,/9j/4QDKRXhpZgAATU0AKgAAAAgABgESAAMAAAABAAEAAAEaAAUAAAABAAAAVgEbAAUAAAABAAAAXgEoAAMAAAABAAIAAAITAAMAAAABAAEAAIdpAAQAAAABAAAAZgAAAAAAAABIAAAAAQAAAEgAAAABAAeQAAAHAAAABDAyMjGRAQAHAAAABAECAwCgAAAHAAAABDAxMDCgAQADAAAAAQABAACgAgAEAAAAAQAAABOgAwAEAAAAAQAAAAqkBgADAAAAAQAAAAAAAAAAAAD/2wCEAAEBAQEBAQIBAQIDAgICAwQDAwMDBAUEBAQEBAUGBQUFBQUFBgYGBgYGBgYHBwcHBwcICAgICAkJCQkJCQkJCQkBAQEBAgICBAICBAkGBQYJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCf/dAAQAAv/AABEIAAoAEwMBIgACEQEDEQH/xAGiAAABBQEBAQEBAQAAAAAAAAAAAQIDBAUGBwgJCgsQAAIBAwMCBAMFBQQEAAABfQECAwAEEQUSITFBBhNRYQcicRQygZGhCCNCscEVUtHwJDNicoIJChYXGBkaJSYnKCkqNDU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6g4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2drh4uPk5ebn6Onq8fLz9PX29/j5+gEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoLEQACAQIEBAMEBwUEBAABAncAAQIDEQQFITEGEkFRB2FxEyIygQgUQpGhscEJIzNS8BVictEKFiQ04SXxFxgZGiYnKCkqNTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqCg4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2dri4+Tl5ufo6ery8/T19vf4+fr/2gAMAwEAAhEDEQA/AP0W+FExXW9G8J+N7u10mKPTriS9uJZhE0bxwL5TGVz8mZZUDKBt4AIHUY/7Zlv8JPAHwCvvihqi3f8AaFpc2Bitllsbq8Ed2Yo03wybYSquWeceeVCEMhZdor5q8SgW3izWdKth5drvmTyV4j2+VaDbtHGMMwxjufWuW8eeD/CUfi34YXsel2izano0Ed44gjDXCG2dysp25cF/mw2RnnrX5dgvZRs5R/q1z+gpU6nt41VNpK2npqfC5+D2q6skeq6LqdubS5jjliyTFhXUMBslO/5c4yc5xkEgg03/AIUd4o/6CNt/3+T/ABrxDxcq6h4p1C6vwJ5TcSKXk+ZsKdqjJ7AAAegGK537BY/88Y/++R/hX6BSjLlWv4HymNT9tL1Z/9k=
ads: true
---
# ASN — l'autoroute du scraping

## Comment j'ai réduit mes coûts de proxy par 10 et arrêté de me battre avec les 429

En informatique, beaucoup de problèmes deviennent plus simples quand on trouve une bonne analogie dans le monde réel. Pour moi, cette analogie a été l'autoroute pour l'ASN.

Ces derniers mois, j'ai réussi à réduire mes coûts de proxy de **68$ à 5,50$ par mois**, sans perte de qualité de données.

![Webshare](img/asn/forfait_webshare.png){: .shadow }

> Le chiffre est volontairement marquant, mais le point important est la méthode.
> Oui, passer directement sur du proxy résidentiel premium (ou d'autre service par exemple Bright Data) peut souvent augmenter le taux de succès plus vite[^residential].
> Mais ce confort a un coût élevé et masque la cause réelle des erreurs.
> Ici, je partage surtout une synthèse de trois mois d'ajustements sur plusieurs pools mondiaux pour garder la performance sans dépendre uniquement du budget.
> Dans la pratique, beaucoup de solutions "scraper-as-a-service" restent coûteuses et peu fiables sur des cibles spécifiques (par exemple Leboncoin ou Steam Market), d'où l'intérêt de construire une chaîne adaptée à son propre cas d'usage.
{: .prompt-info }

Dans cet article, j'explique comment et pourquoi cela a fonctionné.
---

## Comment tout a commencé

Pour le contexte métier derrière mes tests, j'ai aussi publié un article dédié :
[Pourquoi Steam Market est un excellent terrain d'apprentissage]({% post_url 2026-02-14-pourquoi-steam-market %}).

J'ai travaillé presque en continu sur mon propre scraper. Je ne partais pas totalement de zéro : j'avais déjà des scripts Google Apps Script (`.gs`) en production.
`gXd.node/scripts`
{: .filepath}
![Terminal Logs - local.node - scripts](img/asn/parsing_terminal.webp){: .shadow }
Mais avec le temps, le taux de succès de `urlFetch` pouvait tomber vers 15 % sur certaines cibles, ce qui devenait critique.
Même avec une limite quotidienne théorique élevée (souvent citée autour de 20k requêtes/jour[^urlfetch]), les limites réelles d'usage restent plus complexes. 
En pratique, sur mon scénario, j'ai constaté une zone de stabilité autour de **10k requêtes/jour** avec `urlFetch`, mais ce seuil reste dynamique :
en augmentant la fréquence, il m'est déjà arrivé de voir des erreurs apparaître avant ce volume.

![Exemple de limitation Apps Script](img/asn/appscript_limits.webp){: .shadow }


J'ai donc progressivement complexifié l'architecture.

Avant, tout était simple :

- ajouter du jitter,
- limiter la fréquence,
- activer la rotation d'IP,
- changer de pays.

Mais ces dernières années, les backends des grands services se sont beaucoup complexifiés. Les méthodes simples ont cessé de fonctionner.

Les erreurs **429** ont commencé à apparaître même avec une charge prudente.

> Je ne dépassais pourtant jamais 1 requête/seconde et je n'utilisais pas de multi-thread agressif.
> En moyenne, chaque script restait autour de 1 requête/minute vers le service cible.
> Le reste du trafic passait sur des canaux prioritaires (API internes, base de données, services système), donc hors du flux de scraping classique.
{: .prompt-danger }

---

## Ma base de défense

Au moment des tests, j'avais déjà un système assez élaboré :

- pas plus d'une requête par seconde sur 100+ proxys,
- timing dynamique + jitter à 15 %
```js
function withJitter(baseDelayMs = 1000, jitterPercent = 0.15) {
  const delta = baseDelayMs * jitterPercent;
  return Math.round(baseDelayMs + (Math.random() * 2 - 1) * delta);
}
```
{: file="scripts/jitter.js"}

- changement automatique d'adresses
```js
class ProxyRotator {
  constructor(proxies) {
    this.proxies = proxies;
    this.index = 0;
  }

  next() {
    const proxy = this.proxies[this.index % this.proxies.length];
    this.index += 1;
    return proxy;
  }
}
```
{: file="scripts/proxy-rotator.js"}

- chaine de repli : Google → Proxy → Node
La logique est volontairement progressive :
on tente d'abord les adresses Google (meilleure latence/coût),
puis on passe sur les proxys rotatifs,
et enfin sur des instances IPv4 dédiées (pool privé utilisé uniquement par moi) quand la cible devient trop restrictive.

![Taux de succès par chaîne AppScript -> Proxy -> Node](img/asn/success_rate_appscript_proxy_node.webp){: .shadow }
- serveurs propres dans plusieurs datacenters avec des IPv4 "propres"
Logs sur le serveur gXd.node
`gXd.node/logs/scraper-traffic.log`
{: .filepath}
![Webshare](img/asn/logs.webp){: .shadow }
- système de rotation "Feu tricolore",
- émulation de différents appareils et navigateurs.

Extraits simplifiés de la logique (version pédagogique) :


```js
async function fetchWithFallback(request) {
  try {
    return await fetchViaGoogle(request);
  } catch {
    try {
      return await fetchViaProxy(request);
    } catch {
      return await fetchViaNode(request);
    }
  }
}
```
{: file="scripts/fetch-with-fallback.js"}

Sur le papier, tout était correct.
Mais les résultats variaient toujours fortement selon le pays et selon les pools.

---

## Une observation étrange

Avec le temps, j'ai remarqué une régularité intéressante.

Dans un même pays, différents proxys affichaient :

- 90 % de taux de succès,
- 70 %,
- parfois moins de 50 %.

La capture ci-dessous confirme l'idée : à pays égal, le taux de réussite varie fortement selon l'ASN.

![Différences de réussite par ASN](img/asn/be_replaced_ips.webp){: .shadow }

On remarque aussi que l'ASN "faible" a moins de requêtes.
Ce n'est pas un biais de mesure : c'est l'effet direct de l'optimisation.

Dès qu'un proxy montre une dérive (429, timeout, latence instable), il est remplacé rapidement.
L'objectif n'est pas d'accumuler 1000 échecs sur un proxy mort, mais de couper la perte le plus tôt possible.

Le seuil de remplacement reste volontairement individuel : il dépend du coût du pool, de la tolérance aux erreurs et du rythme de collecte.

Pourtant :

- la charge était identique,
- le comportement identique,
- le timing identique.

La différence se résumait à un seul paramètre : **l'ASN**.

> Quand des IP différentes d'un même pays chutent en même temps, le signal "ASN" devient plus fiable que le signal "IP".
{: .prompt-tip }

---

## Hypothèse : les limites ne sont pas par IP, mais par ASN

Une hypothèse s'est imposée :

Les services modernes limitent de plus en plus non pas les IP isolées, mais des **systèmes autonomes entiers (ASN)**.

La logique est simple :

Si un ASN contient beaucoup d'activité suspecte, il est plus simple de ralentir tout le bloc que de filtrer adresse par adresse.

Conséquences :

- même des IP "propres" commencent à recevoir des 429,
- le taux de succès baisse,
- les coûts augmentent.

Si, dans le même ASN, quelqu'un d'autre fait du scraping agressif, vous en subissez les effets.

---

## Comment je l'ai vérifié

J'ai commencé à collecter des statistiques par ASN :

- taux de succès,
- nombre de 429,
- temps de dégradation,
- récupération.

Après quelques semaines, une tendance claire est apparue :

- dès qu'un ASN "décroche",
- tous les IP en son sein chutent,
- changer d'adresse n'aide pas,
- changer d'ASN aide.

Ce n'est pas une preuve formelle, mais la corrélation était trop stable pour être un hasard.

---

## Le système "Feu tricolore"

Pour automatiser la qualité des proxys, j'ai mis en place un système "Feu tricolore".
Le principe est simple, comme en logistique.

**Vert**

L'adresse est stable.
Le taux de succès dépasse le seuil.

→ Utilisée activement.

**Jaune**

10 erreurs d'affilée.

→ L'adresse part "se reposer" quelques heures.

**Rouge**

Après récupération, nouvelle série d'erreurs.

→ Exclusion complète du pool.

---

## Pourquoi c'est utile

Imaginons :

- un proxy a 99 % de réussite,
- puis il se dégrade,
- à cause de la rotation, le système ne le remarque que plusieurs jours après.

Pendant ce temps, des milliers de requêtes partent dans le vide, avec un coût réel.

Le "Feu tricolore" permet de filtrer les mauvaises adresses en quelques heures, pas en semaines.

---

## Le rôle de l'ASN dans le "Feu tricolore"

Avec le temps, j'ai ajouté un niveau d'agrégation :

Adresse → ASN → Pool.

Si plusieurs IP d'un même ASN commencent à générer des erreurs, la priorité de toute la plage baisse.

En pratique, le système apprend à éviter les autoroutes problématiques.

---

## Résultat

Après l'intégration de l'analyse ASN et du "Feu tricolore" :

- les 429 ont diminué plusieurs fois,
- le taux de succès a augmenté,
- les proxys sont utilisés plus efficacement,
- une partie des pools a été entièrement remplacée.

Résultat financier :

| Période | Dépenses |
| ------ | -------- |
| Avant  | 68 $     |
| Après  | 5,50 $   |

Pour la même charge.

---

## Pourquoi l'analogie routière fonctionne

Un ASN, c'est une autoroute.

- Les IP sont les voitures.
- Les proxys sont les conducteurs.
- Le trafic est la marchandise.

On peut changer de voitures, mais si la route est saturée, on reste bloqué.

J'ai arrêté de me battre avec les voitures individuelles et j'ai commencé à choisir les routes.

---

## Conclusion

Le point central est simple :

En 2025, lutter contre les blocages seulement au niveau IP n'a plus de sens.

Il faut travailler :

- avec les ASN,
- avec la réputation des réseaux,
- avec la dégradation dynamique,
- avec un contrôle qualité automatique.

Sinon, on brûle simplement son budget.

---

## Ce que vous pouvez faire dès maintenant

Si vous faites du scraping :

1. Commencez à loguer les ASN.
2. Comparez le taux de succès par plages.
3. Désactivez les réseaux problématiques en bloc.
4. Automatisez la sélection.
5. Ne faites pas confiance aux pools "bon marché" sans statistiques.

Cela se rentabilise très vite.

---

## En guise de conclusion

Avant, je payais 68 $ pour des données instables.
Aujourd'hui, 5,50 $ pour un résultat prévisible.

Tout ça pour un seul paramètre que j'ignorais : l'ASN.

[^residential]: Les proxys résidentiels premium améliorent souvent la délivrabilité, mais leur coût mensuel peut vite dépasser celui d'une optimisation technique sur ASN.
[^urlfetch]: La limite "20k/jour" est une référence fréquente selon les configurations, mais la limite utile dépend aussi du type de script, de la cible et des quotas réellement appliqués.
