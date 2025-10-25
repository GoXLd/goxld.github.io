---
title: Installer un serveur TeamSpeak 3 sur Linux
date: 2025-10-25 11:00:00
categories: [Serveur]
tags: [teamspeak, linux, installation, script]
author: GoXLd
pin: false
published: true
media_subpath: /img/ts3/
image:
  path: titre-ts3.jpg
  lqip: data:image/jpg;base64,/9j/4AAQSkZJRgABAQEBLAEsAAD/2wBDAAMCAgMCAgMDAwMEAwMEBQgFBQQEBQoHBwYIDAoMDAsKCwsNDhIQDQ4RDgsLEBYQERMUFRUVDA8XGBYUGBIUFRT/2wBDAQMEBAUEBQkFBQkUDQsNFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBT/wgARCAAKABMDAREAAhEBAxEB/8QAFwAAAwEAAAAAAAAAAAAAAAAAAAUHA//EABgBAAMBAQAAAAAAAAAAAAAAAAECBQME/9oADAMBAAIQAxAAAAGvQaaLZ3OCzGlaDw6A/wD/xAAbEAACAwADAAAAAAAAAAAAAAACAwEEBQYRFP/aAAgBAQABBQKzeWgGajFOXoSQdy4eOGU5ecU+H//EABwRAAMAAQUAAAAAAAAAAAAAAAABAgMREjEyUf/aAAgBAwEBPwFS2LH6bTMlMToZexXJ/8QAHhEAAgEDBQAAAAAAAAAAAAAAAAECAxMxBBESITL/2gAIAQIBAT8BjHlgtprsdMw47GpSuFT2z//EACIQAAIBAwIHAAAAAAAAAAAAAAECAAMhIgQREhMjMUFCgf/aAAgBAQAGPwIs/CAPJM6as9NcqrbWWAkD4ZqxUzHKc5XjZHu0o39Z/8QAGxABAAIDAQEAAAAAAAAAAAAAAQARITFBUWH/2gAIAQEAAT8h7ItSIIq40a5D3x1gjZN9vE4xaDimKyqcxTUarX5Nxadn/9oADAMBAAIAAwAAABAyk/8A/8QAGBEBAQEBAQAAAAAAAAAAAAAAAREAMSH/2gAIAQMBAT8Qcg4PVd5mWZZMacwCAwL3/8QAHREBAAICAgMAAAAAAAAAAAAAAQARITFBUWGh8P/aAAgBAgEBPxB1QthrwuDz97dShohmY5IQgdQmjmf/xAAbEAEBAAMBAQEAAAAAAAAAAAABEQAhQTFxkf/aAAgBAQABPxAOoxHGw71hM2KFIhqJsg6PAqjpGFabaMGdIzllfc3P270kK2ceZtzcFYQF+ExP78z/2Q==
---

## Pourquoi ?

> Wow, TeamSpeak en 2025 ? Tu es sérieux ?
{: .prompt-tip }

Je comprends très bien cette réaction. TeamSpeak peut sembler dépassé avec la montée en puissance de Discord. Pourtant, ce serait une erreur de l’enterrer trop vite. Dans certains contextes, **il reste une solution extrêmement pertinente**.

### Avantages de TeamSpeak

- **Contrôle total** — vous l’hébergez vous-même, vos données restent chez vous.
- **Faible latence réelle** — pas seulement un joli ping affiché dans l’interface.
- **Efficacité** — consommation minimale de ressources.
- **Pas de collecte de données** contrairement aux plateformes centralisées.
- **Fonctionne même dans des environnements restreints ou censurés**.

### Exemple concret

Discord affiche souvent une latence réseau très faible, comme **6–7 ms** :

![Discord](discord_ping.png){: .shadow }

Mais dans la réalité, quand je parle dans mon micro, la personne dans la pièce voisine entend ma voix avec un **retard réel de 60 à 80 ms**. Discord masque simplement une partie de la latence en n’affichant que le ping réseau, sans inclure le traitement serveur.

Je pourrais ajouter ici une vidéo comme preuve, mais **ce n’est pas le sujet du jour**.
---

### Restrictions dans certains pays

J’ai également découvert que **Discord pouvait être restreint selon les pays**.  
Par exemple, un soir, un ami en Russie m’a écrit que **Discord était partiellement bloqué** :

![Router](tg_lexa.png){: .shadow }

> **Description :** Notre serveur Discord est partiellement hors service — en Russie.

On sait que le gouvernement russe développe ses propres alternatives, et certaines restrictions apparaissent progressivement.  
Par exemple, **les appels entre la France et la Russie via Telegram ne fonctionnent plus**.

