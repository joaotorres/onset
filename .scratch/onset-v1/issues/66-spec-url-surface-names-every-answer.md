# 66: SPEC URL surface names every non-204 answer

Status: needs-triage
Kind: behavioural
Blocked by:
Priority:
Feature:
Model:
Effort:
Changelog:

## Request

Deferred from 60. Behind the scenes: SPEC §5's URL surface paragraph says every POST answers `204 No Content` and "the one exception" is a pick or submit without the claim, `403`; since the Rate limits block (tickets 60 and 62) a request over its limit answers `429`. Reword that paragraph so it names every answer other than `204` (the `403` claim case, the `429` over a limit) and points to Rate limits, and check tickets 60 and 62's own "the one new answer" wording against it.

## Comments

Decided: filed alongside open tickets 60 and 62 rather than merged into either, because it rewords a spec paragraph both depend on and asks for their wording to be checked, not changed in their scope. Instead of: merging into 60.
