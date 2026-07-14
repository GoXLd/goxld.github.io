---
title: Guide – VMware ESXi 8.0U3e free again, how to download it
date: 2025-04-13 12:00:00
categories: [Virtualisation, VMware]
tags: [vmware, esxi, broadcom, hyperviseur, gratuit]     #TAG names should always be lowercase
author: GoXLd
pin: false
toc: false
published: true
media_subpath: /img/vmware-esxi/
image:
  path: esxi-8-free.webp
  lqip: data:image/webp;base64,/9j/4AAQSkZJRgABAQEASABIAAD/2wBDAAYEBQYFBAYGBQYHBwYIChAKCgkJChQODwwQFxQYGBcUFhYaHSUfGhsjHBYWICwgIyYnKSopGR8tMC0oMCUoKSj/2wBDAQcHBwoIChMKChMoGhYaKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCj/wAARCAAOABcDASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6/9oADAMBAAIRAxEAPwD6R1i5dZo4oxcjA3ExRs306fjx/SuR+JF+E0u2lu3nSzc+UyeWQWkwTypIx90Y+v1rs7i0sLqQyXFpHI5GCWQHPGP5Vy/xEl0608PJC1gkpLt5CMMIjlSCxAPoxx7+lc3JGfuz2HKdWEW6DSl0uYnw21OyXUnSzuhHZ/MpSUhOeo4J5JwfwBorjvA+j3HibxkHMsFrDaRvK0caYX5ht+VfUkjPPQYHAAop+xhS92Gw1OrOKddpytrZWR//2Q==
language: en
translation_key: guide-vmware-esxi-80u3e-gratuit-comment-le-telecharger
permalink: /posts/en/guide-vmware-esxi-80u3e-gratuit-comment-le-telecharger/
---

# VMware ESXi is back as a free edition with update 8.0U3e – download it now

![vmware vsphere 8 free](build_details.png){: .shadow }

## **Goal:** download and use the free edition of VMware vSphere Hypervisor 8.0U3e, announced by Broadcom on April 11, 2025.

## 🚨 Big news in the virtualization world

After ending the general availability of the free edition of **VMware ESXi**, Broadcom has reversed its decision and is once again offering a **free edition of ESXi 8.0U3e** through its support portal.

In the [official release notes](https://techdocs.broadcom.com/us/en/vmware-cis/vsphere/vsphere/8-0/release-notes/esxi-update-and-patch-release-notes/vsphere-esxi-80u3e-release-notes.html), you can read:

> *« Broadcom makes available the VMware vSphere Hypervisor version 8, an entry-level hypervisor. You can download it free of charge from the Broadcom Support portal. »*

This change of course allows anyone without a paid support contract to use the **ESXi hypervisor** again for their labs and test environments.

## 🧭 How to download VMware ESXi 8.0U3e for free

1. Create a free account on the Broadcom support portal:  
   👉 [https://support.broadcom.com/group/ecx/free-downloads](https://support.broadcom.com/group/ecx/free-downloads)

2. Go to the **Free Downloads** section.

3. Scroll down to **VMware vSphere Hypervisor**.

>Type vSphere in the search box and open VMware vSphere Hypervisor.
{: .prompt-tip }

![vmware vsphere 8 free](download-1.png){: .shadow }

Click the **8.0U3e** link.

Accept the **Terms and Conditions**.

![vmware vsphere 8 free](terms_and_conditions.png){: .shadow }

Click the **cloud** icon to start the download.

## Installation

To verify, I ran the installation in my home lab (vivat ProXmoX):

![vmware vsphere 8 free](proxmox.png){: .shadow }

No issues with the CPU "drainer" (you need to use the **host** parameter).  
Broad support is available right from the start:  
**ESXi 8.0 Update 3e** adds **vSphere Quick Boot** support for:  
- **Intel vRAN Baseband Driver**  
- **Intel Platform Monitoring Technology Driver**  
- **Intel Data Center Graphics Driver**  
- **AMD Instinct MI Series Driver**

Unlike the CPU, however, the network card must be emulated as **VMware vmxnet3**

All my test settings for the virtual environment are in the screenshot:

![vmware vsphere 8 free](hardware_proxmox.png){: .shadow }

## 🔐 What about the license?

No separate license needed! Here are the details:

**Product:** vSphere 8 Hypervisor

**Expiration date:** Never – meaning the license is free and permanent, it does not expire.

**Features:**

Up to 8-way virtual SMP – each virtual machine can have up to 8 virtual processors (vCPU).

![vmware vsphere 8 free](licence.png){: .shadow }

The free ESXi 8.0U3e edition ships with a **built-in license**, similar to the one offered in the older free ESXi editions. This makes deployment much easier for lab environments.

## ❓ Why this U-turn?

Hard to say what motivated Broadcom to reactivate the free edition. Is it to revive interest in VMware? To counter the growth of alternatives like **Proxmox**, **XCP-ng** or **Hyper-V**?  
Either way, it gives ESXi a second wind in non-commercial environments.

> "Many enthusiasts and cybersecurity students need a simple, stable, free hypervisor. This release comes at just the right time."  
{: .prompt-info }

## ✅ Conclusion

Free VMware ESXi 8.0U3e is a great opportunity for anyone who wants to **experiment**, **test** or **learn** without a commercial commitment.  
Download it for free right now and enjoy one of the most powerful hypervisors on the market!

**🔗 Direct download link:**  
👉 [Broadcom Support Portal – Free VMware ESXi](https://support.broadcom.com/group/ecx/productfiles?subFamily=VMware%20vSphere%20Hypervisor&displayGroup=VMware%20vSphere%20Hypervisor&release=8.0U3e&os=&servicePk=&language=EN&freeDownloads=true)

**📅 Published:** April 13, 2025  
**🖥️ Version:** VMware vSphere Hypervisor 8.0U3e

_Article written by GoXLd – virtualization and secure infrastructure enthusiast._
