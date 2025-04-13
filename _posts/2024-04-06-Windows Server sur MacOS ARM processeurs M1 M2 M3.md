---
title: Guide - Windows Server sur MacOS ARM processeurs M1 M2 M3
date: 2024-04-06 11:00:00
categories: [MacOS]
tags: [macbook, arm, m1, m2, m3, virtualisation]     #TAG names should always be lowercase
author: GoXLd
pin: false
toc: false
published: true
img_path: /img/ws2022/
image:
  path: preview_ws2022.jpg
  lqip: data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAICAgICAgICAgIDAgICAwQDAgIDBAUEBAQEBAUGBQUFBQUFBgYHBwgHBwYJCQoKCQkMDAwMDAwMDAwMDAwMDAz/2wBDAQMDAwUEBQkGBgkNCgkKDQ8ODg4ODw8MDAwMDA8PDAwMDAwMDwwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAz/wAARCAAKABMDAREAAhEBAxEB/8QAGAAAAgMAAAAAAAAAAAAAAAAAAAUEBwn/xAAxEAAABAMDBw0AAAAAAAAAAAABAgMEAAURBjI0CBIhNTZRYgcTFBciIzEzN2FkkZT/xAAZAQACAwEAAAAAAAAAAAAAAAADBQACBAb/xAAuEQAAAwUECAcAAAAAAAAAAAAAAQIDBAURMRITIUIiMlFhcYGCkRQzQUPB0fD/2gAMAwEAAhEDEQA/AEjKxcmkRXrudos00StzCyO+fGl5BcFEM0oCUpueGlexTiqEJYG5w95bKS/vHh0ERSVhpKnq6VJFiHkQem7FCTYovDM8S2FKuHYTXFl7MzuVGPKmctUcuFkyS5VjaBOYqkSITOcdKYAQimkw92oGgAAQMFaQzjkFhbq73rk93yiURGkyTiSp4psnllpFvAXJ9eWrSy1Z2CkZz4fYR9WPxh+o5OyGtsGWPsXyfak2mcYzxwJvJ4t/tG1lXLTNq9XxvGdn615VFMZK3rMXUuzkzu4i6nc4d8WPy/ark4GIvr50/bBpB+CAAfcf/9k=
---

# Installation de Windows Server 2022 sur un ordinateur avec architecture arm - Macbook M2 à des fins éducatives

## Description de l'expérience :
Ces notes s'appliqueront à tous les ordinateurs de la gamme macbook air/pro basés sur les processeurs M1 M2 M3 de l'architecture arm.

Mon Macbook Air M2 8/256 2022



### AVERTISSEMENT
>Je suis simplement un amateur et un expérimentateur qui aime les défis complexes et les solutions simples, mais lors de cet essai, mon Macbook a été extrêmement surchauffé (l'absence de système de refroidissement actif a un impact). Avant de répéter, lisez jusqu'à la fin.
{: .prompt-danger }

![iStat Menus](2024-04-06_11-16-32.webp){: .shadow : .right} Je recommande d'installer les capteurs iStat Menus.


---

## Installation via UTM

Applications/bibliothèques/liens nécessaires :
- Installer brew
   Commande à exécuter dans le terminal :
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```
   Instructions détaillées d'installation disponibles sur le [site officiel](https://brew.sh/).

- Installer les outils de développement xcode
   Commande à exécuter dans le terminal :
```bash
xcode-select --install
```    
- Installer UTM
   Commande à exécuter dans le terminal :
```bash
brew install utm
```
- Installer qemu
   Commande à exécuter dans le terminal :
```bash
brew install qemu
```

 Téléchargez l'image disque de Windows Server 2022 [ici](https://www.microsoft.com/fr-fr/evalcenter/download-windows-server-2022).

## Installation de Windows Server

![Menu d'installation UTM](2024-04-06_11-32-38.webp){: .shadow }

Sélectionnez le processus d'émulation plutôt que de virtualisation, car nous prévoyons d'utiliser une image système créée pour une autre architecture.

![Menu d'installation UTM](2024-04-07_16-43-40.webp){: .shadow }

Ne sélectionnez pas "autre système" - nous allons installer avec les préconfigurations pour Windows 10/11. J'ai essayé plusieurs fois d'installer via "Autre", mais le BIOS intégré ne voulait même pas démarrer ou détecter l'image système. Par conséquent, écoutez mon expérience et choisissez Windows 10/11.

![Menu d'installation UTM](2024-04-07_16-44-45.webp){: .shadow }

Sélectionnez l'image de notre système - j'ai utilisé une image système officielle avec les mises à jour de mars 2024 de Windows Server 2022 (au moment de la rédaction de l'article en avril 2024). Laissez les autres cases cochées telles quelles, faites comme sur la capture d'écran.

![Menu d'installation UTM](2024-04-07_16-46-03.webp){: .shadow }

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



  



  

