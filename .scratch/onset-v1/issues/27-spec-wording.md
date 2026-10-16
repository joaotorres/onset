# 27: SPEC wording fixes from the last two reviews

Status: done
Kind: behavioural
Blocked by:
Model:
Effort:

## Request

SPEC wording: drop the Oxford commas in §5 refuse row and §12 ExpireClaimJob, and replace §8 byline 'Nothing above it beyond main's own bottom padding' with 'Nothing between it and main'

From reviews 20261016-014459 and 20261016-020150. Docs only, no code change; players notice nothing.

Lines found at filing: `SPEC.md:235` (§5 refuse row, "from a player who agreed, and once"), `SPEC.md:514` (§12 `ExpireClaimJob`, "`correct`, `wrong`, or `expired`"), `SPEC.md:420` (§8 Byline footer "Where" bullet, the padding sentence now contradicts "the footer sits at the bottom edge" since ticket 26 made `main` grow).

## Spec references

- §5 Routes, the `POST /games/:code/no_set/refuse` row
- §12 Background Jobs, `ExpireClaimJob`
- §8 Byline footer, the "Where" bullet

## Scope

SPEC.md only. No code, no tests: the footer already renders as the reworded sentence says (ticket 26), and the two comma edits change no meaning.

## Acceptance criteria

- §5 refuse row reads "from a player who agreed and once this board's refusal is used", no comma before "and"
- §12 `ExpireClaimJob` reads "`correct`, `wrong` or `expired`", no comma before "or"
- §8 "Where" bullet reads "Nothing between it and `main`; below it 16px or the bottom safe area", with no mention of `main`'s bottom padding

## Verification

`! grep -nE "agreed, and once|\`wrong\`, or \`expired\`|beyond \`main\`'s own bottom padding" SPEC.md`

Tests to write first: none, docs only.

## Out of scope

The five other serial lists in SPEC.md that keep an Oxford comma (§1 card number, §3 one Rails process, §4 `board` column, §4 Claims audit record, §10 card number stack): the reviews did not name them and a sweep is its own request. Any code or test change.

## Comments

Decided: only the three lines the request names are edited, because the five other Oxford-comma lists in SPEC.md are a style sweep the two reviews did not ask for and the user may want to take as one request. Instead of: sweeping every serial list in the spec under this ticket.

Decided: the ticket closes in triage as `done`, as ticket 25 did, because every change it asks for is a spec edit that gate 1 makes triage commit, so a build would have nothing left to do; the Verification command above passed. Instead of: a ready-for-agent brief that spends a build session on no edit.
