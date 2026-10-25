# 37: Submit button for a SET! claim

Status: deployed
Kind: visual
Blocked by:
Model:
Effort:
Changelog: A Submit button lets you send your three cards as soon as they are picked, instead of waiting out the 15 seconds.

## Request

Submit button for a SET! claim: once 3 cards are picked the claiming player can submit; the request carries the full card_ids and the server judges at once under the game lock (same outcomes as Claim#expire!: correct, wrong). Picks stay changeable until submit; the 15s ExpireClaimJob stays as the fallback when submit is never pressed. Partly reverses ticket 19 (no submit step): the submit must not depend on earlier pick PATCHes having landed, which avoids the race that ticket recorded.

Why: today a claim is judged only when the 15s run out (§11), so even a correct Set waits out the full timer.

Ticket 19 dropped the v1 auto-submit because the third tap was seen not to submit on a phone and the submit raced a mid-claim redraw. An explicit button whose request carries the whole selection avoids both: it does not wait on the pick requests, and the server judges what the button sent.

Kind is visual: a new control in the claim bar or tray, so it waits on the design pass.

## Spec references

- SPEC §2 Game Rules > Round flow, rule 4
- SPEC §5 Routes: the PATCH and `POST /games/:code/claims/:id/submit` rows, and the URL surface sentence (204, the 403 exception)
- SPEC §7 Realtime > Actions answer 204, broadcasts update the screen; Hooks that must survive any markup change (`card-selection`)
- SPEC §8 Views & UX > Player screen > 3. Claiming (mine)
- SPEC §11 Selection submission UX (decision)
- SPEC §12 Background Jobs (`ExpireClaimJob`)
- SPEC §17 Telemetry > Not tracked, on purpose (`claim_submitted`)
- docs/design-system.md v5: `players/controller/_submit`, Player screen during play (Claiming (mine), Portrait tray, Submitted), Rules added in v5
- GLOSSARY.md Claim (already updated, no change)

## Scope

Touches:

- `Claim`: a submit method that, under the game lock, validates the submitted selection (exactly 3 distinct board cards) against a still-pending claim, writes it to `card_ids` and resolves it correct or wrong with the same resolution paths `expire!` uses, so the broadcasts, score, deal, lockout and flash are the ones expiry sends.
- `ClaimsController`: a `submit` action, holder-only (`403` otherwise, as `update`), answering `204` whatever happens, reading `card_ids` as the PATCH does.
- `config/routes.rb`: the member `post :submit` on claims.
- The `card-selection` Stimulus controller: a `submit` target and action, a `hint` target, `submit-url` value; enable Submit at exactly 3 picks (disabled otherwise), the hint text per pick count, the submit `fetch` sent at once whatever pick request is in flight, the freeze from the tap (cards and Submit disabled, Submit in its submitted state, hint "Judging…") until the broadcast replaces the screen, the freeze lifted only when the fetch rejects (network error).
- The player screen's Claiming (mine) markup (`players/_controller_status`): a new `players/controller/_submit` partial in the pill slot in every layout, the portrait tray resized to the v5 rule (128px row above the 44px pill slot, 176px in all), the hint line as a `hint` target, the `submit` target and URL on the `card-selection` root. The `_status_panel` claim variant's hint stays in step if it renders the same bar.
- Specs: request (submit), model (`Claim`), system (the claiming screen in portrait, landscape and computer).

Must not touch: the big screen, `ExpireClaimJob`'s judging, the pick PATCH's behaviour, the No Set flow, the scoreboard, the `Claim` schema.

## Acceptance criteria

1. `POST /games/:code/claims/:id/submit` with `card_ids` of 3 distinct board cards that form a Set, from the holder of a pending claim: the claim is `correct` with those `card_ids` and a `resolved_at`, the player scores +1, the 3 cards leave the board and 3 are dealt (when the deck has them), the claim lock clears and the found-set flash is set, exactly as `expire!` does for 3 picks that form a Set. Answers 204.
2. The same with 3 distinct board cards that do not form a Set: the claim is `wrong`, −1 (floored at 0) and the `Game::CLAIM_TIMEOUT` lockout, the lock cleared, as `expire!` does. Answers 204.
3. The submitted selection is judged, not the stored picks: a claim whose stored `card_ids` are a different two cards resolves on the three the submit carries.
4. A submit with a selection that is not 3 distinct board cards (fewer, more, a duplicate, a card off the board, a non-integer, nothing) changes nothing, the claim stays `pending`, 204.
5. A submit once the claim is no longer pending (already resolved, expired or submitted) changes nothing, 204. `ExpireClaimJob` running after a submit no-ops.
6. A submit from a player who does not hold the claim answers 403 and changes nothing.
7. The submit holds the game lock while judging, and the resolution broadcasts are the ones a judged claim sends today (no new broadcast, no change to the big screen partials).
8. Player screen, Claiming (mine), every layout: a Submit pill in the pill slot, rendered `disabled` below 3 picks, enabled at exactly 3 picks (including a 3rd pick whose PATCH is still in flight) and disabled again on an unpick; the hint reads "Tap 3 cards" at 0 to 2 picks and "Tap Submit" at 3, in every layout.
9. Tapping Submit sends one `POST` to the submit URL with the 3 picks as `card_ids`, at once, without waiting for an in-flight pick request; from the tap the board takes no pick, Submit takes no second tap and shows "Submitted" (full-strength, `aria-label` "Submitted, waiting for the result"), the hint reads "Judging…", the tray, count and countdown ring stay as they were.
10. The resolving broadcast replaces the screen: correct shows the found-set banner and the idle state, wrong shows the locked-out state, as a claim judged at expiry does. The timer still resolves a claim never submitted (existing specs keep passing).
11. A submit request that rejects (no response, simulated with a failing `fetch`) unfreezes the screen at 3/3: cards and Submit enabled, hint "Tap Submit".
12. Portrait: the tray is a 128px row of three 72×101 slots above the 44px Submit pill, 176px in all, so nothing above it moves between idle and claiming; no page scroll at 375×667, 667×375 and 1024×640 with 8 players and 18 cards during a claim.
13. The look follows design system v5 `_submit`: disabled `blue-600` at 35% with `blue-200` text, enabled `blue-600` white text with the glow, submitted `blue-600` white text with the check icon.
14. `bundle exec standardrb` reports nothing on the changed Ruby files.

## Verification

Write first: the request specs for 1 to 7 (the submit route is missing today, so each fails), the model specs for 3 to 5, the system specs for 8 to 12 in the three layout specs or a new one, and see them fail. Then:

```
bundle exec rspec
```

## Out of scope

- A `submitted_at` column or any schema change (Decided above): `resolved_at` tells.
- A `claim_submitted` telemetry event (SPEC §17 Not tracked).
- A visible cue when the submit request fails (Decided below): the screen returns to 3/3.
- "Click Submit" on computer: "Tap" everywhere.
- Any change to the big screen, including an early end of its Claiming panel.
- Gathering the four `stream_version(game, *game.players)` sites into a helper (review 20261024-205314, judgement call 1): a refactor for a ticket of its own.
- Redrawing the claiming boards on the canvas: the code owns the screen once this ticket is done.

## Comments

Design gap: SPEC §11 says "there is no submit" and §2 Round flow, §6, §8 Player screen state 3 and §16 say nothing is judged before the 15 seconds run out, so no SPEC sentence decides the submit. Before the claiming screen can be drawn: (1) Is Submit offered only with exactly 3 picks, shown disabled below that, or hidden until then? (2) Once submitted, is the claim judged at once with the same outcomes and announcements as at expiry (correct: +1, deal, found-set banner; wrong: −1, lockout), and are the picks frozen from the tap on? (3) What does the claiming screen show between the tap and the broadcast that resolves it, and what if the submit request fails: the screen stays on the claim and the timer judges the stored picks? (4) A submit that lands after the claim resolved or expired: ignored, answering 204? (5) Telemetry: CLAUDE.md wants a jtTrack event per new user-facing action, but §17 leaves `set_found` untracked because it fires many times per game; does a submit get an event (`claim_submitted`) or the same exemption? (6) Does the big screen change at all, for example the Claiming panel ending early, or only through the existing Correct and Wrong panels?

Gap settled (triage, 2026-10-24): SPEC §2 Round flow rule 4, §5 Routes (`POST /games/:code/claims/:id/submit`), §6 diagram, §7 (the 204 list, the `card-selection` hooks), §8 Player screen state 3, §11, §12 `ExpireClaimJob`, §16 and §17 Not tracked now decide the submit, and the glossary's Claim entry says a claim is picked and submitted. Answers to the six questions: (1) disabled below three picks, enabled at exactly three, in one fixed place the design pass chooses; (2) judged at once, same outcomes and announcements as at expiry, the picks frozen from the tap; (3) the screen stays on the claim, frozen, ring running, until the resolving broadcast; a request that never reaches the server unfreezes it; (4) a late submit changes nothing and answers 204; (5) no event, listed under §17 Not tracked; (6) the big screen changes only through the existing Correct and Wrong panels. Next: the design brief, then triage.

Decided: Submit is shown disabled below three picks and enabled at exactly three, in one fixed place, because §8 keeps SET! in a fixed slot so the thumb never moves, and a control that appears at the third tap would be a surprise. Instead of: hidden until three picks.

Decided: the submit is its own route, `POST /games/:code/claims/:id/submit`, because judging is a different action from storing picks, and the route table reads it. Instead of: a `submit` flag on the pick PATCH.

Decided: from the tap the screen takes no more picks and no second tap until the resolving broadcast, unfrozen only when the request never reaches the server, because the server has judged what was sent and a response of any kind means the broadcast or the timer follows. Instead of: picks changeable after the tap, or the screen resolving itself before the broadcast.

Decided: a submit that arrives once the claim is resolved, or carrying a selection that is not three distinct board cards, changes nothing and answers 204, because §7 makes every action answer 204 and the broadcast is the truth, and `pick!` already ignores an invalid selection the same way. Instead of: 409 or 422, which no screen reads.

Decided: no `claim_submitted` event, listed under §17 Not tracked, because like `set_found` it fires once per claim, many times a game, and `Claim` records already show a submitted claim by its `resolved_at`. Instead of: an event per CLAUDE.md's default for a new user-facing action.

Decided: the big screen is unchanged, the Claiming panel ending through the existing Correct and Wrong panels, because the resolution broadcasts are the ones expiry sends. Instead of: a new panel or early-end treatment.

Decided: no column records whether a claim was submitted or timed out, because that is a schema change and `resolved_at` against `started_at` plus the timeout already tells. Instead of: a `submitted_at` column on `Claim`.

Decided: the brief leaves the four claiming boards (`play-p8-claiming`, `play-p3-claiming`, `play-l-claiming`, `play-c-claiming`) as they are, because the only change since they were drawn (ticket 19, no dimming at three picks) does not show at their 1/3, and the brief tells the design tool the code is the truth for it. Instead of: redrawing them from the code first.

Design proposes: the claim bar's hint line follows the pick count: "Tap 3 cards" at 0, 1 and 2 picks, "Tap Submit" at 3, "Judging…" from the Submit tap until the resolving broadcast, in the same slot at the same size. SPEC §8 state 3 words it as a fixed "Tap 3 cards".

Design proposes: Submit takes the pill slot in every layout (design system v5, `_submit`), so SPEC §8 state 3's "the pill slot left empty" for landscape and computer no longer holds and "in place of SET! and its pill" for portrait now covers the tray and Submit.

Design question: should the hint line say "Click Submit" on computer, or is "Tap" fine everywhere, as today's "Tap 3 cards" is?

Design question: does a submit that never reaches the server get a visible cue (for example the hint line reading "Not sent, tap Submit again" for a few seconds)? None is drawn; the screen returns to 3/3, as SPEC §11 says.

Design question: does Submit enable at exactly 3 picks while a pick request is still in flight? The boards assume yes, per SPEC §11 ("on the tap it sends the submit at once, whatever pick request is in flight").

Decided: design system v5 changes the Claiming (mine) screen rule from "the pill slot is empty" to Submit in the pill slot, and resizes the portrait tray to a 128px row above it, because the brief asked where Submit sits and the pill slot is the fixed place that already exists. Instead of: Submit inside the yellow bar or block.

Decided: the claim bar's hint follows the picks, "Tap 3 cards" at 0 to 2, "Tap Submit" at 3, "Judging…" from the tap, as the design proposed, SPEC §8 state 3 reworded, because a fixed "Tap 3 cards" at 3/3 tells the player nothing about the one tap left. Instead of: the fixed "Tap 3 cards".

Decided: Submit takes the pill slot in every layout, SPEC §8 state 3 reworded from "the pill slot left empty", because §8 left the place to the design pass and design system v5 put it there. Instead of: a slot of its own in the bar or block.

Decided: the hint says "Tap" in every layout, because §8 chooses the layout by the viewport whatever the input, and "Tap 3 cards" already reads so on computer. Instead of: "Click Submit" on computer.

Decided: a submit that never reaches the server shows no cue, the screen returning to 3/3 with Submit enabled and "Tap Submit", because §11 already says so, a cue is something the request did not ask for and the enabled Submit is the cue. Instead of: the hint reading "Not sent, tap Submit again" for a few seconds.

Decided: Submit enables at exactly 3 picks while a pick request is still in flight, as the boards assume, because §11 says the submit carries the whole selection and never waits on a pick request. Instead of: enabling only once the third pick has landed.

Decided: SPEC §5 states the holder-only `403` on the PATCH row and as the one exception to the 204 sentence, and §11 History says "board" for "grid", settling the review's two wording items, because the submit row said "as the PATCH" about a 403 the spec never gave the PATCH. Instead of: dropping "as the PATCH".

Decided: the brief leaves the four `stream_version(game, *game.players)` sites alone, Out of scope, although the build touches `_controller_status`, because a refactor the request did not ask for belongs to a ticket of its own and the review listed it as a judgement call, not a pending decision. Instead of: gathering them into a `room_version(game)` helper in this build.

Decided: the freeze after a Submit tap is kept in the page's memory of the current claim, so a room update that redraws the screen before the claim resolves keeps it frozen, because §11 says the freeze lasts until the resolving broadcast. Instead of: a redraw giving the screen back at 3/3 mid-judging.
