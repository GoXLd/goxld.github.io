---
title: Установка сервера TeamSpeak 3 на Linux
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
language: ru-RU
translation_key: installer-un-serveur-teamspeak-3-sur-linux
permalink: /posts/ru/installer-un-serveur-teamspeak-3-sur-linux/
---

## Зачем?

> Ого, TeamSpeak в 2025? Ты серьёзно?
{: .prompt-tip }

Я прекрасно понимаю такую реакцию. TeamSpeak может показаться устаревшим на фоне взлёта Discord. И всё же хоронить его слишком рано было бы ошибкой. В некоторых контекстах **он остаётся крайне актуальным решением**.

### Преимущества TeamSpeak

- **Полный контроль** — вы хостите его сами, ваши данные остаются у вас.
- **Реально низкая задержка** — а не просто красивый пинг в интерфейсе.
- **Эффективность** — минимальное потребление ресурсов.
- **Нет сбора данных**, в отличие от централизованных платформ.
- **Работает даже в ограниченных или цензурируемых средах**.

### Конкретный пример

Discord часто показывает очень низкую сетевую задержку, например **6–7 мс**:

![Discord](discord_ping.png){: .shadow }

Но в реальности, когда я говорю в микрофон, человек в соседней комнате слышит мой голос с **реальной задержкой 60–80 мс**. Discord просто маскирует часть задержки, показывая только сетевой пинг без учёта серверной обработки. Я мог бы приложить видео в качестве доказательства, но **сегодня не об этом**.

---

### Ограничения в некоторых странах

Я также обнаружил, что **Discord может ограничиваться в зависимости от страны**.  
Например, однажды вечером друг из России написал мне, что **Discord частично заблокирован**:

![Router](tg_lexa.png){: .shadow }

> **Перевод:** — Наш Discord-сервер не работает / — в России.

Известно, что российское правительство развивает собственные альтернативы, и некоторые ограничения появляются постепенно. Например, **звонки между Францией и Россией через Telegram больше не работают**.

Мои друзья просто мигрировали, без каких-либо трудностей, на **мой сервер TeamSpeak3**.  
Сегодня это факт: за словами _свобода_ и _анонимность_ всё чаще стоят **self-hosting** и **open-source**.

---

Я не претендую на детальное знание внутреннего устройства TeamSpeak 3, но это по-прежнему **надёжная, стабильная и независимая** платформа для общения.

Для этой задачи я делюсь здесь **скриптом автоматической установки** сервера **TeamSpeak 3** на Debian.
> Я не буду описывать процесс создания LXC-контейнера — в нём нет ничего особенного.  
> Я выделил ему **8 ГБ хранилища** (хватит и меньше), **2 ГБ RAM**, **без swap** и **4 vCPU (Ryzen 7 7730)**.
{: .prompt-info }

---

# Установка сервера TeamSpeak 3 на Linux

TeamSpeak 3 остаётся популярным решением для хостинга **производительных и лёгких голосовых серверов** — идеально для геймеров, проектных команд и онлайн-сообществ.

В этой статье я делюсь **Bash-скриптом**, который написал, чтобы **упростить и автоматизировать установку** сервера **TeamSpeak 3** на Linux.

---

## 1. Описание скрипта

Этот Bash-скрипт автоматизирует **все необходимые шаги установки**, такие как:

- Загрузка официальной версии **TeamSpeak 3.XX.X** с официального CDN.
- Автоматическое принятие лицензии (обязательно начиная с TS3 3.10+)
- Создание **systemd**-сервиса для автозапуска

Перед запуском скрипта:

- Создание системного пользователя `teamspeak`

```bash
useradd -r -m -d /opt/teamspeak -s /bin/false teamspeak
```

- Настройка каталогов `/opt/teamspeak` и `/var/log/teamspeak`

```bash
mkdir -p /opt/teamspeak
mkdir -p /var/log/teamspeak

chown -R teamspeak:teamspeak /opt/teamspeak
chown -R teamspeak:teamspeak /var/log/teamspeak
chmod -R 750 /opt/teamspeak
chmod -R 750 /var/log/teamspeak
```
---

## 2. Полный скрипт установки

Вот полный скрипт — скопируйте его в файл **install_ts3.sh**:

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

## 3. Запуск скрипта

Сделайте файл исполняемым и запустите его:

```bash
chmod +x install_ts3.sh
./install_ts3.sh
```

Скрипт автоматически скачает сервер, создаст нужные каталоги, настроит `systemd` и запустит сервис.

![Install TS3](install_ts3.png){: .shadow }
---

## 4. Проверка статуса и получение админ-ключа

Чтобы убедиться, что сервис работает корректно, и получить первичный токен доступа:

```bash
systemctl status teamspeak3.service
```

![Systemctl TeamSpeak3](systecmctl.png){: .shadow }

Также можно найти **первичный ключ администратора (Privilege Key)** следующей командой:

```bash
journalctl -u teamspeak3.service -b | grep -i 'token\|privilege'
```
---

## 5. Подключение к серверу

Не забудьте открыть нужные порты в брандмауэре или на роутере:

- **UDP: 9987**
- **TCP: 30033, 10011**

![Router](router.png){: .shadow }

Из клиента **TeamSpeak 3** подключайтесь по следующему адресу:

```
ваш_публичный_ip:9987

или, если роутер настроен:

ваш_публичный_ip
```

> В моём случае я открыл только порт **9987**, так как не планировал пользоваться передачей файлов.
{: .prompt-info }
---

## Заключение

![First connexion_ts3 server](connexion_ts3.png){: .shadow }

Благодаря этому скрипту установка сервера **TeamSpeak 3** на Linux становится простой, чистой и полностью автоматизированной.  
Это эффективный способ быстро развернуть собственный голосовой сервер — для **личного** использования, **с друзьями**, **в команде** или даже для **сообщества**.

---

**Автор:** GoXLd  
Вы можете свободно переиспользовать и модифицировать этот скрипт для своих серверов.  
Исходный код доступен здесь: [Gist GitHub](https://gist.github.com/GoXLd/a3ce0bbb9637f7ae4181e909d0226c5a)

### 💼 Поиск работы — системный администратор

В настоящее время ищу позицию **системного администратора** в **Лилле (Lille Métropole)** или окрестностях.  
Со мной можно связаться по email.
Другие способы связи — на моей странице: [Контакты](https://vande.fr/posts/Bienvenue/)
