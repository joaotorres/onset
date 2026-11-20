# 72: Big screen play area fits laptops 800px tall and shorter

Status: done
Kind: behavioural
Blocked by:
Priority: high
Feature: Page layout
Model:
Effort:
Changelog: On the big screen, the waiting room's room code, QR code and player pills and the game-over podium now shrink to fit shorter windows, down to 1280×720, with the QR code never under 160px. Eight players with long names can still run past the bottom of the waiting room.

## Request

Deferred from 71. On the big screen on laptops 800px tall and shorter (1280×800, 1366×768, 1280×720) with 8 players, keep the play area inside the window in waiting and ended: check what the code renders for the join hero and its QR, the player pills, Start game and the podium above the 9rem announcement band, and shrink them by the viewport's height where they do not fit.

## Spec references

- SPEC.md, 8. Big screen (`/games/:code`): the Waiting bullet (the 288px QR, smaller on shorter windows), the Ended bullet, and the Fit bullet (everything inside the play area's box from 1280×720 up, the QR never under 160px, the link on one line under its tile, the winner's name never cut, 1920×1080 as built)
- SPEC.md, 8. Big screen: Announcement band (always 9rem tall, unchanged)
- docs/design-system.md v8: Screens > Big screen (`bot-big-waiting8-light`: the 1280×800 hero sizes, "The code is the truth for how the built hero and rail shrink")

## Scope

What the code renders today (computed from its classes, worth confirming with a measurement in the first test): `main` is `h-dvh` with 40px padding and `overflow-hidden`; the left column is `#board` (flex-1) over the 144px `#announcement` with a 24px gap, so `#board` has the window's height less 248px: 832px at 1080, 776px at 1024, 652px at 900, 552px at 800, 472px at 720. The waiting board centres its content with 48px gaps: the QR column 384px (the 336px tile, 288px QR in 24px padding, 16px, the 32px link line), the pills 68px each (3 rows of "Player N" pills at 1280 wide: 236px), Start game 96px: about 812px at 1280 wide. The ended board: "Game over" 32px, 12px, the 96px headline, 48px, the podium about 376px (★ 60px, the 40px name, the 32px points line, 12px, the 224px first bar), 56px, Play again 80px: about 700px, and 96px more when a long winner's name wraps the headline at 1280 wide. Both overflow centred, so their top runs off the window: waiting at 1280×800 and shorter and at 1280×1024 and 1440×900, ended under about 950px tall.

- **Big screen play area only**, in `games/_board.html.erb` (the waiting and ended branches) and `games/_start_button.html.erb`: sizes keyed on the viewport's height (height queries, or `dvh` clamps as the card grid's formula is, the builder choosing the steps and the values) so that with 8 players the waiting hero (QR tile, QR, link, hero text, room code), the pills and `#start_button`, and the ended "Game over", headline, podium (★, names, points, bars) and Play again sit inside `#board`'s box at every window from 1280×720 up. At 1280×800 take the design board's hero sizes where they fit (room code 80px, hero text 24px and 20px, pill text 24px with 16px dots, Start game 80px tall); the QR and gaps shrink as the fit needs
- The QR is at least 160px. The Join from this computer link stays on one line, under the QR tile and no wider than it (the existing 1280×800 layout spec keeps passing). The room code stays on one line and the hero text left of the rail. The headline wraps rather than truncates a long winner's name
- At 1920×1080 every size stays as built (QR 288px, room code 160px, pills 30px text, Start game 96px, headline 96px, first bar 224px)
- Keep every hook and its `data-version` as it is (`#board`, `#start_button`, `data-qr-tile`, `data-room-code`, `data-hero-text`, `data-join-here`, SPEC §7 Hooks), the 9rem `#announcement` and the page's 40px padding
- Must not touch: the playing board and the card grid's size formula, `#announcement`, the rail (room tile, `#scoreboard`, the add-bot tile: tickets 67, 68, 71), the settings button and menu, the player screen, the design system

## Acceptance criteria

- With 8 players named "Player 1" to "Player 8", 4 of them ready, in waiting at 1280×720, 1366×768, 1280×800, 1440×900 and 1280×1024: the QR tile, the link, every `[data-hero-text]` paragraph, every pill and `#start_button` lie inside `#board`'s rect (top at or below its top, bottom at or above its bottom), and `#board`'s bottom is above `#announcement`'s top
- In ended at the same five sizes, with 8 players and a sole winner named "Alexandria Pemberton" (20 characters), the second and third places "Samuel Wainwright" and "Priya Ramanathan": "Game over", the headline, each podium column and Play again lie inside `#board`'s rect, and the headline holds the winner's whole name (no ellipsis, `scrollWidth` not over `clientWidth`)
- At 1280×720 the QR svg is at least 160px wide; at 1280×800 the link sits under the QR tile, on one line, no wider than the tile, and the room code on one line, as the existing layout spec checks
- At 1280×800 the room code's font size is 80px and the Start game button 80px tall, unless the first test's measurement shows they cannot fit, in which case the builder records the sizes taken as a `Decided:` line
- At 1920×1080 the QR svg is 288px, the room code 160px, Start game 96px tall, the headline's font size 96px and the first place's bar 224px tall, and both states fit as above
- In every case above the page does not scroll and the settings button stays 56×56, 40px in from the right and bottom edges
- The same holds in the light theme at 1280×720 in waiting (sizes only: a light screen changes colors alone)

## Verification

`bin/test-all && bundle exec standardrb`

