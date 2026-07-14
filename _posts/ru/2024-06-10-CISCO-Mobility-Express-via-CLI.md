---
title: Гайд — CISCO Mobility Express на AIR-AP2802I-E-K9 GUI
date: 2024-06-20 11:00:00
categories: [MacOS, Windows, CISCO]
tags: [CISCO, Wireless Access Points, GUI, webinterface]     #TAG names should always be lowercase
author: GoXLd
pin: false
toc: false
published: true
media_subpath: /img/cisco-me/
image:
  path: logo_CISCO_ME.webp
  lqip: data:image/webp;base64,UklGRnwDAABXRUJQVlA4WAoAAAAwAAAAIAAADgAASUNDUMgBAAAAAAHIAAAAAAQwAABtbnRyUkdCIFhZWiAH4AABAAEAAAAAAABhY3NwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAA9tYAAQAAAADTLQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAlkZXNjAAAA8AAAACRyWFlaAAABFAAAABRnWFlaAAABKAAAABRiWFlaAAABPAAAABR3dHB0AAABUAAAABRyVFJDAAABZAAAAChnVFJDAAABZAAAAChiVFJDAAABZAAAAChjcHJ0AAABjAAAADxtbHVjAAAAAAAAAAEAAAAMZW5VUwAAAAgAAAAcAHMAUgBHAEJYWVogAAAAAAAAb6IAADj1AAADkFhZWiAAAAAAAABimQAAt4UAABjaWFlaIAAAAAAAACSgAAAPhAAAts9YWVogAAAAAAAA9tYAAQAAAADTLXBhcmEAAAAAAAQAAAACZmYAAPKnAAANWQAAE9AAAApbAAAAAAAAAABtbHVjAAAAAAAAAAEAAAAMZW5VUwAAACAAAAAcAEcAbwBvAGcAbABlACAASQBuAGMALgAgADIAMAAxADZBTFBIIQAAAAEX8Pn/iIhATdtG0LUcSuwe/mSy3h7R/wnow1jF+qUPYwBWUDggDgEAAHAFAJ0BKiEADwA+jTaVSCUjIiE1SACgEYllAL85izcz6bI3/gkVgB8LJy8s86Qd8hKoISgA/vqOrpBmAHP+bXZsSO8xI4zPbdvaTIC0fRqsmE+/omer8TSR6zqWPSz/wzfxm//DrzJ7gosJcVOY/lzUUKWcri1Qy0WrWI24LftA+Yy+AbgqJULNHrbg5rO3AmOTXeI0Kb9hP1urqf1kzX6hepBZtaTtUGSdWSbSu1AKMcs232FEzuNOtFJ2gzHHPkmvcvNUVmxP/feIRsbxGG0oP1D9IlbOebEUx9MlBa3cDpyYraL2C7muO1ZKbIIpq7fpKYqASjNv//oFWsK7ezKy1iMXyJNiOHVmOyAAAFBTQUlOAAAAOEJJTQPtAAAAAAAQAEgAAAABAAIASAAAAAEAAjhCSU0EKAAAAAAADAAAAAI/8AAAAAAAADhCSU0EQwAAAAAADlBiZVcBEAAGAEYAAAAA
language: ru-RU
translation_key: cisco-mobility-express-via-cli
permalink: /posts/ru/cisco-mobility-express-via-cli/
---

# Подробный гайд по обновлению прошивки точек доступа Cisco до Mobility Express

![CISCO download page](photo_2024-06-20_13-11-48.webp){: .shadow }

## **Цель:** описать процесс обновления прошивки AP Cisco до Mobility Express, чтобы можно было пользоваться графическим интерфейсом в браузере на компьютере.

*Оборудование в конфигурации*:

* CISCO AP AIR-AP-2802I-E-K9
* CISCO Catalyst 3650 - 24 PoE+ 4x1G
* MacBook M2 с Windows 11 (чтобы объяснить настройку на Windows)

***Софт:*** tftpd64, putty.exe, драйверы консольного кабеля

Мой Macbook Air M2 8/256 2022, но я буду использовать Win11 (hosted hypervisor: parallels)

### ДИСКЛЕЙМЕР
>Я всего лишь любитель и экспериментатор, который любит сложные задачи и простые решения. Прежде чем повторять — дочитайте до конца.
{: .prompt-danger }

---

## Установка

