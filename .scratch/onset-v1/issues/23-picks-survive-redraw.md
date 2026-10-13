# 23: Keep the latest picks across a player screen redraw during a claim

Status: done
Kind: behavioural
Blocked by:
Model:
Effort:

## Request

A tap made just before the player screen redraws during a claim reaches the server but not the redrawn screen; keep the latest picks across the redraw

Found in review 20261013-031948 (pending decision 1). While the claiming player picks cards, a redraw from elsewhere (for example the previous claim's announcement clearing) replaces the board. When a pick request is still in flight, the old `card-selection` instance has no `disconnect()` and its `finally` still sends its own selection (`card_selection_controller.js:82-87`), while the new instance rebuilt its picks from HTML rendered before that send landed. If the player stops tapping, the claim is judged on picks the screen does not show. Ticket 19 decided "a redraw renders the picks from the server" and SPEC §11 says the controller "continues from them".

The user chose to fix it. The review suggested keeping the latest selection per claim in the page code across the redraw, so the screen and the server agree; no data or schema change.

## Spec references

- §11 Selection submission UX (decision)
- §8 Views & UX, Player screen, 3. Claiming (mine)
- §7 Hooks that must survive any markup change, `card-selection`

## Scope

Touches:

- `app/javascript/controllers/card_selection_controller.js`: move the selection and the one-at-a-time sending out of the instance into module state for the current claim, keyed by the claim URL (`data-card-selection-url-value`): the latest picks, the request in flight and the "send again" flag. A toggle updates that state and sends from it; a request that returns sends the state's latest picks, whichever instance started it. On connect, a URL that matches the stored claim takes the stored picks over the rendered `aria-pressed` ones and marks the board to match (`aria-pressed`, the selected classes, tray, count); a new URL replaces the stored claim, starting from the rendered picks as today. The pending idle tap applies after that, as today.
- `spec/system/stimulus_polish_spec.rb` (or a new `spec/system/picks_across_redraw_spec.rb`): the examples below.

Must not touch: the server side (`Claim`, `ClaimsController`, `ExpireClaimJob`, routes, schema), the views and their markup, the `card-tap` controller, any copy or styling.

## Acceptance criteria

The system examples hold a pick request on its way by wrapping `window.fetch` with `execute_script` so a PATCH waits until the test releases it.

1. Portrait window, the player's own claim: tap card A (held on its way), tap card B, then redraw `#controller_status` (for example `game.update!(flash_claim_id: nil)`). The redrawn screen shows A and B picked (`aria-pressed="true"`), the count reads 2 and two tray slots are filled. After the release, the server's `card_ids` are A and B.
2. Same setup with only card A tapped and held, then the redraw, then a tap on card B on the redrawn screen. Only one PATCH is on its way at a time across the redraw (B's waits for A's), and after the release the server's `card_ids` are A and B and the screen shows both.
3. Same setup, tap A (held), redraw, tap A again on the redrawn screen to unpick it. After the release the server's `card_ids` are empty and the screen shows no picks, count 0.
4. A redraw with no pick on its way still renders the server's picks, as today (the existing "shows the picks again after a redraw mid-claim" example holds).
5. A later claim never starts from an earlier claim's stored picks: after a claim ends and the same player starts a new one by tapping a card, it opens at 1/3 with only that card picked (the existing tap-card examples hold).
6. The rest of the suite stays green.

## Verification

Write first: examples 1 to 3, and see them fail on the current controller. Then:

```
bundle exec rspec
```

## Out of scope

- Keeping picks across a page reload (sessionStorage or similar): after a reload the rendered picks are the picks (§11).
- Retrying a lost pick request on its own: the next tap resends the whole selection, as today.
- Any change to what the server stores or judges, or to the claim's broadcasts.
- Showing that a pick is still on its way (a spinner, a dimmed card): a visual change no one asked for.

## Comments

Decided: the page keeps the latest picks of the current claim in module memory, keyed by the claim URL, on top of the server render, and the redrawn screen prefers them, the server render staying the source after a reload or for a new claim, because the memory is the only place that knows about a pick still on its way, and the review the user accepted recommended it. Instead of: replacing the server render with memory, which ticket 19 rejected because a reload loses it.

Decided: the one-request-at-a-time sending moves into the same module state, so the old screen's in-flight request and the redrawn screen's taps share one queue and the last request carries what the screen shows. Instead of: aborting the old request on disconnect, which can still land on the server after a newer one.

Decided: SPEC §11 and §8 (Claiming, mine) amended to say the redrawn screen shows the latest picks even with one on its way; no other spec change. Instead of: "No spec change", since §11 said the controller continues from the rendered picks.
