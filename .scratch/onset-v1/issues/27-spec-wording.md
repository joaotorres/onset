# 27: SPEC wording fixes from the last two reviews

Status: needs-triage
Kind: behavioural
Blocked by:
Model:
Effort:

## Request

SPEC wording: drop the Oxford commas in §5 refuse row and §12 ExpireClaimJob, and replace §8 byline 'Nothing above it beyond main's own bottom padding' with 'Nothing between it and main'

From reviews 20261016-014459 and 20261016-020150. Docs only, no code change; players notice nothing.

Lines found at filing: `SPEC.md:235` (§5 refuse row, "from a player who agreed, and once"), `SPEC.md:514` (§12 `ExpireClaimJob`, "`correct`, `wrong`, or `expired`"), `SPEC.md:420` (§8 Byline footer "Where" bullet, the padding sentence now contradicts "the footer sits at the bottom edge" since ticket 26 made `main` grow).

## Comments
