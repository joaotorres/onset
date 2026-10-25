# 38: Failed Submit unfreezes a redrawn claiming screen

Status: ready-for-agent
Kind: behavioural
Blocked by:
Model:
Effort:
Changelog:

## Request

Behind the scenes: a Submit request that never reaches the server unfreezes the claiming screen even when a room update redrew it while the request was pending (SPEC §11 says the freeze is lifted on a failed request; today only the controller that sent it is refreshed, card_selection_controller.js:120)

From review 20261025-165721, pending decision 1, where the fix was recommended over accepting it. The case: a redraw (another player's lockout ending, a join, a No Set call) lands while the failing Submit is pending; the redrawn screen freezes itself from the page's memory of the claim and is never told the request failed, so it stays on "Judging…" until the next redraw or the 15-second timer. The review judged it a few lines with no spec change: on a rejected submit, refresh whichever controller is connected for that claim, or let a connecting controller re-check.

## Spec references

No spec change. SPEC §11 Selection submission UX (decision) already covers it: "The freeze is lifted only when the request fails to reach the server, so the player can tap again" and, for a redraw, "the page also keeps the latest picks of the current claim in memory ... a redrawn screen shows those latest picks". Also SPEC §7 Realtime > Hooks that must survive any markup change (`card-selection`).

## Scope

Touches:

- The `card-selection` Stimulus controller only: when the submit request rejects, the unfreeze (`submitted` back to false, cards and Submit enabled, hint "Tap Submit") reaches the controller that is connected for that claim at that moment, whichever controller sent the request. Either the claim's memory knows its connected controller (set on connect) and the rejection refreshes it, or a connecting controller re-checks; the build picks.
- Specs: one system spec beside the existing "gives the screen back at 3/3 when the submit never reaches the server" case.

Must not touch: the server (`Claim`, `ClaimsController`, routes, `ExpireClaimJob`), the markup of the claiming screen, the pick sending, the design system, the freeze itself (a redraw mid-judging stays frozen, ticket 37's last Decided line).

## Acceptance criteria

1. Player screen, Claiming (mine), three picks, Submit tapped: a room update redraws `#controller_status` while the submit request is pending, the redrawn screen is frozen ("Judging…", cards and Submit disabled), then the request rejects (no response, a failing `fetch`): the redrawn screen unfreezes at 3/3, Submit enabled reading "Submit", hint "Tap Submit", cards enabled, and a tap unpicks a card.
2. The same with no redraw still unfreezes the screen that sent the request (the existing spec keeps passing).
3. A submit request that gets any response (204) leaves the screen frozen until the resolving broadcast, with or without a redraw in between (existing specs keep passing).
4. After the claim resolves and a new claim starts, the old claim's controller reference, if any, is not refreshed by a late rejection of the old request (no error in the console, the new claim's screen unchanged).
5. The whole suite stays green.

## Verification

Write first, in `spec/system/claim_submit_spec.rb`, a case for criterion 1: hold the submit POST with the spec's `hold_requests!` seam extended so a held submit can be released as a rejection, redraw with the `redraw!` helper from `spec/system/picks_across_redraw_spec.rb` (touch `flash_claim_id`, wait for the marked `#controller_status` to go), then release the rejection and see the redrawn screen come back to 3/3. It fails today: the redrawn screen stays on "Judging…". Then:

```
bundle exec rspec
```

## Out of scope

- A visible cue that the request failed (ticket 37 Decided: the enabled Submit is the cue).
- Unfreezing on a redraw while the request is still pending (ticket 37 Decided: the freeze is kept across redraws until the broadcast).
- Retrying the submit automatically.
- Any change to the server or to what the timer judges.
- Moving the misplaced comment above `request()` (review 20261025-165721 judgement call 1) unless the build edits those lines anyway.

## Comments

Decided: no spec change, because SPEC §11 already promises the unfreeze on a failed request and the memory across a redraw; the code falls short of it. Instead of: a §11 clause saying the unfreeze may wait for the next redraw.

Decided: the brief names the behaviour (the connected controller for the claim gets the unfreeze) and leaves the mechanism to the build, because the two mechanisms the review offered differ in nothing a player would notice. Instead of: prescribing a controller reference on the claim's memory.
