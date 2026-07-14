---
title: Mon HomeLab v3 - philosophie, architecture et performance silencieuse
description: Présentation complète de ma troisième version de HomeLab - un cluster silencieux, économe et performant, avec 150 Go de RAM, 3,64 To NVMe en RAID 5 et une gestion d’énergie optimisée.
date: 2025-10-08
tags: [homelab, serveur, amd, cluster, nas]
author: GoXLd
pin: false
toc: false
published: true
media_subpath: /img/homelab/
image:
  path: homelab-titre.jpg
  lqip: data:image/webp;base64,UklGRpoAAABXRUJQVlA4II4AAAAQBACdASoZAA4APp0+mUgloyKhMAgAsBOJYwCdB3gAitvRg4/eJyjjgAD+ympIJ+nn1Zk4QcwG6LzPjtQAM13ha5uRNhmU525b0LJ81vRBdamKIpg7GdbtYYWmtb+m2jYNC7ZDq5XNyrDe+zyVQgyXaO+LMND2MTM02E88QfU2sYZz5PP34g2irOG54AAA
ads: true
language: fr-FR
translation_key: homelab-concept
---

# Mon HomeLab v3 : performance et silence

Bonjour à tous !
Aujourd’hui, je vous présente la **troisième version** de mon **HomeLab** — un projet à la fois technique et personnel, qui reflète ma philosophie et mon approche de l’informatique domestique.

![Homelab main photo](homelab.jpg){: .shadow }

## UPDATE - fevrier 2026

Après plus de **90 jours** de fonctionnement continu, le lab reste **stable**, sans problème ni interruption.

![Uptime du HomeLab](uptime.png){: .shadow }

Actuellement, un seul serveur est allumé : le **node1 (Ryzen 7 7730U, 64 Go RAM)**.  
Les autres nœuds sont éteints pour économiser l’énergie, et cette machine suffit largement pour tous mes conteneurs et mes VM.

Début **décembre 2025**, j’ai coupé `node2` et `node3` pour mesurer l’impact énergétique, car la consommation avait dépassé **30 kWh/mois**.  
Après optimisation, seuls restent actifs : les deux switches, le serveur principal, le KVM, les capteurs d’air et les ventilateurs du rack.

![Consommation décembre 2025 / janvier 2026](consommation.jpg){: .shadow }

En **janvier 2026**, on voit clairement que la consommation reste sous **20 kWh/mois**, malgré une utilisation plus active du lab.




## Philosophie du projet

>Avant de parler technique, je veux partager mes priorités dans la conception d’un HomeLab :
1. **Silence absolu** — un serveur domestique ne doit pas ressembler à un mini data center.  
2. **Performance par watt** — un hyperviseur actif 24/7 ne doit pas exploser la facture d’électricité.  
3. **Rapport qualité/prix** — choisir des composants cohérents, pas forcément les plus/moins chers.
{: .prompt-danger }
Ce projet n’est pas un tutoriel, mais un **échange d’expérience** et une **invitation à la discussion** pour tous ceux qui construisent leur propre infrastructure à la maison.

## Les versions précédentes de la HomeLab

Pourquoi « version 3 » ?  
Parce qu’avant d’arriver à cette configuration, j’ai expérimenté deux itérations.

### Version 1 : la découverte
Un simple **mini-PC basé sur un processeur AMD x86**.  
Pourquoi AMD ?  
Parce qu’à l’époque, **Intel ne proposait pas encore de processeurs à petit nœud gravure** (4 nm pour le 8845HS contre beaucoup plus pour ses équivalents Intel).  
Résultat : pour seulement 45 W, j’obtiens **28 000 points CPU Mark**, contre 6 000 pour un Intel à 6 W.

J’ai souvent vu des vidéos où des créateurs montent un « cluster » sur des N100 en vantant leur faible consommation… mais incapables de supporter une charge réelle.  
Mon conseil : cherchez **le meilleur rendement énergétique CPU Mark par Watt** , pas seulement le chiffre sur la prise.

![AE8 Geekom - mon premier mini PC](AE8_geekom.jpg){: .shadow }
> Ainsi, vous pouvez remarquer que le mini PC ne possède qu’une seule interface Ethernet. Mais même s’il y en a trois ou quatre, il faut regarder **lesquelles**. Je ne soulèverais pas ce sujet sans raison, mais j’ai très souvent constaté, sur presque tous les mini PC que j’ai testés, l’impossibilité de les “réveiller” depuis l’état S5 à l’aide d’un paquet magique (Magic Packet). 
{: .prompt-info }

### Version 2 : le NAS et les limites du Synology

J’ai ensuite testé un stockage partagé basé sur **Synology**.  
Leur UI est superbe, mais les performances **I/O** pas terrible, surtout pour le prix.  
J’ai donc opté pour un **Beelink compact**, bien plus rapide, où le **goulot d’étranglement est le réseau**, pas le CPU ou les disques.

