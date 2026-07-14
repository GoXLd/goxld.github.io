---
title: Installing a TeamSpeak 3 server on Linux
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
language: en
translation_key: installer-un-serveur-teamspeak-3-sur-linux
permalink: /posts/en/installer-un-serveur-teamspeak-3-sur-linux/
---

## Why?

> Wow, TeamSpeak in 2025? Are you serious?
{: .prompt-tip }

I completely understand that reaction. TeamSpeak may look outdated with the rise of Discord. Yet burying it too quickly would be a mistake. In some contexts, **it remains an extremely relevant solution**.

### Advantages of TeamSpeak

- **Full control** — you host it yourself, your data stays with you.
- **Genuinely low latency** — not just a pretty ping displayed in the interface.
- **Efficiency** — minimal resource consumption.
- **No data collection**, unlike centralized platforms.
- **Works even in restricted or censored environments**.

### A concrete example

Discord often displays a very low network latency, such as **6–7 ms**:

![Discord](discord_ping.png){: .shadow }

But in reality, when I speak into my microphone, the person in the next room hears my voice with a **real delay of 60 to 80 ms**. Discord simply hides part of the latency by only displaying the network ping, without including server processing. I could add a video here as proof, but **that's not today's topic**.

---

### Restrictions in some countries

I also discovered that **Discord can be restricted depending on the country**.  
For example, one evening a friend in Russia wrote to me that **Discord was partially blocked**:

![Router](tg_lexa.png){: .shadow }

> **Translation:** - Our Discord server is down / — in Russia.

We know the Russian government is developing its own alternatives, and some restrictions are appearing progressively. For example, **calls between France and Russia via Telegram no longer work**.

My friends simply migrated, without any difficulty, to **my TeamSpeak3 server**.  
It is a fact today: behind the words _freedom_ and _anonymity_, you increasingly find **self-hosting** and **open-source**.

---

I don't claim to know the internal structure of TeamSpeak 3 in detail, but it remains a **reliable, stable and independent** platform for communication.

To answer this need, I am sharing here **an automatic installation script** for a **TeamSpeak 3** server on Debian.
> I won't include the LXC container creation process here, as there is nothing special about it.  
> I gave it **8 GB of storage** (less is more than enough), **2 GB of RAM**, **no swap** and **4 vCPU (Ryzen 7 7730)**.
{: .prompt-info }

---

# Installing a TeamSpeak 3 server on Linux

TeamSpeak 3 remains a popular solution for hosting **high-performance, lightweight voice servers**, ideal for gamers, project teams or online communities.

In this article, I share a **Bash script** I wrote to **simplify and automate the installation** of a **TeamSpeak 3** server on Linux.

---

## 1. Script overview

This Bash script automates **all the steps required for the installation**, such as:

- Downloading the official **TeamSpeak 3.XX.X** release from the official CDN.
- Automatically accepting the license (mandatory since TS3 3.10+)
- Creating a **systemd** service for automatic startup

Before running the script:

- Create the `teamspeak` system user

```bash
useradd -r -m -d /opt/teamspeak -s /bin/false teamspeak
```

- Set up the `/opt/teamspeak` and `/var/log/teamspeak` directories

```bash
mkdir -p /opt/teamspeak
mkdir -p /var/log/teamspeak

chown -R teamspeak:teamspeak /opt/teamspeak
chown -R teamspeak:teamspeak /var/log/teamspeak
chmod -R 750 /opt/teamspeak
chmod -R 750 /var/log/teamspeak
```
---

## 2. Full installation script

Here is the full script to copy into a file named **install_ts3.sh**:

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

## 3. Running the script

Make the file executable, then run it:

```bash
chmod +x install_ts3.sh
./install_ts3.sh
```

The script automatically downloads the server, creates the required directories, configures `systemd` and starts the service.

![Install TS3](install_ts3.png){: .shadow }
---

## 4. Checking the status and retrieving the admin key

To verify the service is running correctly and retrieve the initial access token:

```bash
systemctl status teamspeak3.service
```

![Systemctl TeamSpeak3](systecmctl.png){: .shadow }

You can also find the **initial admin key (Privilege Key)** with the following command:

```bash
journalctl -u teamspeak3.service -b | grep -i 'token\|privilege'
```
---

## 5. Connecting to the server

Don't forget to open the required ports in your firewall or on your router:

- **UDP: 9987**
- **TCP: 30033, 10011**

![Router](router.png){: .shadow }

From your **TeamSpeak 3** client, connect to the following address:

```
your_public_ip:9987

or if you configured your router:

your_public_ip
```

> In my case, I only opened port **9987** because I wasn't planning to use file transfer.
{: .prompt-info }
---

## Conclusion

![First connexion_ts3 server](connexion_ts3.png){: .shadow }

Thanks to this script, installing a **TeamSpeak 3** server on Linux becomes simple, clean and fully automated.  
It is an efficient way to quickly deploy your own voice server, whether for **private** use, **with friends**, **in a team** or even for **a community**.

---

**Author:** GoXLd  
You are free to reuse and modify this script for your own servers.  
Source code available here: [GitHub Gist](https://gist.github.com/GoXLd/a3ce0bbb9637f7ae4181e909d0226c5a)

### 💼 Job search – Systems Administrator

Currently looking for a **systems administrator** position in **Lille (Lille Métropole)** or the surrounding area.  
You can contact me by email.
Other contact options are available on my page: [Contact](https://vande.fr/posts/Bienvenue/)
