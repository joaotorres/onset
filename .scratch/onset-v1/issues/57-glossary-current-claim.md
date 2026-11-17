# 57: Glossary: add Current claim, qualify when a claim is judged

Status: needs-triage
Kind: behavioural
Blocked by:
Priority:
Feature:
Model:
Effort:
Changelog:

## Request

Deferred from 56. GLOSSARY.md's Claim entry still says without condition that "a claim never submitted is judged on its picks when the window closes", and has no entry for "current claim", which SPEC now uses as a defined term (§5 PATCH and submit rows, §6 Key invariants, §12 ExpireClaimJob and BotSubmitJob). Add a Current claim entry matching §6 Key invariants (the room is playing, the claim is pending, held by `claim_player_id` and the room's newest claim; a claim left pending by an earlier game is never judged), and qualify the Claim entry so only the room's current claim is ever judged. Check every other glossary entry that mentions a claim being judged, expiring or submitted for the same unconditioned wording.

## Comments
