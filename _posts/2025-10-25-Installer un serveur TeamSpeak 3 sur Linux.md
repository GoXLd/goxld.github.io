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
  lqip: data:image/jpg;base64,/9j/4AAQSkZJRgABAQEBLAEsAAD/2wBDAAMCAgMCAgMDAwMEAwMEBQgFBQQEBQoHBwYIDAoMDAsKCwsNDhIQDQ4RDgsLEBYQERMUFRUVDA8XGBYUGBIUFRT/2wBDAQMEBAUEBQkFBQkUDQsNFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBT/wgARCAAJABIDAREAAhEBAxEB/8QAFgABAQEAAAAAAAAAAAAAAAAABQcE/8QAGAEBAAMBAAAAAAAAAAAAAAAAAQACAwT/2gAMAwEAAhADEAAAAahybnxNSQaX0FRGf//EAB0QAAICAQUAAAAAAAAAAAAAAAIEAwUAARQyNDb/2gAIAQEAAQUCktEa5Wa1IC3auuI9Wu8WHH//xAAYEQACAwAAAAAAAAAAAAAAAAAQEQABMf/aAAgBAwEBPwFBS8P/xAAYEQACAwAAAAAAAAAAAAAAAAAAEAERMf/aAAgBAgEBPwEpzq//xAAkEAACAQIDCQAAAAAAAAAAAAABAgADEQQFcxITISMxYbHB0f/aAAgBAQAGPwLbbdKBwjOqBsCg5lVrdfglyKV+zTMdFvMbTqe4J//EAB8QAAIBAwUBAAAAAAAAAAAAAAERACFBURAxYaHR8P/aAAgBAQABPyEFYQdMvCF4s5J6s0wTcPhgDDXU7T4pPm4aHdMT/9oADAMBAAIAAwAAABBoFr//xAAZEQEAAgMAAAAAAAAAAAAAAAAAAREQMUH/2gAIAQMBAT8QgqFGhzH/xAAZEQEAAwEBAAAAAAAAAAAAAAABABExEKH/2gAIAQIBAT8QLXJ6lMdOv//EABsQAQACAwEBAAAAAAAAAAAAAAERIQAxUfAQ/9oACAEBAAE/EHkbzSPQRVQ0HcTnQSShSQhgxtLRB+EZUWt2lHPl/wBrufO5n//Z
language: fr-FR
translation_key: installer-un-serveur-teamspeak-3-sur-linux
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

Mais dans la réalité, quand je parle dans mon micro, la personne dans la pièce voisine entend ma voix avec un **retard réel de 60 à 80 ms**. Discord masque simplement une partie de la latence en n’affichant que le ping réseau, sans inclure le traitement serveur.  Je pourrais ajouter ici une vidéo comme preuve, mais **ce n’est pas le sujet du jour**.

---

### Restrictions dans certains pays

J’ai également découvert que **Discord pouvait être restreint selon les pays**.  
Par exemple, un soir, un ami en Russie m’a écrit que **Discord était partiellement bloqué** :

![Router](tg_lexa.png){: .shadow }

> **Traduction :**  - Notre serveur Discord est hors service / — en Russie.

On sait que le gouvernement russe développe ses propres alternatives, et certaines restrictions apparaissent progressivement. Par exemple, **les appels entre la France et la Russie via Telegram ne fonctionnent plus**.

Mes amis ont simplement migré, sans aucune difficulté, vers **mon serveur TeamSpeak3**.  
C’est un fait aujourd’hui : derrière les mots _liberté_ et _anonymat_, on retrouve de plus en plus **l’auto-hébergement** et **l’open-source**.

---

Je ne prétends pas connaître en détail la structure interne de TeamSpeak 3, mais cela reste une plateforme **fiable, stable et indépendante** pour communiquer.

Pour répondre à ce besoin, je partage ici **un script d’installation automatique** d’un serveur **TeamSpeak 3** sous Debian.
> Je ne vais pas ajouter ici le processus de création du conteneur LXC, car il n’a rien de particulier.  
> Je lui ai attribué **8 Go de stockage** (moins suffit largement), **2 Go de RAM**, **aucun swap** et **4 vCPU (Ryzen 7 7730)**.
{: .prompt-info }

---

# Installer un serveur TeamSpeak 3 sur Linux

TeamSpeak 3 reste une solution populaire pour héberger des **serveurs vocaux performants et légers**, idéale pour les joueurs, les équipes de projet ou les communautés en ligne.

Dans cet article, je partage un **script Bash** que j’ai écrit afin de **simplifier et automatiser l’installation** d’un serveur **TeamSpeak 3** sous Linux.

---

## 1. Présentation du script

Ce script Bash automatise **toutes les étapes nécessaires à l’installation** comme 

- Téléchargement de la version officielle **TeamSpeak 3.XX.X** depuis le CDN officiel.
- Acceptation automatique de la licence (obligatoire depuis TS3 3.10+)
- Création d’un service **systemd** pour le démarrage automatique

Avant lance le script:

- Création licence free d’un utilisateur système `teamspeak`

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
---

## 2. Script complet d’installation

