---
title: Guide - CISCO Mobility Express sur 
date: 2024-04-06 11:00:00
categories: [MacOS, Windows, CISCO]
tags: [macbook, arm, m1, m2, m3, virtualisation, CISCO, Wireless Access Points, GUI]     #TAG names should always be lowercase
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

## **Objectif :** Décrire le processus de mise à jour du firmware des AP Cisco vers Mobility Express pour permettre l'utilisation de l'interface graphique dans un navigateur sur un ordinateur.

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

Tftpd64 - GLOBAL
![Tftpd64 - Settings - GLOBAL](2024-06-17_11-43-31.webp){: .shadow }

Tftpd64 - Settings - TFTP
![Tftpd64 - Settings - TFTP](2024-06-17_13-29-07.webp){: .shadow }

Tftpd64 - Settings - DHCP
![Tftpd64 - Settings - DHCP](2024-06-17_13-32-53.webp){: .shadow }

**ATTENTION TRÈS IMPORTANT !** J'ai beaucoup lu sur l'émulation de Windows Server sur Internet et il y a beaucoup d'avis négatifs sur cette approche, disant que c'est très lent et instable. Mais dans mon cas (encore une fois, Macbook Air M2 8/256), tout fonctionne à un niveau acceptable, bien que la température pendant l'installation soit effrayante. Après tout, j'ai besoin du système pour apprendre, pas pour déployer un centre de données réel.

>La première fois que j'ai installé WS, j'ai aussi trouvé que tout était très lent et trop bogué, mais quelle a été ma surprise quand j'ai réalisé que lors de l'installation avec les paramètres par défaut, UTM essayait d'installer Windows en émulant seulement un cœur de processeur. 1 ! Il est étrange que personne n'en parle, compte tenu des lags et des ralentissements du système émulé.
{: .prompt-warning }

![Gestionnaire des tâches avec le système installé avec les paramètres par défaut du processeur émulé](2024-04-06_01-21-55.webp){: .shadow }
Travailler dans un tel système, même à des fins éducatives, était impossible.

**SOLUTION :** Spécifiez les cœurs manuellement. À des fins de test, j'ai spécifié 4 cœurs et l'installation ainsi que le démarrage du nouveau système ont été beaucoup plus rapides. Je pense que sur votre Macbook Pro, vous pouvez spécifier plus de cœurs alloués.

Choisissez autant de RAM que possible. J'ai choisi 4 Go, mais si j'avais un Macbook avec 16 Go, j'aurais choisi 8 Go. La logique est simple.

![Menu d'installation UTM](2024-04-07_16-48-52.webp){: width="700" height="400" : .shadow }

La taille de l'espace de stockage permanent selon vos besoins (et possibilités).

Après l'installation, l'installateur m'a demandé de choisir un dossier partagé pour les fichiers (vous pouvez le faire plus tard, mais dans mon cas, j'ai créé un répertoire séparé pour utiliser WS).

![Menu d'installation UTM](2024-04-07_16-51-09.webp){: .shadow }

L'installateur résume toutes les configurations que nous avons saisies pour confirmation finale.
![Menu d'installation UTM](2024-04-07_16-52-09.webp){: .shadow }

Maintenant, nous avons le système dans la fenêtre de sélection dans UTM.
![Menu d'installation UTM](2024-04-07_16-52-49.webp){: .shadow }

Lancer

Lors du premier démarrage, j'ai été confronté à cette fenêtre, résolue en saisissant la commande

![Menu d'installation UTM](2024-04-07_16-53-53.webp){: .shadow }

```bash
exit
```

Et sans modifier les paramètres du BIOS - effectuez une réinitialisation - reset
![Menu d'installation UTM](2024-04-07_16-54-46.webp){: .shadow }

## "Press any key to load ..."

Appuyez sur n'importe quelle touche

Et après un certain temps, vous verrez la fenêtre d'installation de Windows familière.

![Menu d'installation UTM](2024-04-07_16-57-23.webp){: .shadow }

### Conseils d'installation :

Pendant l'installation de Windows Server, n'oubliez pas de sélectionner le système approprié :
<!-- markdownlint-capture -->
<!-- markdownlint-disable -->
> Petites explications :
- Desktop Experience permet d'avoir une interface graphique familière des versions de bureau de **Windows**.
- La version Datacenter permet de créer des comptes d'utilisateurs virtuels (utilisateurs du système) 
{: .prompt-info }
<!-- markdownlint-restore -->

Pour mes besoins éducatifs, j'installerai Windows Server 2022 (expérience de bureau) licence Datacenter.

Maintenant, faites attention aux températures pendant l'installation :
![l'installation UTM](2024-04-06_00-53-47.webp){: .shadow }

Après l'installation, vous verrez la fenêtre de déverrouillage Windows standard, où vous serez invité à saisir Ctrl + Alt + Detele pour déverrouiller, mais comme ces touches n'existent pas, je vais insérer ici une réponse de GitHub UTM [lien vers le post](https://github.com/utmapp/UTM/issues/3413#issuecomment-1001997191)  (GoXLd : Une autre solution: vous pouvez également toujours installer un clavier standard WIN) 

![Windows Server 2022](2024-04-07_17-53-27.webp){: .shadow }

N'oubliez pas non plus qu'au premier démarrage, le système doit installer UTM Guest Tool.

![Windows Server 2022](2024-04-05_20-30-11.webp){: .shadow }
il me semble que lancer Windows Server de cette manière sur un M2 8/256 est un masochisme complet. Un système avec une émulation plus précisément réglée fonctionne beaucoup mieux (moins de plantages et de gel), mais reste loin de la fluidité de la virtualisation. D'ailleurs, lors de l'utilisation de Windows Server 2022, il n'y a pas de surchauffe du système et la température moyenne du Macbook reste entre 70 et 80 degrés. 
>Peut-être que sur mon ordinateur 'faible', il faut d'essayer des versions plus anciennes (moins exigeantes en matériel) 
{: .prompt-tip }
N'oubliez pas retirez le ISO WS
![Windows Server 2022](2024-04-07_18-31-38.webp){: .shadow }

Windows Server 2022

![Windows Server 2022](2024-04-07_20-24-44.webp){: .shadow }

>La conclusion finale en raison de l'absence de refroidissement actif et du coût des ressources pour émuler x86_64 et exécuter Windows Server 2022 est une action très dangereuse, pouvant entraîner une dégradation rapide du processeur central et la panne de l'ordinateur. Le démarrage sur les versions MacBook Pro reste également incertain. Mais sur les versions par défaut de n'importe quel MacBook Air (en 2024) - ne le faites même pas, n'essayez même pas.
{: .prompt-danger }

_Merci de votre attention !_



  



  

