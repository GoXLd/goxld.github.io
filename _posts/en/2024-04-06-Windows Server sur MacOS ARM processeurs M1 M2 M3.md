---
title: Guide - Windows Server on MacOS ARM (M1 M2 M3 processors)
date: 2024-04-06 11:00:00
categories: [MacOS]
tags: [macbook, arm, m1, m2, m3, virtualisation]     #TAG names should always be lowercase
author: GoXLd
pin: false
toc: false
published: true
media_subpath: /img/ws2022/
image:
  path: preview_ws2022.jpg
  lqip: data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAICAgICAgICAgIDAgICAwQDAgIDBAUEBAQEBAUGBQUFBQUFBgYHBwgHBwYJCQoKCQkMDAwMDAwMDAwMDAwMDAz/2wBDAQMDAwUEBQkGBgkNCgkKDQ8ODg4ODw8MDAwMDA8PDAwMDAwMDwwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAz/wAARCAAKABMDAREAAhEBAxEB/8QAGAAAAgMAAAAAAAAAAAAAAAAAAAUEBwn/xAAxEAAABAMDBw0AAAAAAAAAAAABAgMEAAURBjI0CBIhNTZRYgcTFBciIzEzN2FkkZT/xAAZAQACAwEAAAAAAAAAAAAAAAADBQACBAb/xAAuEQAAAwUECAcAAAAAAAAAAAAAAQIDBAURMRITIUIiMlFhcYGCkRQzQUPB0fD/2gAMAwEAAhEDEQA/AEjKxcmkRXrudos00StzCyO+fGl5BcFEM0oCUpueGlexTiqEJYG5w95bKS/vHh0ERSVhpKnq6VJFiHkQem7FCTYovDM8S2FKuHYTXFl7MzuVGPKmctUcuFkyS5VjaBOYqkSITOcdKYAQimkw92oGgAAQMFaQzjkFhbq73rk93yiURGkyTiSp4psnllpFvAXJ9eWrSy1Z2CkZz4fYR9WPxh+o5OyGtsGWPsXyfak2mcYzxwJvJ4t/tG1lXLTNq9XxvGdn615VFMZK3rMXUuzkzu4i6nc4d8WPy/ark4GIvr50/bBpB+CAAfcf/9k=
language: en
translation_key: windows-server-sur-macos-arm-processeurs-m1-m2-m3
permalink: /posts/en/windows-server-sur-macos-arm-processeurs-m1-m2-m3/
---

# Installing Windows Server 2022 on an arm computer — Macbook M2, for learning purposes

## About the experiment:
These notes apply to every Macbook Air/Pro based on the arm-architecture M1 M2 M3 processors.

My Macbook Air M2 8/256 2022

### DISCLAIMER
>I am just a hobbyist and experimenter who likes complex challenges and simple solutions, but during this experiment my Macbook was severely overheating (the lack of an active cooling system takes its toll). Before repeating this, read to the end.
{: .prompt-danger }

![iStat Menus](2024-04-06_11-16-32.webp){: .shadow : .right} I recommend installing the iStat Menus sensors.


---

## Installing via UTM

