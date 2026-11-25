# 82: Behind the scenes: bring three records in line with what is built

Status: deployed
Kind: behavioural
Blocked by:
Priority: low
Feature: Claiming a SET
Model:
Effort:
Changelog: Behind the scenes: the spec names every answer a screen action can get, says a late submit is judged against the room's current claim, and the design system gives the tray slot number its built 24px.

## Request

Deferred from 66. Behind the scenes: bring three records in line with what is built. SPEC §5's URL surface, and §7's pointer to it naming `403`, `404` and `429`, lists every answer a screen action can get besides `204`, but leaves out two the app gives any request: `406` to a browser `allow_browser` turns away, and `422` to a missing or stale CSRF token. SPEC §11 (Submit) still says a late submit is ignored once the claim is "no longer pending", and judges at expiry a claim still pending, where §5, §6 Key invariants and the glossary now say the room's current claim. `docs/design-system.md` (Portrait tray) gives the tray slot number as 22px, and the built slot is `text-2xl`, 24px: make the two agree.

## Spec references

Edited by this triage, to match the build:

- SPEC.md, `## Shared: 5. Routes`, the URL surface list (`406` and `422` added)
- SPEC.md, `## Shared: 7. Realtime: Action Cable + Turbo Streams`, `### Actions answer 204, broadcasts update the screen` (the pointer names `406` and `422`)
- SPEC.md, `## 11. Selection submission UX (decision)` (picks stored, a late submit or pick ignored and the expiry judged against the room's current claim, §6 Key invariants)
- docs/design-system.md v9, `## Screens` > `### Player screen, during play` (Portrait tray: the slot number 24px, `text-2xl`) and `## Changelog`

Already right, unchanged: SPEC.md `### Key invariants`, `## Shared: 12. Background Jobs` (`ExpireClaimJob`, `BotSubmitJob`), GLOSSARY.md Current claim.

## Scope

Records only, edited in this triage: SPEC.md and docs/design-system.md. No code, no tests.

- §5 URL surface: `406` for any request from a browser `allow_browser versions: :modern` turns away (`ApplicationController`), page loads included; `422` for a POST, PATCH or DELETE with a missing or stale CSRF token (Rails' forgery protection, on by default under `load_defaults 8.1`), forms included. Both change nothing
- §7: the pointer to §5 lists `403`, `404`, `406`, `422`, `429`
- §11: "the pending claim", "no longer pending" and "still pending" become the room's current claim, citing §6 Key invariants
- DESIGN Portrait tray: 22px/700 becomes 24px/700 (`text-2xl`), as `players/_controller_status.html.erb` renders the empty slot; one v9 changelog entry, no version bump, as tickets 53 and 65
- Must not touch: any file under `app/`, the canvas boards, §4 Claim's `pending` result wording (it names the enum state, not the current claim)

## Acceptance criteria

- §5 URL surface names `406` and `422` with the cases that meet each
- §7 Actions answer 204 names `406` and `422` in its pointer to §5
- §11 no longer says "no longer pending" or "still pending", and judges a late submit, a late pick and the expiry against the room's current claim
- DESIGN Portrait tray gives the slot number as 24px/700, and its Changelog has the ticket 82 entry under v9

## Verification

`grep -c 'no longer matches the session' SPEC.md && grep -c 'once the claim is no longer the room.s current claim' SPEC.md && ! grep -q 'no longer pending' SPEC.md && ! grep -q 'still pending' SPEC.md && grep -c '406.*422.*429.. are listed in §5' SPEC.md && grep -c 'centred in display type, 24px/700' docs/design-system.md && ! grep -q '22px/700' docs/design-system.md`

Tests to write first: none, records only. Passed in this triage.

## Out of scope

- Any controller change, such as rescuing `InvalidAuthenticityToken` or giving the `406` and `422` a body of their own
- The `400` a join form without its `player` params gets (`params.expect`): a page form, not a screen action, and the form always sends them
- Redrawing the canvas tray board, or a DESIGN version bump

## Comments

Decided: the ticket closes in triage as `done`, as tickets 58 and 66 did, editing DESIGN too as triage 67 did, because every change is a records edit gate 1 makes triage commit and the one DESIGN number would spend a build session on a single word. Instead of: a ready-for-agent brief for the DESIGN line, as ticket 53.

Decided: DESIGN takes the built 24px, the code unchanged, because the request is to match the records to the build and a done screen's code is the truth (loop-rules 9). Instead of: changing the slot to `text-[22px]`.

Decided: §11's "stores them on the pending claim" becomes the current claim too, because it is the same stale wording the request names for Submit and expiry, and a fix covers the whole flaw (loop-rules 11). Instead of: the two sentences the request quoted.

Decided: `406` and `422` are the only answers added, because a search of the controllers finds no other answer a screen action can get (`params.expect` sits only in the join form, `400` aside as out of scope), and §5 keeps `500` unnamed as every app does. Instead of: listing `400` and `500` too.

Decided: Priority low, Feature "Claiming a SET", Model and Security empty, because no user notices a records fix, two of the three items are the claim's, and naming the CSRF answer changes no rule of who can do what. Instead of: Feature "Rate limits", ticket 66's.

Decided: no conflict with open tickets or the spec changes since the last deploy, because 79 changes no answer in §5 URL surface, 74 and 78's `422` is the join page's own render, and 69's `BotSubmitJob` already reads the current claim. Instead of: blocking on any of them.