Synology reste top pour les **sauvegardes**, mais pour les performances brutes, Beelink l’emporte largement.

## L’infrastructure actuelle : HomeLab v3

Le cœur de cette version repose sur trois mini-PC formant un **cluster performant et modulaire**.

### Spécifications générales

- **CPU total** : 74 989 points CPU Mark  
- **RAM** : 150 Go  
- **Stockage NAS** : RAID 5 NVMe 3,64 To (jusqu’à 5 Gb/s par lien données, 2,5 Gb/s vers les serveurs)  
- **Réseau** : double commutateur configurable (switch principal + extension Gigabit)  
- **Refroidissement** : système silencieux à flux d’air dirigé  
- **Équipements annexes** : KVM over IP, Raspberry Pi 5, capteurs de température et de consommation.

<!-- 📸 Отдельное фото Raspberry Pi 5 с экраном Zabbix -->

## Les serveurs

Avant de présenter en détail la configuration interne, je précise que j’utilise un **GeeekPi 8U Server Rack DeskPi RackMate T1**, un châssis rackmount conçu pour les mini-serveurs et équipements réseau, avec une structure en alliage d’aluminium et panneau acrylique.

![AE8 Geekom - mon premier mini PC](rackmate.png){: .shadow }

Voici la composition du cluster :

1. **Bleu** : Topton Mini PC fanless, Ryzen 7 7730U, 64 Go DDR4, SSD 1 To  
2. **Blanc** :  GEEKOM AE8, AMD Ryzen 7 8845HS (8 cœurs / 16 threads, jusqu’à 5,1 GHz), 64 Go DDR5, SSD 512 Go  
3. **Rouge** : Ryzen 7 8845HS, 32 Go DDR5, SSD 512 Go

Coût annuel estimé (la facture d’électricité mode 24/7):
- 7730U : **8,21 €**
- 8845HS : **24,64 €**

Performance :
- Single Thread : 3004 à 3739  
- CPU Mark : 18 027 à 28 481  

En usage réel, un seul serveur (le 7730U) suffit pour mes tâches quotidiennes.  

> Par exemple, lorsqu’il a été nécessaire de maintenir simultanément la connexion de plus de 200 clients. La machine virtuelle fonctionnait simplement sur un serveur équipé d’un processeur 8845HS, et pendant toute la durée de fonctionnement sous une telle charge (2 mois), la charge moyenne du processeur 8845HS n’a été que de 4 %.

Le cluster n’est activé qu’en période de test ou de charge spécifique.  
L’alimentation est assurée par un **bloc Anker 250 W USB-C** à distribution intelligente.

<!-- 📸 Фото каждого мини-ПК отдельно с подписями Bleu / Blanc / Rouge -->
<!-- 📸 Фото блока питания Anker с экраном потребления -->

---
## Le stockage NAS

J’utilise un **Beelink ME Mini PC (Intel N150)**, 12 Go LPDDR5, configuré sous **TrueNAS**.  

![Beelink ME Mini](NAS.jpg){: .shadow }

Trois disques **NVMe de 2 To** chacun sont montés en **RAID 5**, offrant un bon équilibre entre sécurité et vitesse.  
Le refroidissement actif garde les SSD sous contrôle même en pleine charge.

Le NAS est connecté au réseau via deux interfaces agrégées à **5 Gb/s**.  
Le design cylindrique rappelle le **Cylindre Mac Pro**, avec un flux d’air vertical très efficace.

![NAS Beelink](NAS_vent.jpg){: .shadow }

---
## Réseau et alimentation
![Switch LACP](SW1.jpg){: .shadow }
Le switch principal est un modèle noname sans ventilation active, mais avec une excellente stabilité thermique, même à 2,5 Gb/s.
Sa principale particularité est la prise en charge étendue des protocoles réseau, notamment le LACP, que je considère indispensable pour augmenter la bande passante du cluster. En effet, un agrégat de liens (bond) sans LACP pourrait, au mieux, offrir un léger gain, mais conduirait surtout à une retransmission massive de paquets. Ainsi, la présence du protocole LACP est essentielle.

![Switch without LACP](SW2.jpg){: .shadow }

Le second switch gigabit dispose également d’une large gamme de fonctions standards, mais ne prend pas en charge autant de protocoles. Il reste toutefois deux fois moins cher, ce qui en fait une solution économique pour l’extension des ports (KVM, Raspberry, etc.).

Les deux switches possèdent un port fibre optique à 10 Gb/s et huit ports Ethernet à 2,5 Gb/s chacun.

Côté alimentation, tout repose sur le **Alim Anker 250 W**, capable d’alimenter quatre appareils via USB-C, avec un affichage en temps réel de la consommation.  
![Anker](psu.jpg){: .shadow }

Cependant, un point pratique mérite d’être mentionné : les serveurs du cluster utilisent **des interfaces d’alimentation différentes**.

### Interfaces d’alimentation des serveurs

