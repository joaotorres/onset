# 71: Big screen Players rail clears the settings button under 800px tall

Status: ready-for-agent
Kind: behavioural
Blocked by: 67, 68
Priority: high
Feature: Page layout
Model:
Effort:
Changelog:

## Request

Deferred from 67. On the big screen on laptops shorter than 800px (1366×768, 1280×720) with 8 players, keep every Players row visible and the rail clear of the settings button in waiting, playing and ended, shrinking the rail further below 800px tall.

## Spec references

- SPEC.md, 8. Big screen (`/games/:code`): the Scoreboard bullet (every row in full and the rail above the settings button down to 1280×720 and 1366×768, shrinking again under 800px tall)
- SPEC.md, 8. Settings menu: Opening it (keeps the big screen's no-page-scroll rule)
- docs/design-system.md v8: Screens > Settings button placement (Big screen: 56×56, 40px in from both edges); Screens > Big screen (`bot-big-waiting8-light`: "The code is the truth for how the built hero and rail shrink"); Components > Add-bot control (the 136px big screen tile)

## Scope

The budget, after ticket 67: the rail starts 40px from the top and the settings button's top edge is 96px from the bottom, and the rail must end 8px above it, so it has the window's height less 144px: 624px at 1366×768, 576px at 1280×720. Ticket 67's compact rail (the room tile at 144px, 16px to Players, the 28px label and 8px under it, 8 rows of 52px with 6px gaps, 458px) is about 654px in play, so it runs 30px under the button at 768 tall and 78px at 720.

- **Big screen rail only** (the room tile, the "Players" label, the `#scoreboard` rows and, while waiting, ticket 68's add-bot tile, in their partials and the big screen view): on a viewport under 800px tall (a height query, as ticket 67's under 1000px), the rows and the rail's spacing shrink again until 8 rows end at least 8px above the settings button's top edge at 1280×720 in every state, the builder choosing the exact values. One budget that fits, for orientation: room tile padding 12px with a 36px room code (124px tile), 12px between the room tile and Players, 6px under the label, rows 44px (padding 6px 16px, 24px names, 30px scores) with 4px between (380px): 550px in play, ending 26px above the button at 720. While waiting, the add-bot tile as built (136px) with the same spacing and rows is 562px: it keeps its size unless the measurement says otherwise
- The dot, the Locked tag, the claiming row's yellow fill and ticket 69's bot mark (if built) stay, sized to fit the shorter row's content
- From 800px tall up to 999px every size stays as ticket 67 set it; at 1000px and up as built
- Keep every hook and its `data-version` as it is (`#scoreboard`, `#room_tile`, SPEC §7 Hooks), the page's 40px padding, and the settings button where it is
- Must not touch: the play area (`#board`, the card grid's size formula, `#announcement`, the join hero, the pills, `#start_button`, the podium), the settings button and menu, the player screen

## Acceptance criteria

- At 1280×720 with 8 players, in waiting (with the add-bot tile), in play (a claim running, so one row is the yellow claiming row, and one row locked out with its Locked tag) and ended, all 8 rows of `#scoreboard` are visible inside the window, and the last row's bottom edge is at least 8px above the settings button's top edge
- The same holds at 1366×768, in play
- At 1280×800 a scoreboard row is still 52px tall, the rows 6px apart and the score's font size 36px (ticket 67's sizes), and at 1920×1080 72px tall and 8px apart
- At 1280×720 a scoreboard row is shorter than 52px
- In every case above the page does not scroll and the settings button stays 56×56, 40px in from the right and bottom edges (the existing big screen settings button specs still pass)
- The same holds in the light theme at 1280×720 in play (sizes only: a light screen changes colors alone)

## Verification

`bin/test-all && bundle exec standardrb`

Tests first, a system spec on the big screen with the "big screen theme" context (its `resize`, `rect`, `add_players` and `expect_settings_in_corner`), next to ticket 67's rail spec:

- 1280×720, 8 players, waiting, playing (a claim and a locked player) and ended: every row's rect inside the window and the last row's bottom at least 8px above the settings button's top; red today in every state
- 1366×768 in play: the same; red today
- 1280×720: a row under 52px tall; 1280×800: 52px, gap 6px, score 36px (ticket 67's spec may already hold this: extend it rather than repeat it)
- Keep each file under 8 s: one `describe` per window size if needed

## Out of scope

- The play area at short heights (the join hero, the pills, Start game, the podium): the Deferred line below
- Big screens shorter than 720px
- Scrolling the scoreboard, or capping how many rows it shows
- Moving or resizing the settings button, or its menu
- Any change to the design system: it leaves the rail's shrinking to the code

## Comments

Decided: Kind behavioural, as ticket 67 judged its rail, because it shrinks the rail design system v8 already draws, inventing no token or component. Instead of: visual.

Decided: SPEC §8 Big screen, Scoreboard, now names 1280×720 and 1366×768 and a second shrink under 800px tall, the code choosing the sizes, with a History line, because the design system says the code is the truth for how the built rail shrinks, so no design pass is needed. Instead of: a design pass for the under-800 rail.

Decided: a second height step under 800px tall, on top of ticket 67's under 1000px, because 1280×800 keeps the design board's 52px rows and only shorter laptops need smaller ones. Instead of: shrinking the under-1000 rail as a whole to the 720 budget, which would move 1280×800 off its board.

Decided: 1280×720 is the shortest window the rail must fit, because it is the shortest laptop the request names. Instead of: a fit at every height.

Decided: blocked by 67 and 68, because this ticket shrinks 67's compact rail and its waiting criterion measures 68's add-bot tile at the top of the rail. Instead of: blocked by 67 alone, which would leave the waiting rail untested with the tile.

Decided: Priority high, because at 1366×768, a common laptop, the eighth player's row runs under the settings button or off the screen in play, broken behaviour in built work. Instead of: normal.

Decided: Feature Page layout, the parent's (67). Instead of: a new feature name.

Decided: Model left empty and no Security line, because it is a CSS sizing change with no shared logic and no auth. Instead of: Model fable.

Decided: the play area at short heights is filed as a follow-up of its own, because the search for the same flaw found the waiting join hero (a 336px QR tile), the 8 pills and Start game sized for 1080 with nothing keyed on height, likely taller than the space over the 9rem band under 800px tall, a different region the spec decides on its own. Instead of: folding the play area into this rail ticket.

Deferred: On the big screen on laptops 800px tall and shorter (1280×800, 1366×768, 1280×720) with 8 players, keep the play area inside the window in waiting and ended: check what the code renders for the join hero and its QR, the player pills, Start game and the podium above the 9rem announcement band, and shrink them by the viewport's height where they do not fit.
