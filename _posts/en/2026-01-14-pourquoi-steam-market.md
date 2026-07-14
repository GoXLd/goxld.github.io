---
title: Why Steam Market is a great learning playground
description: A global, user-driven marketplace, useful for leveling up in scraping, data and economic logic.
date: 2026-01-14
tags: [steam, scraping, economie, data]
author: GoXLd
pin: false
toc: false
published: true
ads: true
image:
  path: img/steam/steammarket.jpg
  lqip: data:image/jpeg;base64,/9j/4QDKRXhpZgAATU0AKgAAAAgABgESAAMAAAABAAEAAAEaAAUAAAABAAAAVgEbAAUAAAABAAAAXgEoAAMAAAABAAIAAAITAAMAAAABAAEAAIdpAAQAAAABAAAAZgAAAAAAAABIAAAAAQAAAEgAAAABAAeQAAAHAAAABDAyMjGRAQAHAAAABAECAwCgAAAHAAAABDAxMDCgAQADAAAAAQABAACgAgAEAAAAAQAAABKgAwAEAAAAAQAAAAmkBgADAAAAAQAAAAAAAAAAAAD/4gHYSUNDX1BST0ZJTEUAAQEAAAHIAAAAAAQwAABtbnRyUkdCIFhZWiAH4AABAAEAAAAAAABhY3NwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAA9tYAAQAAAADTLQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAlkZXNjAAAA8AAAACRyWFlaAAABFAAAABRnWFlaAAABKAAAABRiWFlaAAABPAAAABR3dHB0AAABUAAAABRyVFJDAAABZAAAAChnVFJDAAABZAAAAChiVFJDAAABZAAAAChjcHJ0AAABjAAAADxtbHVjAAAAAAAAAAEAAAAMZW5VUwAAAAgAAAAcAHMAUgBHAEJYWVogAAAAAAAAb6IAADj1AAADkFhZWiAAAAAAAABimQAAt4UAABjaWFlaIAAAAAAAACSgAAAPhAAAts9YWVogAAAAAAAA9tYAAQAAAADTLXBhcmEAAAAAAAQAAAACZmYAAPKnAAANWQAAE9AAAApbAAAAAAAAAABtbHVjAAAAAAAAAAEAAAAMZW5VUwAAACAAAAAcAEcAbwBvAGcAbABlACAASQBuAGMALgAgADIAMAAxADb/2wCEAAEBAQEBAQIBAQIDAgICAwQDAwMDBAUEBAQEBAUGBQUFBQUFBgYGBgYGBgYHBwcHBwcICAgICAkJCQkJCQkJCQkBAQEBAgICBAICBAkGBQYJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCf/dAAQAAv/AABEIAAkAEgMBIgACEQEDEQH/xAGiAAABBQEBAQEBAQAAAAAAAAAAAQIDBAUGBwgJCgsQAAIBAwMCBAMFBQQEAAABfQECAwAEEQUSITFBBhNRYQcicRQygZGhCCNCscEVUtHwJDNicoIJChYXGBkaJSYnKCkqNDU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6g4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2drh4uPk5ebn6Onq8fLz9PX29/j5+gEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoLEQACAQIEBAMEBwUEBAABAncAAQIDEQQFITEGEkFRB2FxEyIygQgUQpGhscEJIzNS8BVictEKFiQ04SXxFxgZGiYnKCkqNTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqCg4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2dri4+Tl5ufo6ery8/T19vf4+fr/2gAMAwEAAhEDEQA/APuqD4ifETwV4um+C/iS3hvhp2m2GpTTXMIjjhW4VzHDIkW8M0flHCKMgAAnPJ5vxpN4yufCEcNvrVzYaLCjXJuLiP8A1dkMZDAKjRN5jbinLCMYNfQf7N3/ACXb4o/9ddJ/9EPWr+3r/wAmofED/sGW/wD6NFeFQoxliIQirX5fxS6H7FLHxhio4fk/l/FLpbzPzpl+EHhe3laC+8DzXkyErJPBLcrFKw4LoobhWPKjsKj/AOFTeDf+ifXX/f65/wDiq+/9C/5Aln/1wj/9BFatcn9t1j2edn//2Q==
language: en
translation_key: pourquoi-steam-market
permalink: /posts/en/pourquoi-steam-market/
---

# Why Steam Market is a great learning playground

When I run scraping and data-analysis experiments, I often come back to Steam Market.
Not because it is "about gaming", but because it is a **genuine distributed economic system**, with very real technical constraints.

At first glance the platform may look like it is only for gamers and geeks.
In practice, it is more like a modern collectibles market: scarcity, liquidity, speculation, arbitrage.
In other words, it is much closer to "real world" logic than to a simple mini-game.

> Steam Market is not just a place to trade virtual items: it is a full-scale laboratory for data engineering.
{: .prompt-info }

---

## Why this market is interesting

Steam Market works like a global marketplace:

