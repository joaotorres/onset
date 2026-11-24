# 82: Behind the scenes: bring three records in line with what is built

Status: needs-triage
Kind: behavioural
Blocked by:
Priority:
Feature:
Model:
Effort:
Changelog:

## Request

Deferred from 66. Behind the scenes: bring three records in line with what is built. SPEC §5's URL surface, and §7's pointer to it naming `403`, `404` and `429`, lists every answer a screen action can get besides `204`, but leaves out two the app gives any request: `406` to a browser `allow_browser` turns away, and `422` to a missing or stale CSRF token. SPEC §11 (Submit) still says a late submit is ignored once the claim is "no longer pending", and judges at expiry a claim still pending, where §5, §6 Key invariants and the glossary now say the room's current claim. `docs/design-system.md` (Portrait tray) gives the tray slot number as 22px, and the built slot is `text-2xl`, 24px: make the two agree.

## Comments
