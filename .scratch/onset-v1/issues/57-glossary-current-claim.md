# 57: Glossary: add Current claim, qualify when a claim is judged

Status: done
Kind: behavioural
Blocked by:
Priority: low
Feature: Claiming a SET
Model:
Effort:
Changelog: Behind the scenes: the glossary defines the current claim and says only it is ever judged.

## Request

Deferred from 56. GLOSSARY.md's Claim entry still says without condition that "a claim never submitted is judged on its picks when the window closes", and has no entry for "current claim", which SPEC now uses as a defined term (§5 PATCH and submit rows, §6 Key invariants, §12 ExpireClaimJob and BotSubmitJob). Add a Current claim entry matching §6 Key invariants (the room is playing, the claim is pending, held by `claim_player_id` and the room's newest claim; a claim left pending by an earlier game is never judged), and qualify the Claim entry so only the room's current claim is ever judged. Check every other glossary entry that mentions a claim being judged, expiring or submitted for the same unconditioned wording.

## Spec references

No spec change: SPEC `## Shared: 6. Round State Machine`, `### Key invariants` (the current-claim bullet) already defines the term, and `## Shared: 5. Routes` (PATCH and submit rows) and `## Shared: 12. Background Jobs` (`ExpireClaimJob`, `BotSubmitJob`) already use it with that qualification.

Edited by this triage: GLOSSARY.md, Game > Claim (qualified) and Game > Current claim (new).

## Scope

GLOSSARY.md only, edited in this triage. No code, no tests, no SPEC edit.

- Claim: says only the room's current claim is ever judged, and that one never submitted is judged on its picks when the window closes
- Current claim (new, after Claim): the room is playing, the claim is pending, its player holds the claim lock and it is the room's newest claim; only it takes picks, a submit (a bot's too) or its expiry; a claim left pending by an earlier game is never judged, scores nothing and costs nothing
- Checked the other entries for the same unconditioned wording: Lockout ("after a wrong or timed-out claim") names only judged claims, and Bot, No Set call, Refusal and Ready vote say nothing of judging, expiry or submit, so none changes

## Acceptance criteria

- GLOSSARY.md has a Current claim entry with the four conditions of SPEC §6 Key invariants and says a claim left pending by an earlier game is never judged
- The Claim entry no longer says without condition that a claim never submitted is judged when the window closes

## Verification

`grep -n '^\*\*Current claim\*\*:' GLOSSARY.md && ! grep -n 'a claim never submitted is judged' GLOSSARY.md`

Tests to write first: none, glossary only.

## Out of scope

- Any SPEC rewording, such as §2 Round flow item 4's "the server judges the picks it holds", which runs inside a game where the claim is current
- Any code or test change

## Comments

Decided: no spec change, because SPEC §6 Key invariants already defines the current claim and §5 and §12 already qualify each path by it; only the glossary drifted. Instead of: restating the definition in another SPEC section.

Decided: no other glossary entry changes, because Lockout speaks only of wrong or timed-out claims, which are judged ones, and no other entry mentions judging, expiry or a submit. Instead of: qualifying Lockout too.

Decided: no _Avoid_ line on Current claim, because SPEC uses "a claim is active" and "a claim runs" for `claim_active?`, so neither can be marked to avoid. Instead of: _Avoid_: Active claim.

Decided: the ticket closes in triage as `done`, as tickets 25 and 27 did, because its only change is a glossary edit that gate 1 makes triage commit, so a build would have nothing left to do; the Verification command above passed. Instead of: a ready-for-agent brief that spends a build session on no edit.

Decided: Priority low, Feature "Claiming a SET" (ticket 56's), Model empty, because no user notices a glossary fix. Instead of: normal.

Decided: no conflict with open tickets or the spec changes since the last deploy, because the edit only restates SPEC §6 as it stands, and ticket 47's `BotSubmitJob` takes the same current-claim check. Instead of: blocking on 47.
