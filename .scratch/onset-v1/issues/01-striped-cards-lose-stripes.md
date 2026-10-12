# 01: Striped cards lose their stripes after a tap

Status: needs-triage
Kind: behavioural
Blocked by:
Model:
Effort:

## Request

Bug: striped cards lose their stripes on a computer after a card is tapped (duplicate SVG pattern ids, tray copy hidden in landscape)

Cause found while grilling: every card SVG declares `<pattern id="stripes-<color>">`. `card_selection_controller.js` clones the tapped card's SVG into the tray, which sits before the card grid and is `landscape:hidden`. Browsers resolve `url(#id)` to the first element with that id, so striped cards point at a pattern inside a hidden element and render unfilled. A computer window is landscape, hence "browser only". Fix: a unique pattern id per card instance.

## Comments
