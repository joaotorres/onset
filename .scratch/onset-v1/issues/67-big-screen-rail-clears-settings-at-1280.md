# 67: Big screen Players rail clears the settings button at 1280×800

Status: ready-for-agent
Kind: behavioural
Blocked by:
Priority: high
Feature: Page layout
Model:
Effort:
Changelog:

## Request

Deferred from 47. On the big screen at 1280×800 with 8 players, keep the Players rail clear of the 56×56 settings button in every state (waiting, playing and ended): the built boards' rail, a 152px room tile and 60px rows with 8px gaps, is about 760px tall and runs under the button. Check what the code renders at 1280 and shrink the rows as the design system's 1280 board draws them (52px rows, padding 8px 16px, 36px scores, 6px gaps) where it does not fit.

## Spec references

- SPEC.md, 8. Big screen (`/games/:code`): the Scoreboard bullet (every row in full, the rail above the settings button, shrinking under 1000px tall)
- SPEC.md, 8. Settings menu: Opening it (keeps the big screen's no-page-scroll rule)
- docs/design-system.md v8: Screens > Settings button placement (Big screen: 56×56, 40px in from both edges); Screens > Big screen (the `bot-big-waiting8-light` 1280×800 rail rows); Open questions (answered by triage 67)

## Scope

What the code renders today (computed from its classes, worth confirming with a measurement in the first test): the rail is a column with 32px gaps; the room tile is 152px (hidden while waiting, its empty root still taking a gap); the "Players" label 28px plus a 12px margin; each scoreboard row 72px (12px padding around the 48px score) with 8px between. With 8 players that is 856px in play and once ended, 704px while waiting. At 1280×800 the rail starts 40px from the top and the settings button's top edge is 96px from the bottom (704px), so the waiting rail runs 40px under the button, and in play the 7th row runs under it and off the screen and the 8th row is cut off entirely (the page clips at the window, so no scroll shows it). At 1920×1080 the rail ends at 896px and the button starts at 984px: it fits.

- **Big screen rail only** (the room tile, the "Players" label and the `#scoreboard` rows, in their partials and the big screen view): on a viewport under 1000px tall (a height query, not a width breakpoint: a 1440×900 laptop has the same overlap), the rows take the 1280 board's sizes, 52px tall, padding 8px 16px, 36px scores, 6px between, and the rail's own spacing tightens until 8 rows end at least 8px above the settings button's top edge at 1280×800 in every state. One budget that fits, for orientation: room tile padding 16px (144px tile), 16px between the room tile and Players, 8px under the label, 458px of rows: 654px, ending 10px above the button. Names, the dot, the Locked tag and the claiming row's yellow fill stay as they are, sized to fit the 36px row content
- At 1000px tall and up every size stays as built
- Keep every hook and its `data-version` as it is (`#scoreboard`, `#room_tile`, SPEC §7 Hooks), and the settings button where it is
- Must not touch: the play area (`#board`, the card grid's size formula, `#announcement`, the join hero, `#start_button`), the settings button and menu, the player screen, the add-bot tile (ticket 68) and the bot mark in the rail rows (ticket 69): each lands in the rail as it stands after this ticket. The add-bot tile is 136px, 16px shorter than the room tile, so it keeps the clearance this ticket sets, as long as it takes the compact spacing too

## Acceptance criteria

- At 1280×800 with 8 players, in waiting, in play (a claim running, so one row is the yellow claiming row, and one row locked out with its Locked tag) and ended, all 8 rows of `#scoreboard` are visible inside the window, and the last row's bottom edge is at least 8px above the settings button's top edge
- The same holds at 1440×900, in play
- At 1920×1080 the rows keep their built size (72px tall, 8px apart) and the rail its built spacing, and 8 rows end above the settings button
- At 1280×800 a scoreboard row is 52px tall, the rows 6px apart, the score's font size 36px
- In every case above the page does not scroll and the settings button stays 56×56, 40px in from the right and bottom edges (the existing big screen settings button specs still pass)
- The same holds in the light theme at 1280×800 in play (sizes only: a light screen changes colors alone)

## Verification

`bin/test-all && bundle exec standardrb`

Tests first, a system spec on the big screen with the "big screen theme" context (its `resize`, `rect`, `add_players` and `expect_settings_in_corner`):

- 1280×800, 8 players, waiting, playing (a claim and a locked player) and ended: every row's rect inside the window and the last row's bottom at least 8px above the settings button's top; red today in every state
- 1440×900 in play: the same
- 1920×1080: the same, plus the row height 72px and gap 8px
- 1280×800: row height 52px, gap 6px, score font size 36px
- Keep the file under 8 s: one `describe` per window size if needed

## Out of scope

- Big screens shorter than 800px (1366×768, 1280×720): the Deferred line below
- Scrolling the scoreboard, or capping how many rows it shows
- Moving or resizing the settings button, or its menu
- Any change to the play area, the hero or the card grid
- The No Set and claiming headlines' name truncation at 1280 (a design system open question of its own)

## Comments

Decided: Kind behavioural, because design system v8 already draws the 1280 rail's sizes, so nothing new is invented. Instead of: visual.

Decided: SPEC §8 Big screen, Scoreboard, states that with 8 players every row shows in full and the rail ends above the settings button in waiting, playing and ended, at 1280×800 as at 1920×1080, with a History line on the cut-off eighth row, and the design system's open question on the rail is marked answered, because the request is a change a user would notice and the spec said nothing about the rail's fit. Instead of: no spec change.

Decided: the compact rail is keyed on the viewport's height, under 1000px tall, because what runs under the button is the rail's height (the built rail needs 40 + 856 + 8 + 96 = 1000px), and a 1440×900 laptop overlaps as 1280×800 does. Instead of: a width breakpoint at 1280, which would leave 1440×900 overlapping and shrink a 1280-wide but tall window for nothing.

Decided: the rows alone do not clear the button in play (152 + 32 + 40 + 458 = 682px, ending 18px under the button's top), so the rail's own spacing tightens too (the gap above Players, the label's margin, the room tile's padding), within an 8px clearance, the builder choosing the exact values, because the design system leaves how the built rail shrinks to the code. Instead of: shrinking the rows only, which still overlaps in play.

Decided: the scope covers the rail in every state of one view, and no other place on the big screen, because the settings button sits under the rail column alone (40px in from the bottom-right, inside the rail's width); the play area, the band and the hero never reach it, and the player screen's button sits in its own footer row. Instead of: also auditing the play area for the button.

Decided: Priority high, because in play at 1280×800 the eighth player's row is cut off the screen, broken behaviour in built work. Instead of: normal.

Decided: Feature Page layout, because this is the big screen's layout fitting a window, as the content width was. Instead of: a new feature name.

Decided: Model left empty and no Security line, because it is a CSS sizing change with no shared logic and no auth. Instead of: Model fable.

Decided: big screens shorter than 800px are filed as a follow-up of their own, because the request names 1280×800 and the compact rail (about 654px) still overlaps the button under about 800px tall. Instead of: folding 768 and 720 tall laptops into this ticket.

Deferred: On the big screen on laptops shorter than 800px (1366×768, 1280×720) with 8 players, keep every Players row visible and the rail clear of the settings button in waiting, playing and ended, shrinking the rail further below 800px tall.
