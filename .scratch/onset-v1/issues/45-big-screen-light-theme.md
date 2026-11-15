# 45: Light theme and the settings menu on the big screen

Status: ready-for-agent
Kind: visual
Blocked by: 43
Priority: normal
Model:
Effort:
Changelog:

## Request

Split from 40 (Dark mode, with a settings menu to toggle it): the settings button and menu on the big screen and the light theme of every big screen state.

## Spec references

- SPEC.md, Shared: 10. Cards and visual system > Themes, Visual system
- SPEC.md, 8. Settings menu
- SPEC.md, 8. Big screen (waiting, playing, the announcement band, ended)
- SPEC.md, Shared: 7. Realtime > Hooks that must survive any markup change
- docs/design-system.md v6: Shared: Themes (v6), Shared: Rules added in v6, Components > Settings button (big screen size), Settings menu (placement), games/_announcement, games/_scoreboard, games/_start_button, games/_ring; Screens > Settings button placement (big screen), Big screen
- Boards (canvas in docs/design-handoff.md): s-big-dark, s-big-dark-open, s-big-light-open, l-big-waiting4, l-big-waiting1, d-big-waiting4, d-big-waiting1, BigScreenTh, l-big-claiming, -noset, -refused, -correct, -wrong, -deck-empty, -ended, d-big-ended

## Scope

- **The settings button** on the big screen, 56×56, bottom-right, 40px in from both edges, under the rail, outside every broadcast target (`#board`, `#scoreboard`, `#announcement`, `#start_button`, `#room_tile`); the menu from 43 opening 40px from the right and 108px from the bottom. No page scroll at 1280px wide and up
- **The light theme** of every big screen state: waiting (the join hero, the QR tile with its light inset edge, the player pills, Start game and its disabled form), playing (deck line, Deck is empty pill, the card grid with the card wrapper edge and the light arrive outline `green-600`), the announcement band's panels (empty, Claiming, No Set, Refused, Correct, Wrong / Time's up), the room tile, the scoreboard (claiming row, Locked pill) and ended (the podium, ★ `yellow-700`, Play again), every value from DESIGN v6 Shared: Themes (v6)
- Every themed value comes from CSS keyed on `<html>` through 43's mechanism; every broadcast partial renders the same for every viewer
- Must not touch: the `_card` partial and the card palette (41), the player screen (44), any dark value, layouts, sizes and animations

## Acceptance criteria

- The big screen shows the settings button bottom-right in waiting, playing and ended; it opens the Theme menu and picking Light turns the screen light with no reload
- At 1280×800 and 1920×1080, no page scroll in any state with the button shown, and the card grid and band keep their sizes (the existing big screen specs pass unchanged)
- With the menu open, a broadcast (a player joins, a claim, a deal) updates the screen and the menu stays open with its choice
- A tap outside the open menu, on Start game or Play again, only closes the menu: the game does not start or restart
- In the light theme, the states in Scope take DESIGN v6's light values (spot checks: the page `gray-50`, the room tile white with the inset `gray-200` edge, the Claiming band `yellow-50` with a `yellow-500` ring, the No Set band `purple-50`, the Locked pill `red-100` with `red-700` text, the Deck is empty pill `orange-50`, the podium ★ `yellow-700`, the QR tile white with dark modules)
- In the dark theme every state renders as before this ticket
- A broadcast partial renders the same HTML whatever the viewer's `theme` cookie

## Verification

`bin/test-all && bin/rubocop`

Tests first:

- System specs for the button's presence and no page scroll at the two sizes, the menu surviving a broadcast, and the tap outside on Start game that starts nothing
- Computed-style spot checks of the light values above
- A request spec that the big screen's broadcast partials do not depend on the `theme` cookie

## Out of scope

- The Card colors option, the Classic palette and the color mark (41)
- Any change to the dark big screen
- The player screen (44)

## Comments
