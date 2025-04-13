---
title: Guide - CISCO Mobility Express sur AIR-AP2802I-E-K9 GUI
date: 2024-06-20 11:00:00
categories: [MacOS, Windows, CISCO]
tags: [macbook, arm, m1, m2, m3, virtualisation, CISCO, Wireless Access Points, GUI, webinterface]     #TAG names should always be lowercase
author: GoXLd
pin: false
toc: false
published: true
img_path: /img/cisco-me/
image:
  path: logo_CISCO_ME.webp
  lqip: data:image/webp;base64,UklGRnwDAABXRUJQVlA4WAoAAAAwAAAAIAAADgAASUNDUMgBAAAAAAHIAAAAAAQwAABtbnRyUkdCIFhZWiAH4AABAAEAAAAAAABhY3NwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAA9tYAAQAAAADTLQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAlkZXNjAAAA8AAAACRyWFlaAAABFAAAABRnWFlaAAABKAAAABRiWFlaAAABPAAAABR3dHB0AAABUAAAABRyVFJDAAABZAAAAChnVFJDAAABZAAAAChiVFJDAAABZAAAAChjcHJ0AAABjAAAADxtbHVjAAAAAAAAAAEAAAAMZW5VUwAAAAgAAAAcAHMAUgBHAEJYWVogAAAAAAAAb6IAADj1AAADkFhZWiAAAAAAAABimQAAt4UAABjaWFlaIAAAAAAAACSgAAAPhAAAts9YWVogAAAAAAAA9tYAAQAAAADTLXBhcmEAAAAAAAQAAAACZmYAAPKnAAANWQAAE9AAAApbAAAAAAAAAABtbHVjAAAAAAAAAAEAAAAMZW5VUwAAACAAAAAcAEcAbwBvAGcAbABlACAASQBuAGMALgAgADIAMAAxADZBTFBIIQAAAAEX8Pn/iIhATdtG0LUcSuwe/mSy3h7R/wnow1jF+qUPYwBWUDggDgEAAHAFAJ0BKiEADwA+jTaVSCUjIiE1SACgEYllAL85izcz6bI3/gkVgB8LJy8s86Qd8hKoISgA/vqOrpBmAHP+bXZsSO8xI4zPbdvaTIC0fRqsmE+/omer8TSR6zqWPSz/wzfxm//DrzJ7gosJcVOY/lzUUKWcri1Qy0WrWI24LftA+Yy+AbgqJULNHrbg5rO3AmOTXeI0Kb9hP1urqf1kzX6hepBZtaTtUGSdWSbSu1AKMcs232FEzuNOtFJ2gzHHPkmvcvNUVmxP/feIRsbxGG0oP1D9IlbOebEUx9MlBa3cDpyYraL2C7muO1ZKbIIpq7fpKYqASjNv//oFWsK7ezKy1iMXyJNiOHVmOyAAAFBTQUlOAAAAOEJJTQPtAAAAAAAQAEgAAAABAAIASAAAAAEAAjhCSU0EKAAAAAAADAAAAAI/8AAAAAAAADhCSU0EQwAAAAAADlBiZVcBEAAGAEYAAAAA
---

# Guide détaillé pour la mise à jour du firmware des points d'accès Cisco vers Mobility Express

![CISCO download page](photo_2024-06-20_13-11-48.webp){: .shadow }

## **Objectif :** Décrire le processus de mise à jour du firmware des AP Cisco vers Mobility Express pour permettre l'utilisation de l'interface graphique dans un navigateur sur un ordinateur.

*Matériels dans la configuration* :

* CISCO AP AIR-AP-2802I-E-K9
* CISCO Catalyst 3650 - 24 PoE+ 4x1G
* MacBook M2 avec Windows 11 (pour expliquer la configuration sur Windows)

***Logiciels:*** tftpd64, putty.exe, drivers de câble console