Tests first, system specs on the big screen with the "big screen theme" context (its `resize`, `rect`, `add_players`, `light!` and `expect_settings_in_corner`), next to `spec/system/big_screen/layout_spec.rb`:

- A helper that checks each named element's rect against `#board`'s rect
- Waiting at the five sizes: red today at 1280×720, 1366×768, 1280×800, 1440×900 and 1280×1024
- Ended at the five sizes with the long winner's name: red today at least at 1280×720 to 1440×900
- 1280×720: QR at least 160px; 1920×1080: the built sizes in both states
- Keep each file under 8 s: one file per state if needed

## Out of scope

- 8 players with long names whose waiting pills wrap to more rows: the Deferred line below
- The remove control on bot pills (ticket 48) and the bot mark on pills and the podium (tickets 68, 69): each fits the pills as they stand when built
- The playing state: the card grid's formula already shrinks the cards by the window's height
- Shrinking or hiding the 9rem announcement band in waiting or ended
- Windows shorter than 720px or narrower than 1280px
- Scrolling the play area, or capping how many pills show
- Any change to the design system: it leaves how the built hero shrinks to the code

## Comments

Decided: Kind behavioural, as tickets 67 and 71 judged the rail, because it shrinks components design system v8 already draws, inventing no token or component, and the design system leaves how the built hero shrinks to the code. Instead of: visual.

Decided: SPEC §8 Big screen gains a Fit bullet (every waiting and ended element inside the play area's box from 1280×720 up, the code choosing the sizes, 1280×800 at the design board's hero sizes, a History line) and the Waiting bullet's 288px QR points to it, because the request is a change a user would notice and the spec said nothing about the play area's fit. Instead of: no spec change.

Decided: the fit covers every window from 1280×720 up, tested at 1280×1024 and 1440×900 as well as the three laptops the request names, because the search for the same flaw found the waiting board (about 812px at 1280 wide) overflowing any `#board` under about 1060px tall, and the ended board (about 700px) under about 950px, so a 1280×1024 monitor and a 1440×900 laptop cut the hero's top as 1280×800 does. Instead of: only the heights the request names.

Decided: the QR shrinks with the window's height, never under 160px, because at 1280×800 the hero has about 216px for the QR column once the board sizes for the pills and Start game are spent, so the 288px QR cannot stay, and a 160px code (about 5px a module for the join URL) still scans from a phone across a table. Instead of: keeping the QR at 288px and shrinking everything else, which does not fit at 800 tall.

Decided: the ended headline wraps a long winner's name to a second line instead of truncating it, tested with a 20-character name, because the winner's name is what the screen announces and names run to 20 characters, so at 1280 wide the headline already wraps for names of about 15. Instead of: truncating the name with an ellipsis.

Decided: the 9rem announcement band stays in waiting and ended, because the request fits the play area above it and SPEC keeps it always 9rem so nothing jumps. Instead of: collapsing the empty band to give the hero room.

Decided: no blockers, because the fit is measured with people's pills and the ended podium, which exist today; tickets 68 (the bot mark on pills), 69 (the mark on the podium) and 48 (the remove control on bot pills) each fit their addition into the pills as they stand when built, and blocking on 68 would hold this high ticket behind a Security build. Instead of: blocked by 68.

Decided: Priority high, because at 1280×800 and shorter the waiting hero's QR runs off the top of the window with 8 players, broken behaviour in built work. Instead of: normal.

Decided: Feature Page layout, the parent's (71). Instead of: a new feature name.

Decided: Model left empty and no Security line, because it is a CSS sizing change with no shared logic and no auth. Instead of: Model fable.

Decided: 8 players with long names in waiting are filed as a follow-up of their own, because 8 pills of 20-character names wrap to four rows at 1280 wide (about 260px at the board's 24px pills), leaving the hero under the 160px QR floor at 800 tall, so fitting them needs a different pill layout (columns, truncation or smaller text), a behaviour the spec decides on its own. Instead of: folding long-name pills into this ticket.

Deferred: On the big screen at 1280×800 and shorter, keep the waiting play area inside the window with 8 players whose names run to 20 characters, whose pills wrap to four rows at 1280 wide, without the QR going under 160px. Filed as 73.

Decided: at 1280×800 the room code takes what its column allows (about 71px, between 64 and 80), not 80px, because the code's 17cqi cap keeps six wide letters off the rail and the 800px-tall hero cannot widen the column without dropping the QR under 160px; Start game is 80px tall and the other hero sizes as the design board. Instead of: 80px room code with a QR under 160px.

Decided: the Join link steps down with the height (24px, 20px under 920px, 16px under 820px, 14px under 740px), because it must stay one line no wider than the shrinking QR tile. Instead of: letting it outgrow the tile.

Decided: deep review 20261120-094918 leaves the names of the big screen's height variants for a follow-up, because the sizes are right and a rename changes nothing a user sees. Instead of: a pending decision.

Deferred: Behind the scenes: name the big screen's height variants by what they mean, before another step joins them. `app/assets/tailwind/application.css` defines `short` (under 1000px tall, ticket 67's rail) and `snug`, `tight`, `compact` and `cramped` (under 1080, 920, 820 and 740px, ticket 72's play area). The names give neither their order nor their threshold, `short` falls between `snug` and `tight`, and the comment on `short` says the rail "takes the compact sizes" though `compact:` is another step. Rename the five by threshold, or by one clear order, across their 30 uses in `app/views/games/` (`_board`, `_scoreboard`, `_start_button`, `_room_tile`, `show`), correct the comment, and name ticket 71's under-800px rail step the same way, whichever is built first. No size changes.