Voici le script complet à copier dans un fichier **install_ts3.sh** :

```bash
#!/usr/bin/env bash
set -euo pipefail

# === Paramètres ===
LOG_FILE="/root/install_ts3.log"
IP_SERVER="${IP_SERVER:-}"
TS_VERSION="3.13.7"
TS_PKG="teamspeak3-server_linux_amd64-${TS_VERSION}.tar.bz2"
TS_URL="https://files.teamspeak-services.com/releases/server/${TS_VERSION}/${TS_PKG}"
TS_USER="teamspeak"
TS_GROUP="teamspeak"
TS_HOME="/opt/teamspeak"
TS_LOG_DIR="/var/log/teamspeak"

# === Préparation ===
echo -e "\n$(date +'%F %T') :: Installation du serveur TeamSpeak 3 version ${TS_VERSION}\n" | tee -a "$LOG_FILE"

if [[ "$(id -u)" -ne 0 ]]; then
  echo "Ce script doit être exécuté en tant que root." | tee -a "$LOG_FILE"
  exit 1
fi

if ! command -v systemctl >/dev/null 2>&1; then
  echo "Systemd n’a pas été trouvé. Ce script nécessite systemd." | tee -a "$LOG_FILE"
  exit 1
fi

if [[ -z "${IP_SERVER}" ]]; then
  IP_SERVER="0.0.0.0"
fi

# Installation des dépendances
if command -v apt-get >/dev/null 2>&1; then
  apt-get update -y >>"$LOG_FILE" 2>&1 || true
  apt-get install -y wget tar bzip2 >>"$LOG_FILE" 2>&1
elif command -v dnf >/dev/null 2>&1; then
  dnf install -y wget tar bzip2 >>"$LOG_FILE" 2>&1
elif command -v yum >/dev/null 2>&1; then
  yum install -y wget tar bzip2 >>"$LOG_FILE" 2>&1
fi

# Création de l’utilisateur système
if ! id -u "$TS_USER" >/dev/null 2>&1; then
  useradd --system --home-dir "$TS_HOME" --shell /usr/sbin/nologin "$TS_USER"
fi
mkdir -p "$TS_HOME" "$TS_LOG_DIR"
chown -R "$TS_USER":"$TS_GROUP" "$TS_HOME" "$TS_LOG_DIR"

# Téléchargement et extraction
TMPD="$(mktemp -d)"
trap 'rm -rf "$TMPD"' EXIT
echo "Téléchargement de ${TS_URL}..." | tee -a "$LOG_FILE"
wget -q -O "${TMPD}/${TS_PKG}" "$TS_URL"
tar -xjf "${TMPD}/${TS_PKG}" -C "$TMPD"
cp -a "${TMPD}/teamspeak3-server_linux_amd64/." "$TS_HOME/"

# Fichier de configuration
cat > "${TS_HOME}/ts3server.ini" <<EOF
machine_id=
default_voice_port=9987
voice_ip=${IP_SERVER}
licensepath=
filetransfer_port=30033
filetransfer_ip=${IP_SERVER}
query_port=10011
query_ip=${IP_SERVER}
query_ip_whitelist=query_ip_whitelist.txt
query_ip_blacklist=query_ip_blacklist.txt
dbplugin=ts3db_sqlite3
dbconnections=10
logpath=${TS_LOG_DIR}/
logquerycommands=0
EOF

# Acceptation de la licence
touch "${TS_HOME}/.ts3server_license_accepted"
chown "$TS_USER":"$TS_GROUP" "${TS_HOME}/.ts3server_license_accepted"
chown -R "$TS_USER":"$TS_GROUP" "$TS_HOME"

# Service systemd
cat > /etc/systemd/system/teamspeak3.service <<'UNIT'
[Unit]
Description=TeamSpeak 3 Server
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=teamspeak
Group=teamspeak
WorkingDirectory=/opt/teamspeak
Environment=TS3SERVER_LICENSE=accept
ExecStart=/opt/teamspeak/ts3server inifile=ts3server.ini
Restart=on-failure
RestartSec=5s
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
UNIT

# Activation et démarrage
systemctl daemon-reload
systemctl enable --now teamspeak3.service
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

N’oubliez pas d’ouvrir les ports nécessaires dans votre pare-feu ou sur votre routeur :

- **UDP : 9987**
- **TCP : 30033, 10011**

![Router](router.png){: .shadow }

Depuis votre client **TeamSpeak 3**, connectez-vous à l’adresse suivante :

```
votre_ip_publique:9987

ou si vous avez configure votre routeur:

votre_ip_publique 
```

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
Code source disponible ici : [Gist GitHub](https://gist.github.com/GoXLd/a3ce0bbb9637f7ae4181e909d0226c5a)

### 💼 Recherche d’emploi – Administrateur Systèmes

Actuellement à la recherche d’un poste d’**administrateur systèmes** sur **Lille (Lille Métropole)** ou ses environs.  
Vous pouvez me contacter par email.
Autres moyens de contact disponibles sur ma page : [Contact](https://vande.fr/posts/Bienvenue/)