Required applications/libraries/links:
- Install brew
   Command to run in the terminal:
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```
   Detailed installation instructions are available on the [official site](https://brew.sh/).

- Install the xcode developer tools
   Command to run in the terminal:
```bash
xcode-select --install
```    
- Install UTM
   Command to run in the terminal:
```bash
brew install utm
```
- Install qemu
   Command to run in the terminal:
```bash
brew install qemu
```

 Download the Windows Server 2022 disk image [here](https://www.microsoft.com/fr-fr/evalcenter/download-windows-server-2022).

## Installing Windows Server

![UTM setup menu](2024-04-06_11-32-38.webp){: .shadow }

Select the emulation process rather than virtualization, since we plan to use a system image built for a different architecture.

![UTM setup menu](2024-04-07_16-43-40.webp){: .shadow }

Do not pick "other system" — we will install with the Windows 10/11 presets. I tried several times to install via "Autre", but the built-in BIOS would not even boot or detect the system image. So learn from my experience and choose Windows 10/11.

![UTM setup menu](2024-04-07_16-44-45.webp){: .shadow }

Select your system image — I used an official Windows Server 2022 image with the March 2024 updates (as of writing, April 2024). Leave the other checkboxes as they are — do it as shown in the screenshot.

![UTM setup menu](2024-04-07_16-46-03.webp){: .shadow }

**VERY IMPORTANT!** I read a lot on the internet about emulating Windows Server, and there are many negative reviews of this approach, saying it is very slow and unstable. But in my case (again, Macbook Air M2 8/256) everything runs at an acceptable level, although the temperature during installation is frightening. After all, I need the system for learning, not for deploying a real data center.

>The first time I installed WS, I also found everything very slow and far too buggy. Imagine my surprise when I realized that with the default settings, UTM was trying to install Windows while emulating only one CPU core. 1! It is strange nobody mentions this, given the lag and stutter of the emulated system.
{: .prompt-warning }

![Task Manager of the installed system with the default emulated CPU settings](2024-04-06_01-21-55.webp){: .shadow }
Working in such a system, even for learning, was impossible.

**SOLUTION:** Set the cores manually. For testing purposes I set 4 cores, and both the installation and the boot of the new system were much faster. On a Macbook Pro you can probably allocate more cores.

For RAM, the more the better. I chose 4 GB, but if I had a 16 GB Macbook I would have picked 8 GB. The logic is simple.

![UTM setup menu](2024-04-07_16-48-52.webp){: width="700" height="400" : .shadow }

Choose the persistent storage size according to your needs (and means).

Afterwards the installer asked me to pick a shared folder for files (you can do this later, but in my case I created a separate directory for WS).

![UTM setup menu](2024-04-07_16-51-09.webp){: .shadow }

The installer summarizes all the settings we entered for final confirmation.
![UTM setup menu](2024-04-07_16-52-09.webp){: .shadow }

Now the system appears in the UTM selection window.
![UTM setup menu](2024-04-07_16-52-49.webp){: .shadow }

Launch it

On first boot I landed on this screen — solved by typing the command

![UTM setup menu](2024-04-07_16-53-53.webp){: .shadow }

```bash
exit
```

And without changing any BIOS settings — do a reset
![UTM setup menu](2024-04-07_16-54-46.webp){: .shadow }

## "Press any key to load ..."

Press any key

And after a while you will see the familiar Windows setup window.

![UTM setup menu](2024-04-07_16-57-23.webp){: .shadow }

### Installation tips:

During the Windows Server installation, remember to pick the right edition:
<!-- markdownlint-capture -->
<!-- markdownlint-disable -->
> A few notes:
- Desktop Experience gives you the graphical interface familiar from desktop versions of **Windows**.
- The Datacenter edition lets you create virtual accounts (system users)
{: .prompt-info }
<!-- markdownlint-restore -->

For my learning purposes I will install Windows Server 2022 (Desktop Experience) with a Datacenter license.

Now pay attention to the temperatures during installation:
![UTM installation](2024-04-06_00-53-47.webp){: .shadow }

After installation you will see the standard Windows lock screen asking you to press Ctrl + Alt + Delete to unlock, but since those keys do not exist, here is an answer from the UTM GitHub [link to the post](https://github.com/utmapp/UTM/issues/3413#issuecomment-1001997191) (GoXLd: another solution — you can always plug in a standard WIN keyboard)

![Windows Server 2022](2024-04-07_17-53-27.webp){: .shadow }

Also remember that on first boot the system needs to install the UTM Guest Tool.

![Windows Server 2022](2024-04-05_20-30-11.webp){: .shadow }
To me, running Windows Server this way on an M2 8/256 is pure masochism. A system with more finely tuned emulation works much better (fewer crashes and freezes), but it is still nowhere near the smoothness of virtualization. By the way, while Windows Server 2022 is running there is no overheating — the Macbook's average temperature stays around 70–80 degrees.
>Perhaps on my 'weak' computer it is worth trying older (less hardware-demanding) versions
{: .prompt-tip }
Do not forget to remove the WS ISO
![Windows Server 2022](2024-04-07_18-31-38.webp){: .shadow }

Windows Server 2022

![Windows Server 2022](2024-04-07_20-24-44.webp){: .shadow }

>Final conclusion: given the lack of active cooling and the resource cost of emulating x86_64, running Windows Server 2022 is a very dangerous exercise that can lead to rapid degradation of the CPU and the failure of the computer. Booting it on MacBook Pro models also remains uncertain. But on the base configuration of any MacBook Air (in 2024) — just don't, don't even try.
{: .prompt-danger }

_Thank you for your attention!_