- prices move continuously,
- buyers and sellers are real users,
- multiple currencies coexist,
- time zones change the traffic rhythms,
- through secondary platforms, some virtual items can be monetized.

So it is **not** a static dataset.
Valve even leaned very early into mechanics close to "rare" digital assets: some items carry a high collectible value, often tied to their limited availability.
With millions of active users, the scale quickly becomes massive.

*Example of CS2 market valuation:*
![Example of CS2 items market valuation](img/steam/cs2_market_cap.png){: .shadow }

It is a living environment — perfect for testing hypotheses about data collection and data quality.

---

## A useful bit of history

The topic becomes even clearer when you look at the service's history.

In 2012 Valve hired the economist Yanis Varoufakis as *Economist-In-Residence* to analyze the virtual economies around Steam.

> "Yanis Varoufakis is an academic economist, an author..."
> Born in Athens (1961), trained in mathematics, statistics and economics (PhD, University of Essex), he taught at several major universities in Europe and Australia.
> This academic trajectory explains why his time at Valve was taken seriously well beyond the gaming world.
{: .prompt-info }

As early as 2013, the *Financial Times* was already covering the economic reality of video-game virtual markets.
![Financial Times - video game economics](img/steam/ft.png){: .shadow }

Even though the article is old, it remains useful for understanding why this subject goes far beyond mere entertainment.

> Honestly, what is there left to argue about?
> When following this platform requires reading newspapers like the *Financial Times* and *Forbes*, the case is practically closed.
{: .prompt-tip }

- [Financial Times (archive)](https://archive.is/20230729204017/https://www.ft.com/content/151b8794-750f-11e2-a9f3-00144feabdc0)

He would later become Greece's Minister of Finance in 2015.

Additional references:
![Yanis Varoufakis' blog on Valveconomics](img/steam/yanis_blog.png){: .shadow }

- [Introducing Valveconomics](https://www.yanisvaroufakis.eu/2012/06/22/introducing-valveconomics-my-new-blog-with-research-notes-on-digital-economies/)
- [Interview on becoming Economist-In-Residence at Valve](https://www.yanisvaroufakis.eu/2012/07/11/interviewed-by-doug-henwood-on-my-new-position-as-economist-in-residence-at-valve-software/)
- [Valveconomics (Web archive, 2020)](https://web.archive.org/web/20200210025523/http://blogs.valvesoftware.com/economics)

The historic Valveconomics blog is now partially unavailable depending on the page and the access zone.
![Example of an inaccessible page](img/steam/access_denied.png){: .shadow }

> Web archives therefore remain essential to document the technical and economic history of the subject.
{: .prompt-warning }

---

## What Steam Market teaches on the engineering side

For a scraper, Steam Market is a good "gym":

- you have to handle price and availability variability,
- you have to handle multiple currencies and integrate reliable conversions to track real liquidity,
- you have to track volume and volatility effects: a single update can trigger very brutal moves.

For example, after a Valve update, the CS2 community went through heavy turbulence in skin valuations.

> "The Counter-Strike 2 community has been thrown into turmoil..."  
> Source: [Forbes (archive)](https://web.archive.org/web/20251204062315/https://www.forbes.com/sites/danidiplacido/2025/10/23/the-counter-strike-2-skins-market-crash-explained/)

- you have to work with sometimes-ancient endpoints and an API that evolves slowly,
- the ecosystem also rests on a lot of legacy code: it complicates automation, but it is very educational.

![Example of legacy code visible client-side](img/steam/codestyle.webp ){: .shadow }

- you have to distinguish blocking errors, quota errors, latency errors and data errors.

Above all, the "right" architecture does not depend only on code, but also on the **cost of acquiring the data**.
And if you like games, the learning loop is even more motivating.

---

## Why I keep using it as a test bed

On this kind of market, you can level up simultaneously on:

- **collection robustness** (huge volumes, very heterogeneous items),
- **observability** (*logs*, errors, retries, delays) to steer both the scraper and the infrastructure,
- **economic analysis** (supply, demand, spreads, drifts), which remains a complex field.

![Example of economic complexity](img/steam/economy_forest.jpg ){: .shadow }

- **product discipline**: which data is actually worth its acquisition cost?

My personal goal is to move quickly from "*I'm learning*" to "*I'm applying*".
A positive result (here, actually executable operations) is far more motivating than a mere `Hello, World`.

In short, Steam Market remains an excellent sandbox for strengthening both the technical side and the decision-making side.

![Experimentation sandbox](img/steam/sandbox.png ){: .shadow }

A concrete bonus: some well-mastered strategies can also generate real gains, since many items are monetized on secondary markets[^money].

> That potential exists, but you must always respect the platform's rules, local taxation and your accepted level of risk.
{: .prompt-danger }

---

## Respect for the ecosystem

This approach is also a way to salute the work of the Steam teams and their community:
without this ecosystem, many data experiments would not be nearly as educational.

[^money]: The income level depends heavily on item liquidity, transaction fees, price spreads and market volatility.
