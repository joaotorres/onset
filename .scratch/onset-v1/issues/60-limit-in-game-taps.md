# 60: Limit how often one player may send in-game actions

Status: needs-triage
Kind: behavioural
Blocked by:
Priority:
Feature:
Model:
Effort:
Changelog:

## Request

Limit how often one player may send in-game actions (I'm ready, SET!, card picks, Submit, No Set, End game) with a rate_limit on the gameplay POSTs, set so a player picking cards fast is never refused mid-claim.

Deferred from 54: the security review (.scratch/onset-v1/reviews/security-20261115.md, F1) suggested it, and the owner chose on 2026-11-19 to file it as a ticket of its own rather than fold it into 54. With 54's 8-player cap each tap's cost is already bounded, so this only guards against one player hammering the server. Touches security.

## Comments

Decided: filed apart from 54, overlapping its review finding, because the owner chose option 3 on 54 (a ticket of its own). Instead of: merging it into 54.
