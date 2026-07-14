---
title: My HomeLab v3 - philosophy, architecture and silent performance
description: Full presentation of the third version of my HomeLab - a silent, frugal and powerful cluster with 150 GB of RAM, 3.64 TB NVMe in RAID 5 and optimized power management.
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
language: en
translation_key: homelab-concept
permalink: /posts/en/homelab-concept/
---

# My HomeLab v3: performance and silence

Hello everyone!
Today I'm presenting the **third version** of my **HomeLab** — a project both technical and personal, reflecting my philosophy and my approach to home computing.

![Homelab main photo](homelab.jpg){: .shadow }

## UPDATE - February 2026

After more than **90 days** of continuous operation, the lab remains **stable**, with no issues or interruptions.

![HomeLab uptime](uptime.png){: .shadow }

Currently only one server is powered on: **node1 (Ryzen 7 7730U, 64 GB RAM)**.  
The other nodes are shut down to save energy, and this machine is more than enough for all my containers and VMs.

In early **December 2025**, I shut down `node2` and `node3` to measure the energy impact, as consumption had exceeded **30 kWh/month**.  
After optimization, only these remain active: the two switches, the main server, the KVM, the air sensors and the rack fans.

![Consumption December 2025 / January 2026](consommation.jpg){: .shadow }

In **January 2026**, you can clearly see consumption staying under **20 kWh/month**, despite more active use of the lab.




## Project philosophy

>Before talking tech, I want to share my priorities when designing a HomeLab:
1. **Absolute silence** — a home server must not sound like a mini data center.  
2. **Performance per watt** — a hypervisor running 24/7 must not blow up the electricity bill.  
3. **Value for money** — choose coherent components, not necessarily the most/least expensive ones.
{: .prompt-danger }
This project is not a tutorial, but an **experience exchange** and an **invitation to discuss** for everyone building their own infrastructure at home.

## The previous HomeLab versions

Why "version 3"?  
Because before reaching this configuration, I went through two iterations.

### Version 1: discovery
A simple **mini PC based on an AMD x86 processor**.  
Why AMD?  
Because at the time, **Intel did not yet offer small-process-node processors** (4 nm for the 8845HS versus much larger for its Intel equivalents).  
Result: for only 45 W, I get **28,000 CPU Mark points**, versus 6,000 for an Intel at 6 W.

I've often seen videos where creators build a "cluster" on N100s while praising their low consumption… yet unable to sustain a real workload.  
My advice: look for **the best CPU Mark per watt energy efficiency**, not just the number at the wall socket.

![AE8 Geekom - my first mini PC](AE8_geekom.jpg){: .shadow }
> You may notice the mini PC has only one Ethernet interface. But even if there are three or four, you have to look at **which ones**. I wouldn't bring this up without a reason, but I have very often observed, on almost every mini PC I tested, the impossibility of "waking" them from the S5 state using a Magic Packet.
{: .prompt-info }

### Version 2: the NAS and Synology's limits

I then tried shared storage based on **Synology**.  
Their UI is gorgeous, but the **I/O** performance is underwhelming, especially for the price.  
So I went with a **compact Beelink**, much faster, where the **bottleneck is the network**, not the CPU or the disks.

Synology remains great for **backups**, but for raw performance, Beelink wins by a wide margin.

## The current infrastructure: HomeLab v3

The core of this version rests on three mini PCs forming a **powerful, modular cluster**.

### General specifications

- **Total CPU**: 74,989 CPU Mark points  
- **RAM**: 150 GB  
- **NAS storage**: RAID 5 NVMe 3.64 TB (up to 5 Gb/s per data link, 2.5 Gb/s to the servers)  
- **Network**: dual configurable switches (main switch + Gigabit extension)  
- **Cooling**: silent, directed-airflow system  
- **Ancillary equipment**: KVM over IP, Raspberry Pi 5, temperature and power sensors.

<!-- 📸 Отдельное фото Raspberry Pi 5 с экраном Zabbix -->

## The servers

Before detailing the internal configuration, note that I use a **GeeekPi 8U Server Rack DeskPi RackMate T1**, a rackmount chassis designed for mini servers and network gear, with an aluminum alloy structure and acrylic panel.

![AE8 Geekom - my first mini PC](rackmate.png){: .shadow }

Here is the cluster's composition:

1. **Blue**: Topton fanless Mini PC, Ryzen 7 7730U, 64 GB DDR4, 1 TB SSD  
2. **White**: GEEKOM AE8, AMD Ryzen 7 8845HS (8 cores / 16 threads, up to 5.1 GHz), 64 GB DDR5, 512 GB SSD  
3. **Red**: Ryzen 7 8845HS, 32 GB DDR5, 512 GB SSD

Estimated annual cost (electricity bill, 24/7 mode):
- 7730U: **€8.21**
- 8845HS: **€24.64**

Performance:
- Single Thread: 3004 to 3739  
- CPU Mark: 18,027 to 28,481  

In real-world use, a single server (the 7730U) is enough for my daily tasks.

> For example, when it was necessary to simultaneously maintain connections from more than 200 clients. The virtual machine simply ran on a server with an 8845HS processor, and during the whole period under such load (2 months), the 8845HS's average CPU load was only 4%.

The cluster is only powered on during testing or specific workloads.  
Power is provided by an **Anker 250 W USB-C** unit with smart distribution.

<!-- 📸 Фото каждого мини-ПК отдельно с подписями Bleu / Blanc / Rouge -->
<!-- 📸 Фото блока питания Anker с экраном потребления -->

---
## The NAS storage