Mes amis ont simplement migré, sans aucune difficulté, vers **mon serveur TeamSpeak 3**.  
C’est un fait aujourd’hui : derrière les mots _liberté_ et _anonymat_, on retrouve de plus en plus **l’auto-hébergement** et **l’open-source**.

---

Je ne prétends pas connaître en détail la structure interne de TeamSpeak 3, mais cela reste une plateforme **fiable, stable et indépendante** pour communiquer.

Pour répondre à ce besoin, je partage ici **un script d’installation automatique** d’un serveur **TeamSpeak 3** sous Debian.
> Je ne vais pas ajouter ici le processus de création du conteneur LXC, car il n’a rien de particulier.  
> Je lui ai attribué **8 Go de stockage** (moins suffit largement), **2 Go de RAM**, **aucun swap** et **4 vCPU (Ryzen 7 7730)**.
{: .prompt-info }

---

# Installer un serveur TeamSpeak 3 sur Linux avec un script automatisé

TeamSpeak 3 reste une solution populaire pour héberger des **serveurs vocaux performants et légers**, idéale pour les joueurs, les équipes de projet ou les communautés en ligne.

Dans cet article, je partage un **script Bash** que j’ai écrit afin de **simplifier et automatiser l’installation** d’un serveur **TeamSpeak 3** sous Linux.

---

## 1. Présentation du script

Ce script Bash automatise **toutes les étapes nécessaires à l’installation** :

- Téléchargement de la version officielle **TeamSpeak 3.13.7** depuis le CDN officiel
- Création d’un utilisateur système `teamspeak`

```bash
useradd -r -m -d /opt/teamspeak -s /bin/false teamspeak
```

- Configuration des répertoires `/opt/teamspeak` et `/var/log/teamspeak`

```bash
mkdir -p /opt/teamspeak
mkdir -p /var/log/teamspeak

chown -R teamspeak:teamspeak /opt/teamspeak
chown -R teamspeak:teamspeak /var/log/teamspeak
chmod -R 750 /opt/teamspeak
chmod -R 750 /var/log/teamspeak
```

- Acceptation automatique de la licence (obligatoire depuis TS3 3.10+)
- Création d’un service **systemd** pour le démarrage automatique
- Ouverture des ports réseau nécessaires :
  - **9987/UDP** — Voix
  - **30033/TCP** — Transfert de fichiers
  - **10011/TCP** — ServerQuery
---

## 2. Script complet d’installation

Voici le script complet à copier dans un fichier **install_ts3.sh** :

```bash
код здесь
```

---

## 3. Lancer le script

Rendez le fichier exécutable puis lancez-le :

```bash
chmod +x install_ts3.sh
./install_ts3.sh
```

Le script télécharge automatiquement le serveur, crée les répertoires nécessaires, configure `systemd` et démarre le service.

![Install TS3](install_ts3.png){: .shadow }
---

## 4. Vérifier le statut et récupérer la clé d’administration

Pour vérifier que le service fonctionne correctement et récupérer le token d’accès initial :

```bash
systemctl status teamspeak3.service
```

![Systemctl TeamSpeak3](systecmctl.png){: .shadow }

Vous pouvez également retrouver la **clé d’administration initiale (Privilege Key)** avec la commande suivante :

```bash
journalctl -u teamspeak3.service -b | grep -i 'token\|privilege'
```
---

## 5. Connexion au serveur

Depuis votre client **TeamSpeak 3**, connectez-vous à l’adresse suivante :

```
votre_ip_publique:9987
```

N’oubliez pas d’ouvrir les ports nécessaires dans votre pare-feu ou sur votre routeur :

- **UDP : 9987**
- **TCP : 30033, 10011**

![Router](router.png){: .shadow }

> Il faut également configurer les ports sur le routeur.  
> Dans mon cas, je n’ai ouvert que le port **9987** car je ne prévoyais pas d’utiliser le transfert de fichiers.
{: .prompt-info }
---

## Conclusion

![First connexion_ts3 server](connexion_ts3.png){: .shadow }

Grâce à ce script, l’installation d’un serveur **TeamSpeak 3** sous Linux devient simple, propre et entièrement automatisée.  
C’est une méthode efficace pour déployer rapidement votre propre serveur vocal, que ce soit pour un usage **privé**, **entre amis**, **en équipe** ou même pour **une communauté**.

---

**Auteur :** GoXLd  
Vous pouvez librement réutiliser et modifier ce script pour vos propres serveurs.