Необходимые приложения/библиотеки/ссылки:
- Установить **Tftpd64**
   ```
   https://pjo2.github.io/tftpd64/
   ```
   Детальная инструкция по установке — на [официальной wiki](https://github.com/PJO2/tftpd64/wiki).

- Установить **Putty.exe**


 Скачайте образ «Mobility Express for Aironet 1830» [здесь](https://software.cisco.com/download/home/).

 ![CISCO download page](2024-06-20_00-02-15.webp){: .shadow }


>**Описание:**	Cisco 1830 Series Mobility Express Release 8.10 Software, to be used for conversion from Lightweight Access Points only.

## Установка Mobility-Express через tftp-сервер

1.	Отключить брандмауэр и добавить исключения для tftpd64:

Отключение брандмауэра: откройте настройки брандмауэра на компьютере, временно отключите его, чтобы избежать помех.

ИЛИ добавьте исключения:

Добавьте tftpd64.exe в список исключений брандмауэра для беспрепятственной коммуникации.

2.	Настроить питание на интерфейсах коммутатора для непрерывного питания интерфейсов AP Cisco:
Убедитесь, что все интерфейсы, к которым подключены AP Cisco, настроены на непрерывное питание, чтобы избежать перебоев во время обновления прошивки.
Настройка Inline-питания:
Подключитесь к интерфейсу командной строки (CLI) коммутатора.

Введите следующие команды для настройки непрерывного питания на всех интерфейсах:
```
   configure terminal
   interface range <range_of_interfaces>
   power inline auto
 ```
>В коммутаторах CISCO нет постоянно включённого PoE-питания на интерфейсах — только AUTO или Disable. Так что не удивляйтесь, увидев AUTO.
{: .prompt-tip }

### Настройка сетевой карты на компьютере:
4.	Сменить IPv4-адрес на статический:
Зайдите в сетевые настройки компьютера.
Настройте IPv4-адрес следующим образом:
IP-адрес: 10.0.20.10
Маска подсети: 255.0.0.0

![Сетевые настройки](2024-06-17_11-39-24.webp){: .shadow }

### Запустите Tftpd64 и настройте его по приведённым скриншотам.

**Tftpd64** - GLOBAL
![Tftpd64 - Settings - GLOBAL](2024-06-17_11-43-31.webp){: width="400" : .shadow }{: .right }

**Tftpd64** - Settings - TFTP
![Tftpd64 - Settings - TFTP](2024-06-17_13-29-07.webp){: width="700" : .shadow }{: .right }

**Tftpd64** - Settings - DHCP
![Tftpd64 - Settings - DHCP](2024-06-17_13-32-53.webp){: width="400" : .shadow }

## Подключение к AP Cisco

**Используйте консольный кабель и Putty.exe:**

Подключитесь к AP Cisco через консольный кабель и Putty.exe.
Учётные данные по умолчанию на «чистой» установке:
-	***Имя пользователя***: Cisco
-	***Пароль***: Cisco
-	***Пароль для enable***: Cisco

![Входим в enable mode CLI](2024-06-17_13-54-21.webp){:: .shadow }

## Настройка IP-адреса CAPWAP:
Введите следующую команду для настройки IP-адреса AP:

```
capwap ap ip 10.0.20.5 255.0.0.0 10.0.20.10
```

## Пинг и передача прошивки:

Проверьте связь между устройствами следующими командами:
Пинг с AP на ПК:

```
ping 10.0.20.10
```

Пинг с ПК на AP:
```
ping 10.0.20.5
```

##	Передача прошивки на AP Cisco:
Введите следующую команду для загрузки прошивки на AP:
```
ap-type mobility-express tftp://10.0.20.10/AIR-AP2800-K9-ME-8-10-190-0.tar
```
>Имя прошивки может отличаться в зависимости от скачанного файла.
{: .prompt-info }

![Загрузка прошивки на AP](img-install-firmware.png){:: .shadow }

# Настройка после установки Mobility Express:

![Завершение установки прошивки на AP](2024-06-19_15-20-53.webp){:: .shadow }

## Настройка Mobility Express (минимальная):
Следуйте инструкциям на экране для первичной настройки:

* ***Имя администратора***: admin
* ***Пароль администратора***: Admin1
* ***Имя системы AP***: AP-B1 (для AP Baie №1)
* ***Имя пользователя для AP***: user
* ***Пароль для AP***: APuser1 (Enable Password for AP : APuser1)
* ***Код страны***: FR
* ***Настроить NTP-сервер***: НЕТ
* ***Системное время***: НЕТ
* ***IP-адрес интерфейса***: СТАТИЧЕСКИЙ
* ***IP-адрес управления***: 10.0.20.20
* ***Маска подсети управления***: 255.0.0.0
* ***Шлюз по умолчанию для управления***: 10.0.20.1
* ***Создать DHCP-диапазон управления***: НЕТ
* ***Management DHCP Scope***: НЕТ
* ***Имя рабочей сети (SSID)***: AP-B1
* ***Безопасность рабочей сети***: PSK
* ***PSK-фраза рабочей сети (8-63 символа)***: colbertAP
* ***Повторите PSK-фразу***: colbertAP
* ***Включить оптимизацию RF-параметров***: НЕТ
* ***Настроить внутренний AP в режиме Flex+Bridge***: НЕТ

После перезагрузки нужно ввести следующие команды для активации визуального интерфейса:
```
(Cisco Controller) >config network webmode disable
(Cisco Controller) >config network secureweb enable
```

Первая команда — для ***http***, вторая — для доступа через ***https***.

После выполнения этих шагов ваша точка доступа Cisco должна быть обновлена до Mobility Express и готова к настройке через графический интерфейс в браузере.

```
10.0.20.20

Используйте
Имя администратора: admin
Пароль администратора: Admin1
```

> Внимание: страница доступа не открывается в браузере Chrome (в моём случае), но отлично работает в браузере Edge.
{: .prompt-danger }

![GUI Mobility Express](2024-06-19_15-38-25.webp){:: .shadow }

## Сброс к заводским настройкам

Чтобы сбросить настройки, удерживайте кнопку сброса точки доступа при подаче питания. Не отпускайте её — в консоли должен появиться обратный отсчёт. Для восстановления заводских настроек убедитесь, что отсчёт превысил 20 секунд.

После перезагрузки

Подключитесь к консоли с парой логин/пароль по умолчанию:
Cisco – Cisco

нужно ввести команду (в режиме enable)
```
#capwap ap ip 10.0.20.5 255.0.0.0 10.0.20.10
```
Через некоторое время (1–2 минуты) начнётся загрузка Mobility Express, и нужно будет заново пройти процесс настройки ***Mobility Express***.

![GUI Mobility Express](2024-06-19_15-01-03.webp){:: .shadow }

_Спасибо за внимание!_
