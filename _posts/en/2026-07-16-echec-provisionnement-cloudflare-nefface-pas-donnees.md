---
title: A Cloudflare provisioning failure should not erase data that has already been created
description: How I replaced a destructive rollback with success plus a warning and explicit compensation when a Cloudflare deployment fails halfway through
date: 2026-07-16
categories: [DevOps]
tags: [cloudflare, workers, directus, api, fiabilite, rollback]
author: GoXLd
pin: false
toc: true
published: true
ads: true
mermaid: false
language: en
translation_key: echec-provisionnement-cloudflare-nefface-pas-donnees
permalink: /posts/en/echec-provisionnement-cloudflare-nefface-pas-donnees/
---

# A Worker can fail without making everything else disappear

On May 20, I added automatic Cloudflare Worker provisioning whenever I create a new item in my application. The idea was practical: a single action in the dashboard created the data, prepared its collection and deployed the Worker that would use it.

The problem appeared in the error path. If the Cloudflare deployment failed after the data had been created, the API deleted the item and, if it had just been created, its collection. An infrastructure error was treated as if the entire business request had never existed.

> In one sentence: on May 28, I replaced a rollback that deleted business data with success plus a warning, along with an explicit attempt to clean up the partially created Worker.
{: .prompt-info }

## The starting point: one action, several systems

A creation from the dashboard chained together several operations with different guarantees: an application database, a data collection and the Cloudflare API. There was no SQL transaction across that boundary: each step could succeed while the next one failed.

| Area | Behavior before the fix |
|---|---|
| Business item | Deleted if automatic Worker deployment failed |
| Collection created during the request | Deleted as well |
| Partially created Worker | No dedicated cleanup in this path |
| API response | Error: the creation appeared to have failed completely |

This behavior looked clean on paper: "if everything is not deployed, roll everything back." In reality, it mixed two levels of responsibility. Creating the data is durable and replayable; deploying a Worker is an external dependency that can fail for transient or configuration-related reasons.

The worst-case scenario was therefore not just a missing Worker. It was data the user had just created, which the backend then deleted on their behalf to hide the failure of an external call.

## The rule: compensate only for what belongs to the deployment

I set a simple rule: a provisioning error must not undo an already valid business creation. However, if the external call left a Worker behind, the API must try to delete it and tell the client exactly what happened.

>The rules that became non-negotiable:
>1. **Do not delete the item or its collection** after an external deployment failure.
>2. **Clean up only the potentially orphaned Cloudflare resource**.
>3. **Return a successful response with a warning**: the client must know that the data exists, but the Worker needs attention.
{: .prompt-danger }

This is not a magical distributed transaction. It is targeted compensation: I do not claim that I can return several services to an atomic state, but I explicitly limit cleanup to the resource that may have been created by the last side effect.

## The fix: keep the data, track the compensation

The commit from **May 28, 2026** changes a single backend file: **49 additions** and **18 deletions**. The rollback block that erased the item and collection was replaced with Worker cleanup state.

```js
const cleanupState = {
  attempted: false,
  deleted: false,
  skipped: false,
  error: null
};

// The only side effect to compensate for is the external Worker.
await cloudflareApiRequest({
  method: 'DELETE',
  path: `/accounts/${accountId}/workers/scripts/${workerId}`,
  token,
  timeout: 45000
});
cleanupState.deleted = true;
```

The compensation also carries an important nuance: a `404` response during the `DELETE` is treated as successful cleanup. In this context, the goal is not to prove that the Worker existed; it is to guarantee that it no longer exists after processing.

The final response then distinguishes three readable cases: cleanup completed, cleanup skipped because the necessary context is missing, or cleanup attempted but failed. The API keeps this information in a dedicated warning field instead of burying it in a generic error.

| Situation after the Cloudflare failure | Response to the dashboard |
|---|---|
| Worker deleted, including when the API returns `404` | Creation successful with a cleanup-completed warning |
| Insufficient identifier or configuration | Creation successful with a cleanup-skipped warning |
| Cloudflare deletion failed | Creation successful with a cleanup-failed warning |

The frontend can therefore display a clear action: the data that was created is usable, while the deployment must be retried or checked. More importantly, a temporary provider error no longer turns a successful creation into a silent disappearance.

## The honest part: the first rollback was too aggressive

The culprit was my initial shortcut. I had treated "automatic provisioning" as an indivisible operation and chosen a full rollback to avoid incomplete states. It was reassuring, but wrong: a collection and an application item are not the same thing as a remote Worker.

The new code does not promise that there will never be an intermediate state either. If Worker cleanup fails, a resource may remain and need attention. The difference is that this state is now **reported**, preserved on the business side and therefore recoverable without asking the user to recreate their data.

Another deliberate limitation: I did not add deferred automatic deletion or a background retry in this fix. The commit stays focused on the request response: do not destroy anything by mistake, attempt compensation immediately, then expose the result.

## Summary: compensation is more honest than a fake rollback

| Verifiable measure | Result |
|---|---|
| File changed | `gXd.node/config-api.js` |
| Fix diff | **49 additions, 18 deletions** |
| Business data deleted after a deployment failure | **0** after the fix |
| Cleanup states exposed | deleted, skipped or failed |
| Fix date | May 28, 2026 |

In workflows that call several services, the right question is not "how do we undo everything?" It is: **which step is actually safe to undo, and which state must remain visible when it is not?**

Here, keeping the data and making the Worker failure observable is more reliable than pretending the whole operation was transactional. The safest rollback is not always the one that deletes the most things: it is the one that destroys only the side effect it is responsible for.
