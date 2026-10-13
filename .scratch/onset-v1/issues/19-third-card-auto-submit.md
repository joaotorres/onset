# 19: Picking the third card does not auto-submit the claim

Status: done
Kind: behavioural
Blocked by:
Model:
Effort:

## Request

pick 3rd card doesn't submit automatically, but does if the time runs out

## Spec references

- §2 Game Rules, Round flow, rule 4
- §4 Data Model, `Claim`
- §5 Routes, `PATCH /games/:code/claims/:id`
- §6 Round State Machine (diagram) and Server-side timers
- §7 Hooks that must survive any markup change, `card-selection`
- §8 Views & UX, Player screen, 3. Claiming (mine)
- §11 Selection submission UX (decision)

## Scope

Touches:

- `app/models/claim.rb`: the validation (0 to 3 distinct board ids while pending or expired, exactly 3 once correct or wrong); a method that replaces the picks of a pending claim and ignores an invalid selection (not on the board, duplicates, more than 3); `expire!` judges the picks it finds (3 forming a Set: the correct path as today; 3 that do not: the wrong path; fewer: expired as today). `submit!` goes.
- `app/controllers/claims_controller.rb#update`: stores the picks, answers 204, never judges.
- `app/jobs/expire_claim_job.rb` only if `expire!` needs a different entry point.
- `app/javascript/controllers/card_selection_controller.js`: no timer, no dimming, no form; each toggle sends the whole selection with `fetch` PATCH (JSON body `card_ids`, `X-CSRF-Token` from the page's meta tag, one request in flight at a time, the latest selection sent when the previous one returns); on connect, picks up the picked cards from `aria-pressed="true"` and refills the tray and the count from them, then applies a pending idle tap through the same toggle path.
- `app/views/players/controller/_board_strip.html.erb` select mode: no form; the claim URL in `data-card-selection-url-value`; a card in `claim.card_ids` renders with `aria-pressed="true"` and the selected classes.
- `app/views/players/_controller_status.html.erb`: the `card-selection` element carries the URL value; the tray slots stay as they are (the controller fills them on connect).
- `docs/design-system.md`: the one Stimulus line that says `auto-submit`, to match SPEC §8.
- Specs: `spec/models/claim_spec.rb`, `spec/requests/claims_spec.rb`, `spec/jobs/expire_claim_job_spec.rb`, `spec/system/tap_card_claim_spec.rb`, `spec/system/stimulus_polish_spec.rb`.

Must not touch: lockout durations or messages (ticket 20 owns the duration), the big screen and other players' screens (the picks stay private), the No Set flow, the card partial, the tray and claim-bar markup and copy, the `card-tap` controller.

## Acceptance criteria

1. `PATCH /games/:code/claims/:id` with 1 or 2 board card ids on a pending claim stores them in `card_ids`, answers 204, leaves the claim pending and updates nothing on the game (no broadcast).
2. The same with 3 ids that form a Set stores them and still leaves the claim pending, unresolved, score unchanged.
3. A selection with an id not on the board, a duplicate id, or more than 3 ids is ignored: 204, picks unchanged.
4. A PATCH from a player who does not hold the claim answers 403 and changes nothing (as today).
5. `ExpireClaimJob` on a pending claim holding 3 picks that form a Set resolves it `correct`: +1, the three cards replaced from the deck, `flash_claim_id` set, `last_dealt` set, game end and quick-win rules applied as for a correct submission today.
6. On 3 picks that do not form a Set: `wrong`, score −1 (never below 0), `locked_until` 5 s ahead, `flash_claim_id` set, unlock broadcast scheduled.
7. On fewer than 3 picks: `expired`, −1, lockout, as today; `card_ids` keeps the picks that were there.
8. A `Claim` with 1 or 2 `card_ids` is valid while pending and expired; `correct` and `wrong` still require exactly 3 distinct ids in 0..80.
9. System (headless Chrome, the player's own claim): tapping three cards highlights them (`aria-pressed="true"`, ring classes), the count reads 3/3, the board does not dim, and the claim on the server is still pending with those three `card_ids`; a fourth tap on a picked card unpicks it and the server's `card_ids` follow.
10. System: `#controller_status` redrawn mid-claim (for example `game.update!(flash_claim_id: nil)` from the test) keeps the picked cards highlighted, the count and the filled tray slots in a portrait window.
11. System: with `HTMLFormElement.prototype.requestSubmit` deleted via `execute_script` before the taps, the picks still reach the server.
12. System: the existing tap-card examples hold with the new rule: a claim started by tapping a card opens at 1/3 with that card picked and the pick stored on the server; the correct and wrong examples resolve once `ExpireClaimJob.perform_now(claim)` runs, not before.

## Verification

Write first: the model specs for the validation and `expire!` judging (criteria 5 to 8), the request specs (1 to 4), then the system examples (9 to 12). Then:

```
bundle exec rspec
```

## Out of scope

- A Submit or Done button that ends the claim early. The request asks for judging at the timeout only.
- Showing the picks on the big screen or on other players' screens.
- Any new copy, hint or state on the claim bar ("judged when the time runs out"): that would be a visual change needing the design pass. The countdown ring is the sign.
- The lockout duration (ticket 20).
- Rewriting the `card-tap` controller to send the tapped card with the SET! POST.
- Updating the §15 implementation plan: it is history.

## Comments

Decided: read as a bug report against SPEC §11 (auto-submit 250ms after the third tap), so behavioural. Instead of: a request to remove auto-submit and submit only on timeout, which triage should ask about if the code shows auto-submit working.

Triage could not reproduce the report: the Chrome system spec auto-submits end to end, and production logs were empty. Code reading found two ways the third tap could fail to submit: a mid-claim redraw of `#controller_status` (3 s after a Set was found or a claim ended) wiping the selection and the pending timer, and a browser without `form.requestSubmit`. Asked; the user chose to drop auto-submit altogether, judging the picks when the time runs out, and to cover both failure modes under that rule. SPEC §2, §4, §5, §6, §7, §8, §11 and §16 updated.

Decided: fewer than three picks when the time runs out stays "Time's up! −1" with the lockout, because §2 already prices a claim that fails to pick as a wrong Set. Instead of: judging a short pick as wrong, which changes only the message.

Decided: the picks live in `Claim#card_ids` while pending, the validation relaxed to at most three until judged, because the column exists and the audit record then shows what was picked. Instead of: a new picks column, a schema change for the same data.

Decided: a redraw renders the picks from the server (`aria-pressed` on the board, the controller refills the tray and count on connect), because the server is the truth now and it costs no client state. Instead of: caching the selection in memory across disconnect and connect, which a page reload still loses.

Decided: each tap sends the whole selection with `fetch` and the page's CSRF token, one request in flight at a time, because that removes `form.requestSubmit` and keeps the picks arriving in order. Instead of: a form submit per tap with a `requestSubmit` fallback.

Decided: no new copy and no dimming once three cards are picked; the countdown ring already shows when the claim is judged. Instead of: a "judged when the time runs out" hint, a visual change that would wait on the design pass.

Decided: the pick request broadcasts nothing, because the picks are private to the claiming player (§8 shows other players only the caller). Instead of: live picks on the big screen, which nobody asked for.
