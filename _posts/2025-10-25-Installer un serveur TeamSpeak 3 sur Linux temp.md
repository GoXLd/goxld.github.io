---
title: Installer un serveur TeamSpeak 3 sur Linux
date: 2025-10-25 11:00:00
categories: [Serveur]
tags: [teamspeak, linux, installation, script]
author: GoXLd
pin: false
published: false
media_subpath: /img/ts3/
image:
  path: titre-ts3.jpg
  lqip: data:image/jpg;base64,/9j/4AAQSkZJRgABAQEBLAEsAAD/2wBDAAMCAgMCAgMDAwMEAwMEBQgFBQQEBQoHBwYIDAoMDAsKCwsNDhIQDQ4RDgsLEBYQERMUFRUVDA8XGBYUGBIUFRT/2wBDAQMEBAUEBQkFBQkUDQsNFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBT/wgARCAAKABMDAREAAhEBAxEB/8QAFwAAAwEAAAAAAAAAAAAAAAAAAAUHA//EABgBAAMBAQAAAAAAAAAAAAAAAAECBQME/9oADAMBAAIQAxAAAAGvQaaLZ3OCzGlaDw6A/wD/xAAbEAACAwADAAAAAAAAAAAAAAACAwEEBQYRFP/aAAgBAQABBQKzeWgGajFOXoSQdy4eOGU5ecU+H//EABwRAAMAAQUAAAAAAAAAAAAAAAABAgMREjEyUf/aAAgBAwEBPwFS2LH6bTMlMToZexXJ/8QAHhEAAgEDBQAAAAAAAAAAAAAAAAECAxMxBBESITL/2gAIAQIBAT8BjHlgtprsdMw47GpSuFT2z//EACIQAAIBAwIHAAAAAAAAAAAAAAECAAMhIgQREhMjMUFCgf/aAAgBAQAGPwIs/CAPJM6as9NcqrbWWAkD4ZqxUzHKc5XjZHu0o39Z/8QAGxABAAIDAQEAAAAAAAAAAAAAAQARITFBUWH/2gAIAQEAAT8h7ItSIIq40a5D3x1gjZN9vE4xaDimKyqcxTUarX5Nxadn/9oADAMBAAIAAwAAABAyk/8A/8QAGBEBAQEBAQAAAAAAAAAAAAAAAREAMSH/2gAIAQMBAT8Qcg4PVd5mWZZMacwCAwL3/8QAHREBAAICAgMAAAAAAAAAAAAAAQARITFBUWGh8P/aAAgBAgEBPxB1QthrwuDz97dShohmY5IQgdQmjmf/xAAbEAEBAAMBAQEAAAAAAAAAAAABEQAhQTFxkf/aAAgBAQABPxAOoxHGw71hM2KFIhqJsg6PAqjpGFabaMGdIzllfc3P270kK2ceZtzcFYQF+ExP78z/2Q==
---

## Pourquoi ?

> Wow, TeamSpeak en 2025 ? Tu es sérieux ?
{: .prompt-tip }

Je comprends cette réaction. TeamSpeak peut sembler « dépassé » pour certains avec la montée de Discord. Pourtant, il reste une solution puissante et pertinente dans de nombreux cas :

### Avantages de TeamSpeak

- **Contrôle total** — vous pouvez l'héberger vous-même et garder vos données.
- **Faible latence réelle** — pas seulement le ping affiché.
- **Performance** — consommation minimale des ressources.
- **Pas de tracking massif** contrairement à certaines plateformes centralisées.
- **Fonctionne même dans des environnements restreints**.

### Un exemple concret

Discord affiche souvent une latence très faible, par exemple **6–7 ms**, comme ici :

![Discord](discord_ping.png){: .shadow }

Mais en réalité, lorsque je parle dans mon micro, la personne dans la pièce voisine entend ma voix avec un délai **réel de 60 à 80 ms**. Discord masque tout simplement une partie de la latence en n’affichant que le ping réseau, sans le traitement serveur.

Je pourrais joindre une vidéo comme preuve, mais ce n’est pas le sujet du jour.

---

### Restrictions dans certains pays

J'ai également découvert que Discord peut être limité selon les pays.  
Par exemple, un ami en Russie m’a écrit un soir que **Discord était bloqué chez eux** :

![Router](tg_lexa.png){: .shadow }
> **Description :** Notre serveur Discord est partiellement hors service — en Russie.

