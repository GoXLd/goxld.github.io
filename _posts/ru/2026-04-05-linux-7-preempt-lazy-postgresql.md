---
title: Linux 7.0 и PostgreSQL на ARM64 — разбор регрессии
description: Почему pgbench проседает почти вдвое на Linux 7.0-rc с ARM64 и что проверить перед выкаткой в прод.
date: 2026-04-05
tags: [linux, postgresql, arm64, performance, kernel]
author: GoXLd
pin: false
toc: false
published: true
ads: true
image:
  path: img/linux-amazon/linux-postgressql.webp
  lqip: data:image/jpg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAA4KCw0LCQ4NDA0QDw4RFiQXFhQUFiwgIRokNC43NjMuMjI6QVNGOj1OPjIySGJJTlZYXV5dOEVmbWVabFNbXVn/2wBDAQ8QEBYTFioXFypZOzI7WVlZWVlZWVlZWVlZWVlZWVlZWVlZWVlZWVlZWVlZWVlZWVlZWVlZWVlZWVlZWVlZWVn/wAARCAAJABIDASIAAhEBAxEB/8QAGQAAAgMBAAAAAAAAAAAAAAAAAAUBAwQG/8QAIxAAAgICAQIHAAAAAAAAAAAAAQIAAwQFESFyFDEyMzRxsf/EABUBAQEAAAAAAAAAAAAAAAAAAAEE/8QAGxEAAgIDAQAAAAAAAAAAAAAAAAECEQMEITH/2gAMAwEAAhEDEQA/AOx2G+qwMo470u5ABJBHHWKNznXeMRqbbK0epXChuOORG+x+WfoSMn1V9i/kNiKeNVxkmRSlas2Ybs2HQzMSTWpJJ8+kJdT7KdohBeFCXD//2Q==
language: ru-RU
translation_key: linux-7-preempt-lazy-postgresql
permalink: /posts/ru/linux-7-preempt-lazy-postgresql/
---

# Linux 7.0 и PostgreSQL на ARM64 — разбор регрессии

В тестовой ветке Linux 7.0 Сальваторе Дипьетро (Amazon) обнаружил серьёзную регрессию: на PostgreSQL (`pgbench simple-update`) производительность на ARM64 падает почти вдвое ([LKML](https://lore.kernel.org/lkml/20260403191942.21410-1-dipiets@amazon.it/)).

По опубликованным цифрам результат падает примерно с **98 565** до **50 751** операций.
Поскольку Linux 7.0 находится в финальной фазе валидации (`v7.0-rc6`), тема напрямую касается админов и команд разработки ([kernel.org](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/?h=v7.0-rc6)).

![Сравнение производительности PostgreSQL на Linux 7.0](img/linux-amazon/compare.png){: .shadow }

## Что сломалось

Основная причина связана с планировщиком ([коммит](https://web.git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=7dadeaa6e851), [разбор в LKML](https://lore.kernel.org/lkml/yr3inlzesdb45n6i6lpbimwr7b25kqkn37qzlvvzgad5hfd7ut@xv4cihno76wu/)):

- режим вытеснения по умолчанию на затронутых архитектурах сменился с `PREEMPT_NONE` на `PREEMPT_LAZY`,
- PostgreSQL в user space начинает тратить намного больше CPU в `s_lock()` (до 55% процессорного времени по опубликованному анализу),
- следствие — заметное падение пропускной способности и отзывчивости под типичной OLTP-нагрузкой.

Классический пример: изменение в ядре может сильно ударить по приложению даже без единой правки в коде самого приложения.

## Обсуждаемые пути исправления

Из обсуждений выделяются два подхода:

1. Вернуть поведение по умолчанию, близкое к `PREEMPT_NONE`, исправив регрессию на стороне ядра ([предложенный патч](https://lore.kernel.org/lkml/20260403191942.21410-2-dipiets@amazon.it/)).
2. Адаптировать PostgreSQL к свежим механизмам ядра (включая `rseq slice`), чтобы снизить вероятность вытеснения в критической секции ([ответ Питера Зейлстры](https://lore.kernel.org/lkml/20260403213207.GF2872@noisy.programming.kicks-ass.net/), [тред про rseq slice](https://lore.kernel.org/all/20251215155615.870031952@linutronix.de/T/#u)).

Проще говоря: откат на стороне ядра или адаптация на стороне user space. Тот же выбор подчёркивают и на OpenNET; финальное решение — за основным мейнтейнером ([OpenNET](https://www.opennet.ru/opennews/art.shtml?num=65143)).

![Переписка разработчиков Linux и Amazon](img/linux-amazon/conversation.png){: .shadow }

## Почему это важно для прода

- PostgreSQL — одна из самых распространённых СУБД в проде.
- ARM64 давно не нишевый сегмент: облака, edge и универсальные серверы.
- Падение почти в 2 раза в конце релизного цикла — реальный прод-риск, а не микрофлуктуация.

## Что я рекомендую перед миграцией

Прежде чем переходить на Linux 7.0 (или дистрибутив с ним):

- прогоните свой реальный профиль `pgbench` на ARM64,
- сравните результаты между текущим ядром и 7.0-rc,
- следите за lock-heavy нагрузками и латентностью p95/p99,
- не соглашайтесь на прод-миграцию без прямого бенчмарка на вашей нагрузке.

> Универсального ответа в духе «обновляем везде» не существует.
> Правильная последовательность: замерить на своей нагрузке, затем постепенная выкатка.
{: .prompt-warning }

## Источники

- [Сообщение в LKML от Amazon](https://lore.kernel.org/lkml/20260403191942.21410-1-dipiets@amazon.it/)
- [Ветка Linux v7.0-rc6](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/?h=v7.0-rc6)
- [Обсуждаемый коммит](https://web.git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=7dadeaa6e851)
- [Дополнительное обсуждение в LKML](https://lore.kernel.org/lkml/yr3inlzesdb45n6i6lpbimwr7b25kqkn37qzlvvzgad5hfd7ut@xv4cihno76wu/)
- [Предложение вернуться к PREEMPT_NONE](https://lore.kernel.org/lkml/20260403191942.21410-2-dipiets@amazon.it/)
- [Ответ Питера Зейлстры](https://lore.kernel.org/lkml/20260403213207.GF2872@noisy.programming.kicks-ass.net/)
- [Обсуждение `rseq slice`](https://lore.kernel.org/all/20251215155615.870031952@linutronix.de/T/#u)
- [Разбор на OpenNET](https://www.opennet.ru/opennews/art.shtml?num=65143)
