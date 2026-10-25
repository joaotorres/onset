Design return for tickets 37.

## New tokens
None

## New components
- `players/controller/_submit`: the Submit pill in the pill slot, at the slot's usual size (portrait 220×44, landscape 144×44, computer 248×46), with three states:
  - disabled (fewer than 3 picks): `blue-600` at 35% with `blue-200` text, "Submit"
  - enabled (exactly 3 picks): `blue-600`, white text, "Submit", glow `0 0 24px rgba(37, 99, 235, 0.55)` (SET!'s glow without the 8px ring)
  - submitted (after the tap, until the resolving broadcast): `blue-600`, white text, disabled, an inline check icon (18px, stroke 3) then "Submitted"; `aria-label` "Submitted, waiting for the result"
  Body font, 16px/700 (15px in landscape). Stimulus `card-selection` owns enabling it and the freeze.

## New or changed rules
- Claiming (mine), every layout: Submit takes the pill slot under the tray (portrait) or under the yellow block (landscape, computer). The pill slot is no longer empty during the claim. Nothing else moves: portrait keeps the 64px status slot, the tray row is 128px tall (three 72×101 slots, 14px apart) above the 44px pill slot, 4px between, 176px in all, the same height as before.
- Portrait tray: an empty slot is a 72×101 dashed `gray-700` box with its slot number (1, 2, 3) centred in display type, 22px/700, `gray-500`; a filled slot shows the picked card. Slots fill in pick order.
- Claim bar hint line follows the pick count: "Tap 3 cards" at 0, 1 and 2 picks, "Tap Submit" at 3, "Judging…" after the tap. Same slot, same size.
- Submitted: the board's buttons are disabled, the three picks keep `ring-4 ring-blue-400 scale-95`, the tray and the n/3 count stay as they were at 3/3, the countdown ring keeps draining and Submit is in its submitted state.
- The board never dims at 3 picks (unchanged from ticket 19, confirmed in the 3/3 boards).

## Decisions the spec does not cover
- Where Submit sits: the pill slot, in every layout. It is the one fixed place that already exists, is sized for a 44px target and in portrait is under the thumb next to the tray; the yellow bar and block stay exactly as built.
- Disabled Submit uses the blocked No Set recipe (fill at 35%, light text at full opacity) rather than fading the whole button, so the label still reads at 4.5:1.
- The bar's hint line changes with the count (see rules); the spec words it as a fixed "Tap 3 cards".
- Submitted shows a full-strength blue "Submitted" with a check rather than the dimmed disabled look, so a frozen screen reads as "sent, waiting" and not as "you can't submit yet".
- A submit that never reaches the server shows no message, as the brief allows: the screen simply returns to 3/3 (Submit enabled, "Tap Submit").
- Drawn seconds on the claim ring: 14 at 0/3, 12 at 1/3, 10 at 2/3, 8 at 3/3, 7 in Submitted, so the five boards read as one claim.

## Open questions
- Should the hint line say "Click Submit" on computer, or is "Tap" fine everywhere as today's "Tap 3 cards" is?
- Does the spec want a visible cue for a failed submit (e.g. the hint line reading "Not sent, tap Submit again" for a few seconds)? None is drawn.
- Should Submit also enable at exactly 3 picks while a pick request is still in flight? The boards assume yes, per §11.

## Artboards added or changed
Added:
- play-p8-claim0, play-p8-claim2, play-p8-claim3, play-p8-submitted
- play-p3-claim0, play-p3-claim2, play-p3-claim3, play-p3-submitted
- play-l-claim0, play-l-claim2, play-l-claim3, play-l-submitted
- play-c-claim0, play-c-claim2, play-c-claim3, play-c-submitted
Changed (Submit now in their pill slot, portrait tray slots numbered):
- play-p8-claiming, play-p3-claiming, play-l-claiming, play-c-claiming
Changed components these render from: PlayPortrait, PlayLandscape, PlayComputer (new `state` values claiming0, claiming2, claiming3, submitted).