On sait que le gouvernement russe développe ses propres alternatives et que certaines restrictions apparaissent, par exemple les appels entre la France et la Russie via Telegram ne fonctionnent plus.

Mes amis ont simplement migré sans problème sur **mon serveur TeamSpeak 3**. C’est une réalité aujourd’hui : derrière les mots *liberté* et *anonymat*, on retrouve de plus en plus *self-hosting* et *open-source*.

---

Je ne prétends pas connaître en détail la structure interne de TeamSpeak 3, mais cela reste une excellente plateforme pour communiquer de manière stable et indépendante.

Pour répondre à ce besoin, je vous partage un script qui permet d’installer automatiquement un serveur TeamSpeak 3 sur Debian.

> Je ne vais pas ajouter ici le processus de création du conteneur LXC, car il n’a rien de particulier.  
> Je lui ai attribué **8 Go de stockage** (moins suffit largement), **2 Go de RAM**, **aucun swap**, et **4 vCPU (Ryzen 7 7730)**.
{: .prompt-info }


# Installer un serveur TeamSpeak 3 sur Linux avec un script automatisé

TeamSpeak 3 reste une solution populaire pour héberger des serveurs vocaux performants et légers — idéale pour les joueurs, les équipes de projet ou les communautés en ligne.  
Dans cet article, nous verrons comment installer rapidement un serveur **TeamSpeak 3** sur une machine Linux grâce à un script Bash automatisé que j’ai rédigé pour simplifier l’installation.

---

## 1. Présentation du script

Ce script Bash automatise toutes les étapes nécessaires à l’installation :

- Téléchargement de la version officielle **TeamSpeak 3.13.7** depuis le CDN officiel.  
- Création d’un utilisateur système `teamspeak`.  

```useradd -r -m -d /opt/teamspeak -s /bin/false teamspeak```

- Configuration des répertoires `/opt/teamspeak` et `/var/log/teamspeak`.  

```mkdir -p /opt/teamspeak
mkdir -p /var/log/teamspeak

chown -R teamspeak:teamspeak /opt/teamspeak
chown -R teamspeak:teamspeak /var/log/teamspeak
chmod -R 750 /opt/teamspeak
chmod -R 750 /var/log/teamspeak
```

- Acceptation automatique de la licence (obligatoire depuis TS3 3.10+).  
- Création d’un service **systemd** pour le démarrage automatique.  
- Ouverture des ports réseau nécessaires :  
  - **9987/UDP** — voix  
  - **30033/TCP** — transfert de fichiers  
  - **10011/TCP** — ServerQuery

---

## 2. Script complet d’installation

Voici le script complet à copier dans un fichier `install_ts3.sh` :

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

Rends le fichier exécutable et lance-le :

```bash
chmod +x install_ts3.sh
./install_ts3.sh
```

Le script télécharge automatiquement le serveur, crée les répertoires nécessaires, configure `systemd` et démarre le service.

![Install TS3](install_ts3.png){: .shadow }

---

## 4. Vérifier le statut et récupérer la clé d’administration

Pour vérifier que le service fonctionne (on peut voir token) :
  
```bash
systemctl status teamspeak3.service
```
![Systemctl TeamSpeak3](systecmctl.png){: .shadow }
Aussi on peut retrouver la clé d’administration initiale (Privilege Key) :

```bash
journalctl -u teamspeak3.service -b | grep -i 'token\|privilege'
```

---




## 5. Connexion au serveur

Depuis votre client TeamSpeak 3, connectez-vous à l’adresse :

```
votre_ip_publique:9987
```

⚠️ N’oubliez pas d’ouvrir les ports nécessaires dans votre pare-feu / router :

- UDP : 9987  
- TCP : 30033, 10011  

![Router](router.png){: .shadow }

>Так же нужно прописать порты на роутере: 
Я прописал только для соединения 9987 так как не планировал тест передачи данных
{: .prompt-info }
---

## Conclusion
![First connexion_ts3 server](connexion_ts3.png){: .shadow }
Grâce à ce script, l’installation d’un serveur **TeamSpeak 3** sous Linux devient simple, propre et automatisée.  
C’est une méthode idéale pour déployer rapidement votre propre serveur vocal, que ce soit pour un usage privé ou communautaire.

---

**Auteur :** GoXLd  
*Vous pouvez réutiliser et modifier ce script librement pour vos propres serveurs.*