Mon Macbook Air M2 8/256 2022 mais je vais utiliser Win11 (hosted hypervisor: parallels)



### AVERTISSEMENT
>Je suis simplement un amateur et un expérimentateur qui aime les défis complexes et les solutions simples. Avant de répéter, lisez jusqu'à la fin.
{: .prompt-danger }

---

## Installation

Applications/bibliothèques/liens nécessaires :
- Installer **Tftpd64**
   ```
   https://pjo2.github.io/tftpd64/
   ```
   Instructions détaillées d'installation disponibles sur le [wiki officiel](https://github.com/PJO2/tftpd64/wiki).

- Installer **Putty.exe**


 Téléchargez l'image "Mobility Express for Aironet 1830"  [ici](https://software.cisco.com/download/home/).

 ![CISCO download page](2024-06-20_00-02-15.webp){: .shadow }


>**Description :**	Cisco 1830 Series Mobility Express Release 8.10 Software,to be used for conversion from Lightweight Access Points only.

## Installation Mobility-Express par tftp server

1.	Désactiver le pare-feu et ajouter des exceptions pour tftpd64 :

Désactivation du pare-feu :	Ouvrez les paramètres du pare-feu sur votre ordinateur.	Désactivez temporairement le pare-feu pour éviter toute interférence.

OU	ajout d'exceptions :

Ajoutez tftpd64.exe à la liste des exceptions du pare-feu pour permettre une communication fluide.

2.	Configurer l'alimentation sur les interfaces du Switch pour une alimentation continue des interfaces AP Cisco :
Assurez-vous que toutes les interfaces connectées aux AP Cisco sont configurées pour une alimentation continue afin d'éviter les interruptions pendant la mise à jour du firmware.
Configuration de l'alimentation Inline :
Connectez-vous à l'interface de ligne de commande (CLI) du switch.

Entrez les commandes suivantes pour configurer l'alimentation continue sur toutes les interfaces :
```
   configure terminal
   interface range <range_of_interfaces>
   power inline auto
 ```
>Dans les commutateurs CISCO, il n'y a pas d'alimentation PoE constamment activée sur les interfaces, seulement AUTO ou Disable. Donc, ne soyez pas surpris de voir AUTO.
{: .prompt-tip }

### Configuration de la carte réseau sur l'ordinateur :
4.	Changer l'adresse IPv4 en statique :
Allez dans les paramètres réseau de votre ordinateur.
Configurez l'adresse IPv4 comme suit :
Adresse IP : 10.0.20.10
Masque de sous-réseau : 255.0.0.0

![Les paramètres réseau](2024-06-17_11-39-24.webp){: .shadow }

### Lancez Tftpd64 et configurez-le selon les captures d'écran fournies.

**Tftpd64** - GLOBAL
![Tftpd64 - Settings - GLOBAL](2024-06-17_11-43-31.webp){: width="400" : .shadow }{: .right }

**Tftpd64** - Settings - TFTP
![Tftpd64 - Settings - TFTP](2024-06-17_13-29-07.webp){: width="700" : .shadow }{: .right }

**Tftpd64** - Settings - DHCP
![Tftpd64 - Settings - DHCP](2024-06-17_13-32-53.webp){: width="400" : .shadow }

## Connexion à l'AP Cisco 

**Utiliser un câble console et le logiciel Putty.exe:**

Connectez-vous à l'AP Cisco en utilisant un câble console et Putty.exe.
Identifiants par défaut sur une installation "propre" :
-	***Nom d'utilisateur*** : Cisco
-	***Mot de passe*** : Cisco
-	***Mot de passe pour enable***: Cisco

![Rentrez dans enable mode CLI](2024-06-17_13-54-21.webp){:: .shadow }

## Configurer l'adresse IP CAPWAP :
Entrez la commande suivante pour configurer l'adresse IP de l'AP :

```
capwap ap ip 10.0.20.5 255.0.0.0 10.0.20.10
```

