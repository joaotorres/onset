# 66: SPEC URL surface names every non-204 answer

Status: done
Kind: behavioural
Blocked by:
Priority: low
Feature: Rate limits
Model:
Effort:
Changelog: Behind the scenes: the spec's list of routes names every answer a screen action can get besides "no content", and points to the rate limits.

## Request

Deferred from 60. Behind the scenes: SPEC §5's URL surface paragraph says every POST answers `204 No Content` and "the one exception" is a pick or submit without the claim, `403`; since the Rate limits block (tickets 60 and 62) a request over its limit answers `429`. Reword that paragraph so it names every answer other than `204` (the `403` claim case, the `429` over a limit) and points to Rate limits, and check tickets 60 and 62's own "the one new answer" wording against it.

## Spec references

SPEC `## Shared: 5. Routes`, the URL surface paragraph, and `## Shared: 7. Realtime: Action Cable + Turbo Streams`, `### Actions answer 204, broadcasts update the screen`, both edited by this triage.

## Scope

SPEC.md only, edited in this triage. No code, no tests.

- §5 URL surface: every screen action (POST, the pick's PATCH, the DELETEs of No Set and of a bot) answers `204`, an ignored one included. Then the other answers, checked against the controllers: `403` (a pick or submit without the claim, `claims_controller.rb`; Start game, Play again and the bot controls without `host_game`, `games_controller.rb` and tickets 68 and 48; a ready vote from no player of the room, `GamesController#ready`), `404` (an unknown room or claim, `find_by!`/`find`; SET!, pick, Submit, No Set and End game from no player of the room, each controller's `set_player`), `429` over a limit, pointing to Rate limits. The landing's and join page's form POSTs are named as pages, pointing to their rows and Rate limits
- §7 Actions answer 204: the action list gains There's a Set and adding and removing a bot, and a sentence points to §5 URL surface for the `403`, `404` and `429`
- Checked and unchanged: tickets 60 and 62's "the `429` is the one new answer", the §5 Rate limits block and the route table rows, §11's "answers 204 (§7)"

## Acceptance criteria

- §5 URL surface no longer calls the `403` claim case the one exception, and names `403`, `404` and `429` with the cases that meet each
- §5 URL surface points to Rate limits for the `429`
- §7 Actions answer 204 points to §5 URL surface for the answers other than `204`

## Verification

`grep -c 'The other answers only a stale page or a script meets' SPEC.md && grep -c 'are listed in §5, URL surface' SPEC.md && ! grep -q 'The one exception is a pick' SPEC.md`

Tests to write first: none, spec only.

## Out of scope

- Any controller change, such as making a ready vote from no player answer `404` as the other player actions do, or giving the `403`s a body: the spec now describes the code as it is
- Rewording the §15 implementation plan's history, or the Rate limits block

## Comments

Decided: filed alongside open tickets 60 and 62 rather than merged into either, because it rewords a spec paragraph both depend on and asks for their wording to be checked, not changed in their scope. Instead of: merging into 60.

Decided: the URL surface also names `404` and the host and ready `403`s, not only the claim `403` and the `429` the request named, because the request asks for every answer other than `204` and the controllers answer those too (the Rate limits bullet already said "`403` or `404`"). Instead of: the two codes the request listed.

Decided: §7 Actions answer 204 gains a pointer to §5 URL surface and the missing actions in its list (There's a Set, the bot controls), because it says every action answers `204` with no exception, the same flaw (loop-rules 11). Instead of: the §5 paragraph alone.

Decided: tickets 60 and 62 keep "the `429` is the one new answer", because it says what each ticket adds to §7, which stays true; 60 is done and its record is history. Instead of: rewording them.

Decided: a ready vote from no player stays `403` while the other player actions answer `404`, written into the spec as the code has it, because no screen sends either and no user notices. Instead of: a follow-up to make them match.

Decided: the ticket closes in triage as `done`, as tickets 25, 27, 57 and 58 did, because its only change is a spec edit that gate 1 makes triage commit; the Verification command above passed. Instead of: a ready-for-agent brief that spends a build session on no edit.

Decided: Priority low, Feature "Rate limits" (tickets 60 and 62's), Model and Security empty, because no user notices a spec fix and it changes no rule of who can do what. Instead of: normal.

Decided: no conflict with open tickets or the spec changes since the last deploy, because 48, 62, 68 and 70 answer the bot controls `403` without `host_game` and `204` otherwise, as the paragraph now says, and 61 and 69 add no screen answer. Instead of: blocking on any of them.

Decided: deep review 20261120-094918 leaves two answers SPEC §5 does not name, §11's older claim wording and one design system size for a follow-up, because a review edits no record and none changes what a user sees. Instead of: a pending decision.

Deferred: Behind the scenes: bring three records in line with what is built. SPEC §5's URL surface, and §7's pointer to it naming `403`, `404` and `429`, lists every answer a screen action can get besides `204`, but leaves out two the app gives any request: `406` to a browser `allow_browser` turns away, and `422` to a missing or stale CSRF token. SPEC §11 (Submit) still says a late submit is ignored once the claim is "no longer pending", and judges at expiry a claim still pending, where §5, §6 Key invariants and the glossary now say the room's current claim. `docs/design-system.md` (Portrait tray) gives the tray slot number as 22px, and the built slot is `text-2xl`, 24px: make the two agree.
