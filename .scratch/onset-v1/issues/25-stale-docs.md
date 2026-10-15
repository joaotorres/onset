# 25: Fix stale claim and refusal text in SPEC and the glossary

Status: needs-triage
Kind: behavioural
Blocked by:
Model:
Effort:

## Request

Fix stale docs: SPEC §12 ExpireClaimJob still says 5 seconds and expire, GLOSSARY Lockout says five seconds, and the refuse route line in §5 reads as if the caller can refuse

From review 20261016-010057: the code is right and players notice nothing. A claim lasts 15 s and its picks are judged when time runs out (ticket 19); the lockout is 15 s (ticket 20); the caller and players who agreed cannot refuse (ticket 21, SPEC §2). Docs only, no code change.

Lines found at filing: `SPEC.md:235` (§5 refuse route, "refused by the caller, a player who agreed, or when this board's refusal is used" means the request is rejected in those cases, but reads as if they may refuse), `SPEC.md:514` (§12 `wait: 5.seconds`, "mark it `expired`"), `SPEC.md:669` (`set(wait: 5.seconds)`), `GLOSSARY.md:35` ("The five seconds after a wrong or timed-out claim").

## Comments
