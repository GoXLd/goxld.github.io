---
title: Guide - CISCO Mobility Express on AIR-AP2802I-E-K9 GUI
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
language: en
translation_key: cisco-mobility-express-via-cli
permalink: /posts/en/cisco-mobility-express-via-cli/
---

# Detailed guide to upgrading Cisco access point firmware to Mobility Express

![CISCO download page](photo_2024-06-20_13-11-48.webp){: .shadow }

## **Goal:** describe the process of upgrading Cisco AP firmware to Mobility Express so the graphical interface can be used in a browser on a computer.

*Hardware in this setup*:

* CISCO AP AIR-AP-2802I-E-K9
* CISCO Catalyst 3650 - 24 PoE+ 4x1G
* MacBook M2 with Windows 11 (to explain the setup on Windows)

***Software:*** tftpd64, putty.exe, console cable drivers

My Macbook Air M2 8/256 2022, but I will use Win11 (hosted hypervisor: parallels)

### DISCLAIMER
>I am just a hobbyist and experimenter who likes complex challenges and simple solutions. Before repeating this, read to the end.
{: .prompt-danger }

---

## Installation

Required applications/libraries/links:
- Install **Tftpd64**
   ```
   https://pjo2.github.io/tftpd64/
   ```
   Detailed installation instructions are available on the [official wiki](https://github.com/PJO2/tftpd64/wiki).

- Install **Putty.exe**


 Download the "Mobility Express for Aironet 1830" image [here](https://software.cisco.com/download/home/).

 ![CISCO download page](2024-06-20_00-02-15.webp){: .shadow }


>**Description:**	Cisco 1830 Series Mobility Express Release 8.10 Software, to be used for conversion from Lightweight Access Points only.

## Installing Mobility-Express via a tftp server

1.	Disable the firewall and add exceptions for tftpd64:

Disabling the firewall: open the firewall settings on your computer and temporarily disable it to avoid any interference.

OR add exceptions:

Add tftpd64.exe to the firewall's exception list to allow smooth communication.

2.	Configure power on the switch interfaces for continuous power to the Cisco AP interfaces:
Make sure all interfaces connected to the Cisco APs are configured for continuous power to avoid interruptions during the firmware upgrade.
Inline power configuration:
Connect to the switch's command-line interface (CLI).

Enter the following commands to configure continuous power on all interfaces:
```
   configure terminal
   interface range <range_of_interfaces>
   power inline auto
 ```
>On CISCO switches there is no permanently-on PoE power on the interfaces, only AUTO or Disable. So don't be surprised to see AUTO.
{: .prompt-tip }

### Configuring the network adapter on the computer:
4.	Change the IPv4 address to static:
Go to your computer's network settings.
Configure the IPv4 address as follows:
IP address: 10.0.20.10
Subnet mask: 255.0.0.0

![Network settings](2024-06-17_11-39-24.webp){: .shadow }

### Launch Tftpd64 and configure it according to the provided screenshots.

**Tftpd64** - GLOBAL
![Tftpd64 - Settings - GLOBAL](2024-06-17_11-43-31.webp){: width="400" : .shadow }{: .right }

**Tftpd64** - Settings - TFTP
![Tftpd64 - Settings - TFTP](2024-06-17_13-29-07.webp){: width="700" : .shadow }{: .right }

**Tftpd64** - Settings - DHCP
![Tftpd64 - Settings - DHCP](2024-06-17_13-32-53.webp){: width="400" : .shadow }

## Connecting to the Cisco AP

**Use a console cable and Putty.exe:**

Connect to the Cisco AP using a console cable and Putty.exe.
Default credentials on a "clean" install:
-	***Username***: Cisco
-	***Password***: Cisco
-	***Enable password***: Cisco

![Enter enable mode CLI](2024-06-17_13-54-21.webp){:: .shadow }

## Configuring the CAPWAP IP address:
Enter the following command to configure the AP's IP address:

```
capwap ap ip 10.0.20.5 255.0.0.0 10.0.20.10
```

## Ping and firmware transfer:

Test the connection between the devices with the following commands:
Ping from the AP to the PC:

```
ping 10.0.20.10
```

Ping from the PC to the AP:
```
ping 10.0.20.5
```

##	Transferring the firmware to the Cisco AP:
Enter the following command to load the firmware onto the AP:
```
ap-type mobility-express tftp://10.0.20.10/AIR-AP2800-K9-ME-8-10-190-0.tar
```
>The firmware name may vary depending on the downloaded file.
{: .prompt-info }

![Loading the firmware onto the AP](img-install-firmware.png){:: .shadow }

# Configuration after installing Mobility Express:

![Firmware installation finished on the AP](2024-06-19_15-20-53.webp){:: .shadow }

## Configuring Mobility Express (minimal):
Follow the on-screen instructions for the initial configuration:

* ***Administrator name***: admin
* ***Administrator password***: Admin1
* ***AP system name***: AP-B1 (for AP Bay #1)
* ***AP username***: user
* ***AP password***: APuser1 (Enable Password for AP : APuser1)
* ***Country code***: FR
* ***Configure NTP server***: NO
* ***System time***: NO
* ***Interface IP address***: STATIC
* ***Management IP address***: 10.0.20.20
* ***Management subnet mask***: 255.0.0.0
* ***Management default router***: 10.0.20.1
* ***Create a management DHCP scope***: NO
* ***Management DHCP Scope***: NO
* ***Employee network name (SSID)***: AP-B1
* ***Employee network security***: PSK
* ***Employee PSK passphrase (8-63 characters)***: colbertAP
* ***Re-enter employee PSK passphrase***: colbertAP
* ***Enable RF parameter optimization***: NO
* ***Configure the internal AP in Flex+Bridge mode***: NO

After the reboot, you need to enter the following commands to enable the visual interface:
```
(Cisco Controller) >config network webmode disable
(Cisco Controller) >config network secureweb enable
```

The first command is for ***http***, the second for access via ***https***.

Once these steps are done, your Cisco access point should be upgraded to Mobility Express and ready to configure through the graphical interface in a browser.

```
10.0.20.20

Use
Administrator name: admin
Administrator password: Admin1
```

> Warning: the access page does not open in the Chrome browser (in my case), but works perfectly in the Edge browser.
{: .prompt-danger }

![GUI Mobility Express](2024-06-19_15-38-25.webp){:: .shadow }

## Restoring the default settings

To reset the settings, hold the access point's reset button while powering it on. Don't release it — a countdown should appear in the console. To restore factory settings, make sure the countdown exceeds 20 seconds.

After the reboot

Connect to the console with the default login/password pair:
Cisco – Cisco

enter the command (in enable mode)
```
#capwap ap ip 10.0.20.5 255.0.0.0 10.0.20.10
```
After some time (1-2 minutes), Mobility Express will start loading and you will need to go through the ***Mobility Express*** configuration process again.

![GUI Mobility Express](2024-06-19_15-01-03.webp){:: .shadow }

_Thank you for your attention!_