## Ping et transfert du firmware :

Testez la connexion entre les appareils avec les commandes suivantes :
Ping depuis l'AP vers le PC :

```
ping 10.0.20.10
```

Ping depuis le PC vers l'AP :
```
ping 10.0.20.5
```

##	Transférer le firmware vers l'AP Cisco :
Entrez la commande suivante pour charger le firmware sur l'AP :
```
ap-type mobility-express tftp://10.0.20.10/AIR-AP2800-K9-ME-8-10-190-0.tar
```
>Le nom du firmware peut varier selon le fichier téléchargé.
{: .prompt-info }

![charger le firmware sur l'AP](img-install-firmware.png){:: .shadow }

# Configuration après l'installation de Mobility Express :

![Fin install le firmware sur l'AP](2024-06-19_15-20-53.webp){:: .shadow }

## Configurer Mobility Express (minimal):
Suivez les instructions à l'écran pour la configuration initiale :

* ***Nom de l'administrateur*** : admin
* ***Mot de passe administrateur*** : Admin1
* ***Nom du système AP*** : AP-B1 (pour AP Baie №1)
* ***Nom d'utilisateur pour l'AP*** : user
* ***Mot de passe pour l'AP*** : APuser1 (Enable Password for AP : APuser1)
* ***Code pays*** : FR
* ***Configurer le serveur NTP*** : NON
* ***Heure du système*** : NON
* ***Adresse IP de l'interface*** : STATIQUE
* ***Adresse IP de gestion*** : 10.0.20.20
* ***Masque de sous-réseau de gestion*** : 255.0.0.0
* ***Routeur par défaut de gestion*** : 10.0.20.1
* ***Créer une plage DHCP de gestion*** : NON
* ***Management DHCP Scope***: NON
* ***Nom du réseau employé (SSID)*** : AP-B1
* ***Sécurité du réseau employé*** : PSK
* ***Phrase de passe PSK employé (8-63 caractères)*** : colbertAP
* ***Ressaisir la phrase de passe PSK employé*** : colbertAP
* ***Activer l'optimisation des paramètres RF*** : NON
* ***Configurer l'AP interne en mode Flex+Bridge*** : NON

Après le redémarrage, vous devez entrer les commandes suivantes pour activer l'interface visuelle: 
```
(Cisco Controller) >config network webmode disable
(Cisco Controller) >config network secureweb enable
```

La première commande est pour ***http***, la deuxième pour accéder via ***https***.

Après avoir terminé ces étapes, votre point d'accès Cisco devrait être mis à jour avec Mobility Express et prêt à être configuré via l'interface graphique dans un navigateur.

```
10.0.20.20

Utilise 
Nom de l’administrateur : admin
Mot de passe administrateur : Admin1
```

> Attention, la page d'accès ne s'ouvre pas dans le navigateur Chrome (dans mon cas), mais fonctionne parfaitement dans le navigateur Edge.
{: .prompt-danger }

![GUI Mobility Express](2024-06-19_15-38-25.webp){:: .shadow }

## Réinstallation des paramètres par défaut

Pour réinitialiser les paramètres, vous devez maintenir le bouton de réinitialisation de l'accès point enfoncé pendant la mise sous tension. Ne le relâchez pas, un compte à rebours devrait s'afficher dans la console. Pour rétablir les paramètres d'usine, assurez-vous que ce compte à rebours dépasse 20 secondes.

Après le redémarrage

Connectez-vous à la console avec le couple de login et mot de passe par défaut :
Cisco – Cisco

il faut entrer la commande (en mode enable)
```
#capwap ap ip 10.0.20.5 255.0.0.0 10.0.20.10
```
Après un certain temps (1-2 mins), le chargement de Mobility Express commencera et on dois recomancer process configuration ***Mobility Express***.

![GUI Mobility Express](2024-06-19_15-01-03.webp){:: .shadow }

_Merci de votre attention !_



  



  