I use a **Beelink ME Mini PC (Intel N150)**, 12 GB LPDDR5, running **TrueNAS**.  

![Beelink ME Mini](NAS.jpg){: .shadow }

Three **2 TB NVMe** drives are set up in **RAID 5**, offering a good balance between safety and speed.  
Active cooling keeps the SSDs under control even at full load.

The NAS connects to the network through two aggregated **5 Gb/s** interfaces.  
The cylindrical design recalls the **Mac Pro cylinder**, with a very efficient vertical airflow.

![NAS Beelink](NAS_vent.jpg){: .shadow }

---
## Network and power
![Switch LACP](SW1.jpg){: .shadow }
The main switch is a noname model without active cooling, but with excellent thermal stability, even at 2.5 Gb/s.
Its main distinguishing feature is extensive network protocol support, notably LACP, which I consider indispensable for increasing the cluster's bandwidth. Indeed, a link aggregate (bond) without LACP could, at best, offer a slight gain, but would mostly lead to massive packet retransmission. So having the LACP protocol is essential.

![Switch without LACP](SW2.jpg){: .shadow }

The second, gigabit switch also has a wide range of standard functions, but supports fewer protocols. It is however half the price, making it an economical solution for port extension (KVM, Raspberry, etc.).

Both switches have one 10 Gb/s fiber port and eight 2.5 Gb/s Ethernet ports each.

On the power side, everything rests on the **Anker 250 W** unit, able to power four devices via USB-C, with a real-time consumption display.  
![Anker](psu.jpg){: .shadow }

However, one practical point deserves a mention: the cluster's servers use **different power interfaces**.

### Server power interfaces

| Server   | Model         | Power type |
| --------- | -------------- | ------------------- |
| **Blue**  | Topton Mini PC | DC Jack             |
| **White** | GEEKOM AE8     | DC Jack             |
| **Red** | Ryzen 7 8845HS | USB-C PD            |

The **Anker 250W** delivers power via **USB-C and USB-A**, but I don't use the USB-A ports because they deliver insufficient power for NUC-style mini PCs.

---

### Cables and adapters used

To power each machine properly, different solutions were necessary:

#### 🔵 Blue (Topton Mini PC)
- **USB-C → USB-C 60W** cable
- **USB-C → DC Jack (100W)** adapter
  ![Jack - USB-C adapter](adaptateur.jpg){: .shadow }
  You can find this type of adapter here:
  👉 [USB-C to DC Jack 5.5mm adapter on AliExpress](https://fr.aliexpress.com/item/1005005101855652.html)

---

#### ⚪ White (GEEKOM AE8)
- Problem when powering via USB-C:
  - At startup, consumption **exceeds 60W**
  - Even though the Anker can deliver **up to 100W**, my cable was limited to **60W**
    ![Anker configuration for C1 USB-C](C1.jpg){: .shadow }
  - Result: **impossible to boot the GEEKOM AE8** with this cable from the Anker

> In the end, **the Anker 250W powers only two mini PCs (NUCs)**.  
Even though its total output would theoretically be enough to power **the whole rack**, the **limitations tied to cables, startup consumption peaks and different connector types** make this configuration impossible in practice *(for now)*.
{: .prompt-danger }



---

#### 🔴 Red (Ryzen 7 8845HS)
- Powered via **USB-C from the Anker (70W max)**  
- **Stable and reliable** operation
  ![Anker configuration for C4 USB-C](C4.jpg){: .shadow }

---

The power distribution required some manual adjustments, but the final result is **clean, silent and reliable**.

Even without active cooling, the power unit's temperature remains **under control** and does not exceed critical values, as the thermal image below shows:
![Thermal](thermal.jpg){: .shadow }

---
## Cooling and thermal management
The airflow is organized as follows:

- At the top: a **LianLi fan** blowing downward onto the fanless servers.  
- At the bottom: a **120 mm fan** automatically activated as soon as the temperature reaches **36 °C**, stopping at **34 °C**.

This layout creates a natural **vertical current**, while keeping noise minimal.
![The thermostat checks the temperature of the main power unit and, if it gets hot, activates the 120 mm fan to create increased airflow.](temp.jpg){: .shadow }

> **Description:**	The thermostat checks the temperature of the main power unit and, when it runs hot, activates the 120 mm fan to create increased airflow.

![The same fan, seen from below looking up from the NAS server mount. The fan is protected by a special grille.](vent.jpg){: .shadow }

> **Description:**	The same fan, seen from below looking up from the NAS server mount. The fan is protected by a special grille.

---
## Conclusion

This project is more than a mere cluster: it is a **personal experimentation platform**.  
A way to learn, to test, to optimize — and sometimes to make mistakes, but always in a controlled setting.  
Because that is precisely **the point of a HomeLab: make your mistakes at home, not in production**.

Thank you for taking the time to discover my setup and my philosophy.  
If this project inspires you or if you have improvement ideas, share them in the comments!

![KVM](KVM.jpg){: .shadow : .right} The KVM device, which can be used for remote server management. It is itself a separate server with a Tailscale connection. Each server has an externally accessible "female" output allowing an HDMI cable and a USB cable (for the virtual keyboard) to be connected.

![KVM cables](KVM-int.jpg){: .shadow }

---

<!-- 💡 Идеи для доп. контента:
- Добавить схему сети (switches, NAS, serveurs)
- Сделать короткое видео (30-60 с) с вентилятором в работе
- Фото сравнения старых и новых версий HomeLab
- Вставить график потребления энергии -->

_Article written by GoXLd – virtualization and secure infrastructure enthusiast._
