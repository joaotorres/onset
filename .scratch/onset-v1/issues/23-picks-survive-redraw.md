# 23: Keep the latest picks across a player screen redraw during a claim

Status: needs-triage
Kind: behavioural
Blocked by:
Model:
Effort:

## Request

A tap made just before the player screen redraws during a claim reaches the server but not the redrawn screen; keep the latest picks across the redraw

Found in review 20261013-031948 (pending decision 1). While the claiming player picks cards, a redraw from elsewhere (for example the previous claim's announcement clearing) replaces the board. When a pick request is still in flight, the old `card-selection` instance has no `disconnect()` and its `finally` still sends its own selection (`card_selection_controller.js:82-87`), while the new instance rebuilt its picks from HTML rendered before that send landed. If the player stops tapping, the claim is judged on picks the screen does not show. Ticket 19 decided "a redraw renders the picks from the server" and SPEC §11 says the controller "continues from them".

The user chose to fix it. The review suggested keeping the latest selection per claim in the page code across the redraw, so the screen and the server agree; no data or schema change.

## Comments
