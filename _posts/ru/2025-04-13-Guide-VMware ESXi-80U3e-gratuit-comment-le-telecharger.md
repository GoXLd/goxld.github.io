---
title: Гайд — VMware ESXi 8.0U3e снова бесплатен, как его скачать
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
language: ru-RU
translation_key: guide-vmware-esxi-80u3e-gratuit-comment-le-telecharger
permalink: /posts/ru/guide-vmware-esxi-80u3e-gratuit-comment-le-telecharger/
---

# VMware ESXi снова доступен в бесплатной версии с обновлением 8.0U3e — скачайте прямо сейчас

![vmware vsphere 8 free](build_details.png){: .shadow }

## **Цель:** скачать и использовать бесплатную версию VMware vSphere Hypervisor 8.0U3e, анонсированную Broadcom 11 апреля 2025 года.

## 🚨 Большая новость в мире виртуализации

Прекратив общую доступность бесплатной версии **VMware ESXi**, Broadcom передумала и снова открыла **бесплатную версию ESXi 8.0U3e** через свой портал поддержки.

В [официальных примечаниях к релизу](https://techdocs.broadcom.com/us/en/vmware-cis/vsphere/vsphere/8-0/release-notes/esxi-update-and-patch-release-notes/vsphere-esxi-80u3e-release-notes.html) сказано:

> *« Broadcom makes available the VMware vSphere Hypervisor version 8, an entry-level hypervisor. You can download it free of charge from the Broadcom Support portal. »*

Этот разворот позволяет любому человеку без платного контракта поддержки снова использовать **гипервизор ESXi** для своих лабораторий и тестовых сред.

## 🧭 Как бесплатно скачать VMware ESXi 8.0U3e

1. Создайте бесплатный аккаунт на портале поддержки Broadcom:  
   👉 [https://support.broadcom.com/group/ecx/free-downloads](https://support.broadcom.com/group/ecx/free-downloads)

2. Перейдите в раздел **Free Downloads**.

3. Пролистайте страницу до **VMware vSphere Hypervisor**.

>Введите vSphere в поиске и перейдите к VMware vSphere Hypervisor.
{: .prompt-tip }

![vmware vsphere 8 free](download-1.png){: .shadow }

Нажмите на ссылку **8.0U3e**.

Примите **Условия использования**.

![vmware vsphere 8 free](terms_and_conditions.png){: .shadow }

Нажмите на иконку **облака**, чтобы начать загрузку.

## Установка

Для проверки я запустил установку в своей домашней лаборатории (виват ProXmoX):

![vmware vsphere 8 free](proxmox.png){: .shadow }

Никаких проблем с «дрейнером» процессора (нужно использовать параметр **host**).  
Ведь из коробки доступна широкая поддержка:  
**ESXi 8.0 Update 3e** добавляет поддержку **vSphere Quick Boot** для:  
- **Intel vRAN Baseband Driver**  
- **Intel Platform Monitoring Technology Driver**  
- **Intel Data Center Graphics Driver**  
- **AMD Instinct MI Series Driver**

Но, в отличие от процессора, сетевую карту нужно эмулировать как **VMware vmxnet3**

Все мои тестовые настройки виртуальной среды — на скриншоте:

![vmware vsphere 8 free](hardware_proxmox.png){: .shadow }

## 🔐 А что с лицензией?

Отдельная лицензия не нужна! Вот детали:

**Продукт:** vSphere 8 Hypervisor

**Дата истечения:** Никогда — то есть лицензия бесплатная и постоянная, она не истекает.

**Возможности:**

Виртуальный SMP до 8 потоков (Up to 8-way virtual SMP) — каждая виртуальная машина может иметь до 8 виртуальных процессоров (vCPU).

![vmware vsphere 8 free](licence.png){: .shadow }

Бесплатная версия ESXi 8.0U3e поставляется со **встроенной лицензией**, как это было в старых бесплатных версиях ESXi. Это сильно упрощает развёртывание в лабораторных средах.

## ❓ Почему такой разворот?

Сложно сказать, что побудило Broadcom вернуть бесплатную редакцию. Чтобы возродить интерес к VMware? Чтобы противостоять росту альтернатив вроде **Proxmox**, **XCP-ng** или **Hyper-V**?  
Как бы то ни было, это даёт ESXi второе дыхание в некоммерческих средах.

> «Многим энтузиастам и студентам в кибербезопасности нужен простой, стабильный и бесплатный гипервизор. Эта версия пришлась очень кстати.»  
{: .prompt-info }

## ✅ Вывод

Бесплатный VMware ESXi 8.0U3e — отличная возможность для всех, кто хочет **экспериментировать**, **тестировать** или **учиться** без коммерческих обязательств.  
Скачайте его бесплатно прямо сейчас и пользуйтесь одним из самых мощных гипервизоров на рынке!

**🔗 Прямая ссылка на загрузку:**  
👉 [Broadcom Support Portal – Free VMware ESXi](https://support.broadcom.com/group/ecx/productfiles?subFamily=VMware%20vSphere%20Hypervisor&displayGroup=VMware%20vSphere%20Hypervisor&release=8.0U3e&os=&servicePk=&language=EN&freeDownloads=true)

**📅 Дата публикации:** 13 апреля 2025  
**🖥️ Версия:** VMware vSphere Hypervisor 8.0U3e

_Статья написана GoXLd — энтузиастом виртуализации и защищённой инфраструктуры._
