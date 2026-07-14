---
title: Cloudflare Workers - from Tail Logs to four levels of structured logging
description: How I replaced a manual tail command with a Debug mode controlled from the dashboard, with executions correlated by run_id.
date: 2026-07-11
categories: [DevOps]
tags: [cloudflare, workers, observabilite, debug, logging, dashboard]
author: GoXLd
pin: false
toc: true
published: true
ads: true
mermaid: false
language: en
translation_key: debug-cloudflare-workers-logs-structures
permalink: /posts/en/debug-cloudflare-workers-logs-structures/
---

# Cloudflare Workers: stop hunting for a command, start by reading an execution

Hello everyone!

On May 8, my problem was not a lack of logs on my Cloudflare Workers. I already had `wrangler tail`. The problem was the path to get there: open a modal in the dashboard, copy a command, go to a terminal, provide a token, start the stream, then try to link lines of text to a specific execution.

That flow is acceptable for an exceptional intervention. It becomes painful as soon as the question is simple: *why did this worker skip its cycle?* or *at which stage did this failure happen?*

> In one sentence: I replaced the "Tail Logs" shortcut with a per-worker `Debug` button, **four levels** of logs and a `run_id` that links the start, stages, skips, success and error of a single execution.
{: .prompt-info }

## The starting point: logs available, but no diagnostic path

| Area | Initial state |
|---|---|
| Dashboard | A `Tail Logs` action copies a `wrangler` command |
| Terminal | The token must be entered before starting the stream |
| Worker | `silent`, `error` and `info` levels |
| Execution | Useful messages, but no systematic correlation between their stages |

The real flaw was how responsibility was split. The dashboard already knew the selected worker, its account and its state. Yet it sent the operator back to a shell before the first actionable piece of information.

The CLI command remains indispensable for some cases — notably a live tail from an admin machine — but it should no longer be the first tool for understanding a current state.

## The rule: debug must be temporary and explicit

I kept a very simple principle: the log level is a deployment configuration, not a checkbox that only affects the UI. Enabling debug redeploys the worker with `LOG_LEVEL=debug`; disabling it redeploys it with `LOG_LEVEL=error`.

>The rules applied to the flow:
>1. **One worker, one switch** — the action never targets an implicit group.
>2. **The level is read from the bindings** — the dashboard shows the actually configured state, not a local preference.
>3. **Debug stays temporary** — it serves an investigation, then goes back to `error`.
>4. **Secrets don't pass through the dashboard** — the CLI command keeps a silent token prompt when a terminal tail is needed.
{: .prompt-danger }

On the API side, the Workers list exposes `log_level`, `debug_enabled` and a URL to the observability events. The dashboard can therefore display `ON` or `OFF`, apply the toggle, then offer the `Logs` link only when debug is active.

```js
// The displayed state reflects the actually deployed configuration.
function workerDebugEnabled(worker) {
  return worker?.debug_enabled === true
    || String(worker?.log_level || '').trim().toLowerCase() === 'debug';
}
```

## Four levels instead of a binary stream

The change in the two Worker templates is not about printing more text everywhere. It introduces a hierarchy that lets you choose the acceptable noise.

| `LOG_LEVEL` level | Content |
|---|---|
| `silent` | No logs |
| `error` | Errors only |
| `info` | The main stages and the execution summary |
| `debug` | The extra details useful for an investigation |

The `debug` level sits above `info`: the essential stages remain readable without opening the details, and the targeted details only appear while hunting a problem. New Workers are provisioned with `LOG_LEVEL=error`; a mass redeploy keeps the already-set level instead of resetting it.

## An execution becomes a readable sequence

The second change matters more than the button. Every execution receives an identifier created at startup. The two templates then write structured events around that identifier: `run_start`, `run_skip`, `run_stage`, `run_end` and `run_error`.

```js
const runId = createRunId();
ctx.logInfo(`[run_start] id=${runId} trigger=${ctx.trigger}`);

// A final line links duration and counters to the same run_id.
ctx.logInfo(`[run_end] id=${runId} ok=true duration_ms=${durationMs}`);
```

The consequence is operational: a `run_skip` no longer looks like a mysterious absence. It carries a reason — for example `trigger_interval`, `cooldown`, `no_items` or `sleep_window`. An error keeps the same identifier and adds the counters available at the time of the failure. For a completed run, the summary includes the duration and the fetch and `429` response counters.

## The journey after the change

| Step | Before | After |
|---|---|---|
| Pick a worker | Open a modal and copy a command | Click `Debug` on its row |
| Enable details | Manually run `wrangler tail` | Redeploy that worker with `LOG_LEVEL=debug` |
| Read the events | Terminal stream without uniform correlation | `Logs` link and events tied together by `run_id` |
| Return to calm | Manually change the deployment | Disable `Debug`, redeploy at `error` |

The CLI hasn't disappeared. When needed, the documentation keeps a command that asks for the token with `read -s`, so it never lands in shell history. The dashboard doesn't replace admin access: it simply reduces the number of steps before a diagnosis.

## The honest part: debug is not free telemetry

The trap would have been leaving `debug` on by default. Details are useful when you're looking for a specific transition — an extracted list of links, a parsing stage, a skip reason — but they also increase the volume of logs to read. That's why provisioning starts at `error`, and why the `Debug` button is an explicit per-worker choice.

Another limitation: this work structures the application logs, it doesn't by itself guarantee that the cause of an incident lies in the Worker. A `run_error` can show the moment and the counters, but an external dependency or a bad configuration still requires the usual checks.

## Summary

| Element | Result |
|---|---|
| Log levels | **4**: `silent`, `error`, `info`, `debug` |
| Targeting | One `Debug` switch per worker |
| Correlation | One `run_id` per execution |
| Structured events | `run_start`, `run_skip`, `run_stage`, `run_end`, `run_error` |
| Return to the nominal level | Redeploy with `LOG_LEVEL=error` |

The progress is not having "more logs". It is matching the level of detail to the question being asked, then making a full execution readable as a single story.

For Workers that run regularly, the right question is therefore no longer "how do I start the tail?". It is: *which execution is running, where did it stop, and what level of information must be enabled to prove it?* When that answer starts in the dashboard and ends with a `run_id`, diagnosis becomes distinctly less mechanical.
