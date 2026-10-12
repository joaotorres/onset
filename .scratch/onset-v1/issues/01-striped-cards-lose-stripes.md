# 01: Striped cards lose their stripes after a tap

Status: ready-for-agent
Kind: behavioural
Blocked by:
Model:
Effort:

## Request

Bug: striped cards lose their stripes on a computer after a card is tapped (duplicate SVG pattern ids, tray copy hidden in landscape)

Cause found while grilling: every card SVG declares `<pattern id="stripes-<color>">`. `card_selection_controller.js` clones the tapped card's SVG into the tray, which sits before the card grid and is `landscape:hidden`. Browsers resolve `url(#id)` to the first element with that id, so striped cards point at a pattern inside a hidden element and render unfilled. A computer window is landscape, hence "browser only". Fix: a unique pattern id per card instance.

## Spec references

- §10 Cards and visual system > Component (Striped: pattern id unique per rendered SVG, tray copies get fresh ids)
- §11 Selection submission UX (decision) (each tap copies the card into the tray)
- §7 Realtime > Hooks that must survive any markup change (`card-selection` targets stay as they are)

## Scope

Confirmed by code path: the card partial declares `<pattern id="stripes-<color>">` in every SVG; the phone claim view renders the portrait tray (hidden in landscape) before the card grid; `card-selection#fillSlot` clones the tapped card's SVG into the tray. In landscape every striped card of that color then resolves its fill to the pattern inside the hidden tray and paints empty.

Touches the card partial (`cards/_card`) and the `card-selection` Stimulus controller's tray copy. Must not touch card geometry, palette, sizing, the tray's layout or the `card-selection` targets, actions and data attributes listed in §7.

## Acceptance criteria

- Rendering the card partial twice for the same card on one page yields two different pattern ids, and each SVG's striped shapes reference the pattern defined inside that same SVG
- A striped card still renders the §10 hatch: 40°, 3.5px lines, 7px pitch, in its card color
- On the player screen during my claim, in a landscape window, after tapping a striped card the document holds no duplicate `id` attribute, and every striped card in the grid (the tapped one included) references a pattern inside its own SVG
- Same in a portrait window: the tray copy references a pattern inside the tray copy, not the original card's
- Deselecting and re-selecting a card leaves no duplicate ids either
- Solid and outline cards render unchanged

## Verification

`bundle exec rspec`

Write first: a view spec rendering `cards/card` twice for one striped card (distinct pattern ids, fills point at their own SVG's pattern), and a system spec in `spec/system/stimulus_polish_spec.rb` that resizes the window to landscape (wider than tall) and to portrait, taps a striped card during a claim and asserts via JS that no `id` is duplicated in the document and each card SVG's `url(#...)` fills resolve inside that SVG.

## Out of scope

- A shared page-level pattern sprite or any other restructuring of the card SVG
- Changing the tray, the grid layout or the landscape/portrait split
- Fixing ids in other SVGs (countdown rings, QR codes)

## Comments

Decided: pattern ids are unique per rendered SVG (a per-render suffix), not derived from the card id, because the same card can render twice on one page (found-set banner and grid). Instead of: `stripes-<color>-<card id>`.

Decided: the tray copy gets fresh pattern ids in `card-selection` when cloned, because a clone of a uniquely-id'd card still duplicates its id ahead of the grid. Instead of: one shared pattern sprite per page, which a hidden container can break the same way.

Decided: SPEC §10 Striped line reworded to require unique ids, because its literal `url(#stripes-#{color})` is the cause of the bug. Instead of: "No spec change".
