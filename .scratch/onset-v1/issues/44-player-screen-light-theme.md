# 44: Light theme and the settings menu on the player screen

Status: ready-for-agent
Kind: visual
Blocked by: 43
Priority: normal
Model:
Effort:
Changelog:

## Request

Split from 40 (Dark mode, with a settings menu to toggle it): the settings button and menu on the player screen, the light theme of every player screen state in portrait, landscape and computer, and the readable disabled No Set pills in both themes.

## Spec references

- SPEC.md, Shared: 10. Cards and visual system > Themes, Visual system
- SPEC.md, 8. Settings menu (Opening it, Closing it, The game carries on under it, Outside every broadcast target)
- SPEC.md, 8. Player screen (all states, the "Room CODE" footer, the no-page-scroll rules)
- SPEC.md, Shared: 7. Realtime > Hooks that must survive any markup change
- docs/design-system.md v6: Shared: Themes (v6), Shared: Rules added in v5 and v6, Components > Settings button (player screen size), Settings menu (placement), players/controller/* entries, `_secondary_action` (disabled No Set while someone else claims, blocked No Set); Screens > Settings button placement (player screen rows), Player screen, Waiting, during play, Game over
- Boards (canvas in docs/design-handoff.md): s-waiting-p-dark-open, s-waiting-p-light-open, s-play-p-dark, -p-dark-open, -p-light-open, -p-picked-light, s-gameover-p-dark, s-play-l-dark, s-play-c-dark, -c-dark-open, -c-light-open, WaitingTh, l-waiting-p-voted, l-waiting-p-qr, l-waiting-l-8, l-waiting-c-8, PlayPortraitTh, l-play-p-deck-empty, -claim3, -submitted, -other, -refusal, -agreed, -blocked, -wrong, -found, -arrive, PlayLandscapeTh, l-play-l-claim3, -other, -refusal, -wrong, -found, PlayComputerTh, l-play-c-claim3, -other, -refusal, -wrong, -found, GameOverTh, l-gameover-p-voted, l-gameover-l, l-gameover-c

## Scope

- **The settings button** on the player screen, at the player screen size DESIGN v6 gives (40×28, 40×32 in the computer Waiting and Game over footers, icon in muted text), in the "Room CODE" footer row, outside `#controller_status`, in every state and layout, at the place Settings button placement gives; the menu from 43 opening from it as placed there. It adds no height: the board keeps its size and no page scroll appears
- **The light theme** of every player screen state (waiting with the invite and the QR sheet, idle, deck empty, claiming mine with the tray and Submit, submitted, someone else claiming, No Set countdown with the refusal pair, agreed, blocked after a refusal, locked out, the found-set banner, the arrive outline, game over with the standings) in portrait, landscape and computer, every value from DESIGN v6 Shared: Themes (v6): the tinted panels, countdown rings (600 progress, `gray-300` track), the light selected card ring `blue-500` and arrive outline `green-600`, the own scoreboard entry and standings row, the QR sheet overlay, the card wrapper edge on the board, tray and found-set banner. The player color strip stays the player's color
- **Both disabled No Set pills**, while someone else claims and blocked after a refusal ("No Set in 12 s"), follow the v5 rule in both themes: dark `purple-700` at 35% with `purple-200` text at full opacity, light `purple-100` with `purple-700` text, never the whole button faded. This is the one change to the dark theme
- Every themed value comes from CSS keyed on `<html>` through 43's mechanism, never from markup that depends on the viewer: `#controller_status` and every partial a stream replaces render the same for every player
- Must not touch: the `_card` partial and the card palette (41), the big screen (45), the hook ids and Stimulus attributes of SPEC 7, layouts, sizes and animations

## Acceptance criteria

- The player screen shows the settings button in the footer row in portrait, landscape and computer, during waiting, play and game over; it opens the Theme menu, and picking Light turns the whole screen light with no reload
- With 8 players and 18 cards, no page scroll at 375×667, 667×375 and 1024×640 in every state, the settings button shown, and the card size the same as before this ticket at each size (the existing layout specs pass unchanged)
- With the menu open, a tap outside it on SET! or a board card only closes the menu: no claim is made (no `Claim` created)
- With the menu open, a room update (another player's SET!, a claim resolved, a deal) updates the board, scoreboard and status panel and the menu stays open with its choice
- In the light theme the states listed in Scope take DESIGN v6's light values (spot checks: the page `gray-50`, the claim bar `yellow-400` with `gray-950` text, the No Set status panel `purple-50` with a `purple-600` border, the locked-out panel `red-50`, the found-set banner `green-50`, the selected card ring `blue-500`, the arrive outline `green-600`, the "Room CODE" footer `gray-500`, the card wrapper edge on board cards)
- In the dark theme every state renders as before this ticket, except both disabled No Set pills, whose fill is `purple-700` at 35% and whose label is `purple-200` at full opacity, with the button itself at full opacity
- A broadcast partial renders the same HTML whatever the viewer's `theme` cookie (a request spec rendering `#controller_status` with `theme=light` and with none gives the same markup)

## Verification

`bin/test-all && bin/rubocop`

Tests first:

- System specs for the settings button's presence and the no-page-scroll sizes in the three layouts, the tap outside that makes no claim, and the menu surviving a broadcast
- Computed-style spot checks of the light values above, and of both dark disabled No Set pills
- A request spec that the controller status markup does not depend on the `theme` cookie

## Out of scope

- The Card colors option, the Classic palette and the color mark (41)
- Redrawing or changing any dark value other than the disabled No Set pills; raising dark-theme contrast is deferred from 40
- Growing the footer to give the settings button 44px
- The big screen (45)

## Comments
