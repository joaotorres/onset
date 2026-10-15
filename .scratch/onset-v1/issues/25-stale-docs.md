# 25: Fix stale claim and refusal text in SPEC and the glossary

Status: done
Kind: behavioural
Blocked by:
Model:
Effort:

## Request

Fix stale docs: SPEC §12 ExpireClaimJob still says 5 seconds and expire, GLOSSARY Lockout says five seconds, and the refuse route line in §5 reads as if the caller can refuse

From review 20261016-010057: the code is right and players notice nothing. A claim lasts 15 s and its picks are judged when time runs out (ticket 19); the lockout is 15 s (ticket 20); the caller and players who agreed cannot refuse (ticket 21, SPEC §2). Docs only, no code change.

Lines found at filing: `SPEC.md:235` (§5 refuse route, "refused by the caller, a player who agreed, or when this board's refusal is used" means the request is rejected in those cases, but reads as if they may refuse), `SPEC.md:514` (§12 `wait: 5.seconds`, "mark it `expired`"), `SPEC.md:669` (`set(wait: 5.seconds)`), `GLOSSARY.md:35` ("The five seconds after a wrong or timed-out claim").

## Spec references

- §5 Routes, the `POST /games/:code/no_set/refuse` row
- §12 Background Jobs, `ExpireClaimJob`
- §15 Implementation plan, Step 10 and Step 11

## Scope

SPEC.md and GLOSSARY.md only. No code, no tests: `Game::CLAIM_TIMEOUT`, `ExpireClaimJob`, `Claim#expire!` and `NoSetsController#refuse` already do what the docs now say.

## Acceptance criteria

- §5 refuse route says the request is ignored from the caller, from a player who agreed and once the board's refusal is used, naming `can_refuse_no_set?` (§4)
- §12 `ExpireClaimJob` waits `Game::CLAIM_TIMEOUT` and judges the held picks (§11) as correct, wrong or expired
- §15 Steps 10 and 11 read `Game::CLAIM_TIMEOUT` and 15 s, not 5 s
- GLOSSARY Lockout says 15 seconds

## Verification

`! grep -nE '(^|[^1])5\.seconds|five seconds|\(5s\)|for 5s|mark it `expired`|refused by the caller' SPEC.md GLOSSARY.md`

Tests to write first: none, docs only.

## Out of scope

Rewording §15's "doesn't submit" and "wrong submission" prose, which is the plan as built at the time and stays history. Any code or test change.

## Comments

Decided: §15 Step 11's 5 s lockout lines (goal, `locked_until`, acceptance) are fixed along with the lines the request names, because they are the same stale number from ticket 20 and the grep that verifies the ticket would otherwise still hit them. Instead of: fixing only the four lines the request lists.

Decided: the ticket closes in triage as `done`, because every change it asks for is a spec or glossary edit that gate 1 makes triage commit, so a build would have nothing left to do; the Verification command above passed. Instead of: a ready-for-agent brief that spends a build session on no edit.
