# 38: Failed Submit unfreezes a redrawn claiming screen

Status: needs-triage
Kind: behavioural
Blocked by:
Model:
Effort:
Changelog:

## Request

Behind the scenes: a Submit request that never reaches the server unfreezes the claiming screen even when a room update redrew it while the request was pending (SPEC §11 says the freeze is lifted on a failed request; today only the controller that sent it is refreshed, card_selection_controller.js:120)

From review 20261025-165721, pending decision 1, where the fix was recommended over accepting it. The case: a redraw (another player's lockout ending, a join, a No Set call) lands while the failing Submit is pending; the redrawn screen freezes itself from the page's memory of the claim and is never told the request failed, so it stays on "Judging…" until the next redraw or the 15-second timer. The review judged it a few lines with no spec change: on a rejected submit, refresh whichever controller is connected for that claim, or let a connecting controller re-check.

## Comments
