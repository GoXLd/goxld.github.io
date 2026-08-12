---
title: Seven accepted contributions to the OVHcloud documentation
description: How I turned seven verifiable defects into fixes accepted by OVHcloud, from theme accessibility to Docker, OpenStack and Node.js commands.
date: 2026-08-10
categories: [DevOps]
tags: [devops, open-source, documentation, accessibilite, docker, nodejs, openstack]
author: GoXLd
pin: false
toc: true
published: true
ads: true
mermaid: false
media_subpath: /img/ovhcloud-contributions/
language: en
translation_key: sept-contributions-documentation-ovhcloud
permalink: /posts/en/sept-contributions-documentation-ovhcloud/
---

# Seven OVHcloud fixes: prove first, propose second

Hello everyone!

At the end of July, I set myself a simple goal: contribute to OVHcloud's public documentation without manufacturing work to fill a GitHub profile. No daily pull request quota, no cosmetic correction presented as a major incident. I wanted to find technical defects that I could demonstrate with official sources, fix within my area of expertise and verify before asking maintainers to review them.

The first cycle is now complete: **seven sets of corrections were accepted**, four directly from my pull requests and three after migration to internal repository branches. They cover **55 files** and seven languages, with changes ranging from React accessibility to Apache, Docker Compose, OpenStack and Node.js.

> In one sentence: seven accepted contributions, 55 corrected files, four direct merges and three internal migrations, with one constant rule: reproducible evidence before every change.
{: .prompt-info }

<!-- TODO: create a cover image showing the seven accepted PRs without private information. -->

## The starting point

The `ovh/ovhcloud-docs` repository is not a simple collection of Markdown pages. It contains the guides published in multiple languages, as well as the site's React theme, generation scripts and content checks. An apparently tiny correction can therefore affect seven language variants or change keyboard behavior across several layouts.

| Area | State observed before correction |
|---|---|
| Search filters | visual grouping without a native semantic HTML element |
| Sidebar navigation | an unrelated key could close the panel; `Enter` or `Space` could cause a `TypeError` |
| Apache examples | a negative `Require not host` without a positive provider in `RequireAll` |
| OpenStack guides | links to EOL Newton and the deprecated `nova boot` command |
| WordPress tutorial | a mix of Docker Compose v1 and v2, with an obsolete `version` field |
| Lovable guide | installation of Node.js 18 after its end of life |

The goal was not to hunt random typos. I limited myself to areas I could defend publicly: JavaScript and TypeScript, Shell, infrastructure commands, technical documentation and web accessibility.

## The method: authority before intuition

For each candidate, I followed the same loop: locate the defect in the current branch, check every copy, consult the official documentation of the relevant product, search for similar issues and pull requests, then build a measurable before/after invariant.

>My non-negotiable rules:
>1. **No PR without a concrete effect** — an obsolete command, broken keyboard behavior or a contradiction with an official specification.
>2. **No product assumptions** — if a behavior requires private access to OVHcloud Manager, I do not present it as a verified bug.
>3. **Every affected variant** — when a guide exists in seven languages, I check all seven files and their fallback relationships.
>4. **Proportionate validation** — tests and a browser for the theme; linting, parsing and exact invariants for guides.
{: .prompt-danger }

This method avoids two opposite traps: launching an expensive multi-locale build for a simple URL, or assuming that a command change is correct because it "looks like" current syntax.

## Accessibility: two defects in the React theme