| Serveur   | Modèle         | Type d’alimentation |
| --------- | -------------- | ------------------- |
| **Bleu**  | Topton Mini PC | Jack DC             |
| **Blanc** | GEEKOM AE8     | Jack DC             |
| **Rouge** | Ryzen 7 8845HS | USB-C PD            |

L’**Anker 250W** fournit de l’énergie via **USB-C et USB-A**, mais je n’utilise pas les ports USB-A car ils délivrent une puissance insuffisante pour les mini-PC de type NUC.

---

### Câbles et adaptateurs utilisés

Pour alimenter correctement chaque machine, différentes solutions ont été nécessaires :

#### 🔵 Bleu (Topton Mini PC)
- Câble **USB-C → USB-C 60W**
- Adaptateur **USB-C → Jack DC (100W)**
  ![Adaptateur Jack - USB-C](adaptateur.jpg){: .shadow }
  On peut trouver ce type d’adaptateur ici :
  👉 [Adaptateur USB-C vers DC Jack 5.5mm sur AliExpress](https://fr.aliexpress.com/item/1005005101855652.html)

---

#### ⚪ Blanc (GEEKOM AE8)
- Problème lors de l’alimentation via USB-C :
  - Au démarrage, la consommation **dépasse 60W**
  - Même si l’Anker peut délivrer **jusqu’à 100W**, mon câble était limité à **60W**
    ![Configuration Anker pour C1 USB-C](C1.jpg){: .shadow }
  - Résultat : **impossible de démarrer le GEEKOM AE8** avec ce câble depuis l’Anker

> Au final, **l’Anker 250W n’alimente que deux mini-PC (NUC)**.  
Même si sa puissance totale serait théoriquement suffisante pour alimenter **l’ensemble du rack**, les **limitations liées aux câbles, aux pics de consommation au démarrage et aux différents types de connecteurs** rendent cette configuration impossible en pratique *(pour le moment)*.
{: .prompt-danger }



---

#### 🔴 Rouge (Ryzen 7 8845HS)
- Alimentation via **USB-C depuis l’Anker (70W max)**  
- Fonctionnement **stable et fiable**
  ![Configuration Anker pour C4 USB-C](C4.jpg){: .shadow }

---

La distribution de puissance a demandé quelques ajustements manuels, mais le résultat final est **propre, silencieux et fiable**.

Même sans refroidissement actif, la température de l’alimentation reste **maîtrisée** et ne dépasse pas les valeurs critiques, comme le montre l’image thermique ci-dessous :
![Thermal](thermal.jpg){: .shadow }

---
## Refroidissement et gestion thermique
Le flux d’air est organisé comme suit :

- En haut : **ventilateur LianLi** soufflant vers le bas sur les serveurs fanless.  
- En bas : **ventilateur 120 mm** activé automatiquement dès que la température atteint **36 °C**, s’arrêtant à **34 °C**.

Cette disposition crée un **courant vertical** naturel, tout en conservant un bruit minimal.
![Le thermostat vérifie la température de l’unité d’alimentation principale et, en cas de température élevée, active le ventilateur de 120 mm afin de créer un flux d’air accru.](temp.jpg){: .shadow }

> **Description :**	Le thermostat vérifie la température de l’unité d’alimentation principale et, en cas de température élevée, active le ventilateur de 120 mm afin de créer un flux d’air accru.

![Ce même ventilateur, vu de bas en haut depuis le support du serveur NAS. Le ventilateur est protégé par une grille spéciale.](vent.jpg){: .shadow }

> **Description :**	Ce même ventilateur, vu de bas en haut depuis le support du serveur NAS. Le ventilateur est protégé par une grille spéciale.

---
## Conclusion

Ce projet est plus qu’un simple cluster : c’est une **plateforme d’expérimentation personnelle**.  
Une manière d’apprendre, de tester, d’optimiser — et parfois de se tromper, mais toujours dans un cadre maîtrisé.  
Car c’est justement **le but d’un HomeLab : faire ses erreurs à la maison, pas en production**.

Merci d’avoir pris le temps de découvrir ma configuration et ma philosophie.  
Si ce projet vous inspire ou si vous avez des idées d’amélioration, partagez-les dans les commentaires !

![KVM](KVM.jpg){: .shadow : .right} Le dispositif KVM, qui peut être utilisé pour la gestion à distance des serveurs via un accès distant. Il s’agit en soi d’un serveur distinct doté d’une connexion Tailscale. Chaque serveur dispose d’une sortie de type « femelle » accessible depuis l’extérieur, permettant de connecter un câble HDMI et un câble USB (pour le clavier virtuel).

![KVM cables](KVM-int.jpg){: .shadow }

---

<!-- 💡 Идеи для доп. контента:
- Добавить схему сети (switches, NAS, serveurs)
- Сделать короткое видео (30-60 с) с вентилятором в работе
- Фото сравнения старых и новых версий HomeLab
- Вставить график потребления энергии -->

_Article rédigé par GoXLd – passionné de virtualisation et d’infrastructure sécurisée._