The first accepted contribution, [PR #473](https://github.com/ovh/ovhcloud-docs/pull/473), replaces the generic wrappers around Pagefind filters with `fieldset` elements. The change spans two files: four CSS additions, then four additions and six deletions in the React component. The goal was not to change the rendering, but to give assistive technologies native grouping semantics.

Validation combined Biome, the project's tests, content and sidebar checks, all seven locale outputs, then a browser comparison of the computed dimensions before and after. The final commit was merged with my original commit retained as a parent of the merge.

[PR #474](https://github.com/ovh/ovhcloud-docs/pull/474) addressed a more visible defect. Five native buttons closed the sidebar on any `keyup`. At the same time, a custom `div[role="button"]` group called a mouse handler without passing it an event. The handler then attempted to call `stopPropagation()` on `undefined`.

The browser reproduction was deterministic: before the patch, `Enter` produced a `TypeError` and the group remained closed. After the patch, `Enter` opens it, `Space` closes it without scrolling the page, a key such as `A` no longer closes the panel, and clicking the overlay still works. Seven theme files were corrected, then the contribution was merged with my attribution.

## Apache: a negation that authorized nobody

The same example appeared in seven languages in the domain-blocking guides:

```apache
<RequireAll>
  Require not host domain.tld
</RequireAll>
```

The Apache 2.4 documentation states that a negative `Require` directive cannot authorize a request by itself and that `RequireAll` needs at least one positive provider. To express "allow everyone except this domain," `Require all granted` was therefore missing.

[PR #481](https://github.com/ovh/ovhcloud-docs/pull/481) corrected **14 blocks** in seven files. My invariant went from 0/14 to 14/14 blocks containing the positive provider immediately before `Require not host`. After approval, the change was migrated to [internal PR #545](https://github.com/ovh/ovhcloud-docs/pull/545), then merged with a `Co-authored-by` trailer preserving my attribution.

## OpenStack: moving on from Newton and `nova boot`

Two separate contributions addressed the same underlying problem: current guides still pointed readers to historical tools.

[PR #482](https://github.com/ovh/ovhcloud-docs/pull/482) replaced **18 links** to the 2016 OpenStack Newton documentation with the current OVHcloud guide for preparing an OpenStack environment. The old page still recommended Python 2.7, `easy_install` and a client without Python 3 support. The replacement uses Python 3, a virtual environment and `python-openstackclient`. The correction was merged through [PR #515](https://github.com/ovh/ovhcloud-docs/pull/515).

[PR #493](https://github.com/ovh/ovhcloud-docs/pull/493) then replaced `nova boot` with `openstack server create` in seven variants of the guide for launching a script when creating an instance. It also corrects `--key_name` to `--key-name` and a malformed variant of `--user-data`. I compared the syntax against the current OpenStackClient reference without claiming to have performed a real instance creation: neither the CLI nor a test cloud was available locally. The patch was merged through [PR #516](https://github.com/ovh/ovhcloud-docs/pull/516).

## Docker Compose: making the tutorial consistent

The WordPress tutorial installed Docker Compose 1.29.2 as a standalone binary, then mixed `docker-compose` and `docker compose`. On a clean machine, the listed packages did not necessarily provide the plugin expected by the v2 commands in the same guide.

[PR #483](https://github.com/ovh/ovhcloud-docs/pull/483) migrated all seven variants to the `docker-compose-plugin` package, removed the standalone download, normalized the v2 commands and removed the now-obsolete Compose `version` field.

I extracted and parsed **14 YAML fragments**, checked the structure of the `db` and `wordpress` services, then verified the absence of the legacy binary, the old URL and the obsolete field. Docker was not installed on the validation machine, so I did not present this work as a container runtime test. During review, the maintainer confirmed that the patch fixed the broken Compose v1 dependency and cleaned up the commands in every language before approving it.

## Node.js: replacing an LTS release that reached end of life

[PR #496](https://github.com/ovh/ovhcloud-docs/pull/496) has the smallest diff: two lines changed in each of the seven languages. The guide for importing a Lovable site used the NodeSource `setup_18.x` script, although Node.js 18 had reached end of life on March 27, 2025.

The replacement with `setup_24.x` was checked in all seven files and against the NodeSource endpoint. The maintainer explicitly confirmed the value of the update: readers now install a supported LTS version instead of a runtime that no longer receives upstream fixes.

## The honest part: code was not always the blocker

Three contributions were not merged from my fork branches. The internal CDS system did not trigger correctly on them, so the maintainers recreated the changes on branches in the main repository. The original PRs #481, #482 and #493 appear closed, but their replacements #545, #515 and #516 were merged.

This distinction matters: a closed PR is not necessarily rejected, and approval is not yet a merge. To track an external contribution properly, you have to follow the replacement links through to the final commit.

The first transfer also taught me a lesson about attribution. The final commit for #516 retained neither my original authorship nor a `Co-authored-by` trailer. The maintainer explained that she had removed the trailer out of caution over a personal address already public in the commits, without realizing that this also removed the GitHub credit. Rewriting shared history was not reasonable. Since then, I add an attribution request to every PR that may be migrated; subsequent merges have retained either my original commit or a co-author trailer.

> The technical result and its attribution are two separate checks. Once the patch is merged, I inspect the final commit, not only the "Merged" badge on the original PR.
{: .prompt-warning }

## Results

| Contribution | Scope | Upstream result |
|---|---:|---|
| [#473](https://github.com/ovh/ovhcloud-docs/pull/473) — semantic filters | 2 files | direct merge |
| [#474](https://github.com/ovh/ovhcloud-docs/pull/474) — sidebar keyboard behavior | 7 files | direct merge |
| [#481](https://github.com/ovh/ovhcloud-docs/pull/481) → [#545](https://github.com/ovh/ovhcloud-docs/pull/545) — Apache | 7 files | internal migration, merge |
| [#482](https://github.com/ovh/ovhcloud-docs/pull/482) → [#515](https://github.com/ovh/ovhcloud-docs/pull/515) — OpenStack links | 18 files | internal migration, merge |
| [#483](https://github.com/ovh/ovhcloud-docs/pull/483) — Docker Compose v2 | 7 files | direct merge, approved |
| [#493](https://github.com/ovh/ovhcloud-docs/pull/493) → [#516](https://github.com/ovh/ovhcloud-docs/pull/516) — OpenStack command | 7 files | internal migration, merge |
| [#496](https://github.com/ovh/ovhcloud-docs/pull/496) — Node.js 24 LTS | 7 files | direct merge, approved |
| **Total** | **55 files** | **7 accepted corrections** |

Across the original diffs, this cycle represents **157 additions and 246 deletions**. These figures describe the Git scope, not a measure of value: the Node.js correction changes only 14 lines in total but avoids recommending an EOL runtime; the two files in #473 directly affect the semantics of the search engine.

## What I learned

Contributing to serious technical documentation is less like "correcting text" and more like a small engineering investigation. You have to distinguish a merely old page from a genuinely dangerous instruction, a style preference from a contradiction with official documentation, and targeted validation from a runtime test you did not perform.

The most useful point is not the number of PRs. It is the method that lets me reject an insufficiently proven idea, then defend precisely the one I submit: an upstream source, complete scope, a before/after invariant and explicit validation limits.

This first cycle has been accepted, but the work continues. Three other contributions remain open; they will only count in a summary if they actually reach the upstream branch. The question is therefore no longer "how many PRs can I open?" but **"which improvement can I prove without asking the maintainer to take my word for it?"**
