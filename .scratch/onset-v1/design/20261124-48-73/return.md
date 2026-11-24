Design return for tickets 48, 73.

## New tokens

None. The remove control uses existing roles only: secondary text, primary text, the Raised, borderless surface and the focus outline.

## New components

Remove control (ticket 48): an icon-only `<button>` on a bot's big screen pill and on a bot's row in the host's waiting roster. Nowhere else, and never on a person.

- **Glyph:** an "×", the Lucide-style "x" (`M18 6 6 18M6 6l12 12`), inline stroke SVG, 24 viewBox, stroke 2.5, round caps, `stroke="currentColor"`, `aria-hidden="true"`. The same weight as the add-bot control's "+", so add and remove read as a pair
- **Accessible name:** `aria-label="Remove Easy bot"`, the bot's name after "Remove"
- **Place:** last in the pill or row, after the ✓. Order in a bot's pill: dot, name, bot mark, ✓, remove control. On a roster row the ✓ keeps its `margin-left: auto` and the control follows it
- **Box and hit area:** a square, transparent at rest, that is both the hit area and what hover and focus draw on. Every size is at least 24×24 CSS px (WCAG 2.2 AA, 2.5.8). `flex: none`, so it never shrinks

| Place | Box and hit area | Glyph | Radius | Margin |
|---|---|---|---|---|
| Big screen pill, 30px names (1080px tall and up, as at 1920×1080) | 44×44 | 24px | 12 | `-4px -10px -4px -4px` |
| Big screen pill, 24px names (under 1080px tall, built pill sizes) | 36×36 | 20px | 10 | `-2px -8px -2px -4px` |
| Big screen pill, small size (20px names: 7 or 8 players under 820px tall, as at 1280×800 and 1280×720) | 28×28 | 16px | 8 | `0 -6px 0 -4px` |
| Host's player screen, portrait (28px rows) | 28×28 | 14px | 8 | `0 -7px 0 -6px` |
| Host's player screen, landscape (26px rows) | 26×26 | 13px | 8 | `0 -6px 0 -5px` |
| Host's player screen, computer (36px rows) | 32×32 | 16px | 8 | `0 -8px 0 -4px` |

  - The negative vertical margins keep a pill at its height (the box is taller than the pill's text line). The negative right margin lets the box overhang the pill's padding or the roster row's right end by its own inner padding, so the glyph sits where the text edge would. On a roster row the glyph therefore ends where a person's ✓ ends
  - The phone rows have no room for a 44px target: the roster rows are 28px and 26px tall, 6px and 4px apart. The control takes the row's full height
- **Resting:** no fill, the glyph in secondary text
  - Dark `gray-400` `#9CA3AF`: 6.99:1 on `gray-900` (big screen pill, the computer roster panel), 7.93:1 on `gray-950` (portrait and landscape roster, on the page)
  - Light `gray-600` `#4B5563`: 7.56:1 on white (big screen pill, the computer roster panel), 7.23:1 on `gray-50` (portrait and landscape roster)
- **Hover** (only where the device hovers: the big screen and the computer player screen; none on phones): the box fills with Raised, borderless and the glyph goes to primary text
  - Dark: `gray-800` `#1F2937` fill, glyph white on the big screen (14.68:1), `gray-50` on the player screen (14.05:1)
  - Light: `gray-200` `#E5E7EB` fill, glyph `gray-900` `#111827` (14.33:1)
- **Keyboard focus:** the 2px `blue-500` outline at 2px offset on the box, glyph as resting. The ring is 3.68:1 on white, 3.52:1 on `gray-50`, 4.83:1 on `gray-900`, 5.48:1 on `gray-950`. On the small pill (34px tall) and on the roster rows the ring passes the pill's or row's edge by 1 to 4px into the gap between rows; nothing moves
- **Pressed, pending, disabled:** none. The action answers 204 and the broadcast removes the bot, as the add-bot control
- **Never red or green**, in any state
- No size moves between states
- Not drawn, derived from the table: the 36×36 control on a 24px pill (rooms of up to 6 players at 1280×800, and every room between 820px and 1079px tall). Boards 1 and 2 draw the 28×28 one, board 3's callout the 44×44 one

Bot mark, one new size: 18px on the small big screen pill (20px names), beside the v8 sizes (26px at 30px names, 22px at 24px names).

## New or changed rules

Big screen waiting pills, the long-name layout (ticket 73). Pills stay content-sized and wrap, as built. Two things are added, both keyed on what CSS already knows (the window's height and the number of pills), never on measuring names:

1. **A cap on every pill's width, at every height.** No pill is wider than its share of the row, so 8 pills never take more rows than the window has room for
   - Under 1080px tall: half the row, `max-width: calc((100% - <the list's gap>) / 2)`. At 1280px wide the row is 744px, so 369px with the 6px gap, 366px with the built 12px gap. 8 pills take at most 4 rows, 6 pills at most 3
   - 1080px tall and up: a third of the row, `calc((100% - 2 × 16px) / 3)`, 450px at 1920×1080. 8 pills take at most 3 rows
   - The name is the only part that gives: `min-width: 0`, one line, `text-overflow: ellipsis`, as the rail's rows. The dot, the bot mark, the ✓ and the remove control are `flex: none` and always show in full
2. **The small pill, with 7 or 8 players on a window under 820px tall** (the code's compact and cramped steps: 1280×800, 1366×768, 1280×720). Four rows of the built pill do not fit there, so from the 7th player every pill in the list takes:
   - 34px tall: 20px semibold text on a 28px line, padding 3px 16px, radius 12, 10px between its parts
   - dot 14px, bot mark 18px, ✓ 18px, remove control 28×28
   - 6px between pills, across and down
   - 4 rows are 154px. Not-ready pills keep secondary text, the light pill its inset edge
   - Rooms of up to 6 players keep the built pill at these heights (24px text, 16px dot; 48px tall under 820px, 44px under 740px, 12px gaps), with the cap: at most 3 rows

What each window takes with 7 or 8 players, and the room it has. The play area is the window's height less 248px (two 40px paddings, the 24px gap, the 9rem band); the room for pills is that less the built hero, the two gaps and Start game, computed from the built sizes in `app/views/games/_board.html.erb`, not measured:

| Window | Play area | Hero, gaps, Start game | Room for pills | Pills | Pill block |
|---|---|---|---|---|---|
| 1280×720 | 472px | 224 + 8 + 8 + 64 | 168px | small, cap half | 154px (4 rows) |
| 1366×768 | 520px | 240 + 20 + 20 + 80 | 160px | small, cap half | 154px |
| 1280×800 | 552px | 240 + 20 + 20 + 80 | 192px | small, cap half | 154px |
| 1440×900 | 652px | 300 + 24 + 24 + 80 | 224px | 24px text, 44px tall (6px top and bottom, the built under-740 pill), 12px gaps, cap half | 212px |
| 1280×1024 | 776px | 336 + 32 + 32 + 80 | 296px | as built (24px text, 56px tall, 16px gaps), cap half | 272px |
| 1920×1080 | 832px | 384 + 48 + 48 + 96 | 256px | as built (30px text, 68px tall, 16px gaps), cap a third | 236px (3 rows) |

So the third rule: **with 7 or 8 players on a window 820px to 919px tall** (1440×900), the pills take the built under-740 pill, 44px tall with 12px gaps. Every other size at every height is as built.

Where a name truncates:

- Small pill at 1280px wide (cap 369px): a person's name has about 290px once ready and about 313px before. Every name of 20 characters in ordinary mixed case shows whole at 20px semibold: the widest drawn, "Bartholomew Nakamura", is about 226px. Only a name of wide capitals is cut: twenty W's (about 380px) end in an ellipsis after about 15. Boards 1 and 2 draw that name on purpose, beside four whole ones
- A bot's pill at the small size has about 234px for its name: "Medium bot 2" (about 129px) shows whole
- Built 24px pill, cap half, at 1280px wide (up to 6 players at 1280×800 and 1280×720, 8 at 1280×1024): about 270px for a person's name, so a 20-character name wider than about 11em ("Bartholomew Nakamura" is right at it) loses its last character or two
- 1920×1080, cap a third (450px): about 334px for a person's name at 30px, the same threshold; names of up to 10 characters are untouched, and a bot's pill with its remove control (about 400px for "Medium bot 2") fits whole

The QR floor of 160px, the one-line link under its tile and the 9rem band stay. Boards 1 and 2 draw the hero as built (ticket 72): 176px QR on a 16px-padded tile, 16px link, 80px code, 80px Start game at 1280×800; 160px QR, 14px link, 64px code, 64px Start game and 8px gaps at 1280×720.

Roster rows (ticket 48): a bot's row on the host's screen ends dot, name, bot mark, ✓, remove control. The name truncates further; nothing else moves and no row height changes. In portrait (a 164px column) "Easy bot" and "Easy bot 2" still show whole; "Medium bot 2" is cut ("Medium bo…").

## Decisions the spec does not cover

Visual choices:

- The remove control is an "×" with no fill at rest, in secondary text, rather than a bordered button or a red one: it sits on up to 8 pills and must not compete with Start game, and red means wrong or locked
- Its hover is a Raised, borderless fill with a primary glyph; its focus is the system outline
- Its sizes and hit areas per place, as the table above; 28×28 and 26×26 on phones, where the rows leave no more
- Long names are met with a width cap plus a smaller pill, not with a fixed grid of equal columns: short names keep flowing as they do today, and nothing needs to measure text
- The small pill's text is 20px at both 1280×800 and 1280×720 (one size for every window under 820px tall), so ordinary 20-character names show whole. Keeping 24px text in a 4-row layout would cut most of them
- A new 18px bot mark size for 20px names

Behaviour a user would notice, for triage:

- **When the small pill applies.** It goes by the number of players (7 or 8) and the window's height, not by how long the names are. So a room of 7 or 8 short names on a laptop under 820px tall also gets 20px pills, where the spec's Fit bullet says 24px pills at 1280×800 "where they fit". Chosen because it is guaranteed by construction and CSS-only (`:has(> li:nth-child(7))` or a class from the count); a rule by name length cannot be guaranteed without measuring text, and with remove controls even 10-character names can reach four rows at 24px (three "Medium bot" pills and five people). The spec sentence would need "with 7 or 8 players the pills take the small size"
- **1440×900 with 7 or 8 players:** the pills step down to 44px tall with 12px gaps (text stays 24px)
- **The cap of a third at 1080px tall and up** is a proposal beyond the brief's windows: without it 8 names of 20 characters can reach four rows at 1920×1080 (320px in 256px of room). It changes nothing for names of up to 10 characters. Not drawn on a board
- **Keyboard focus after a removal.** The broadcast replaces the list, so focus would be lost. Proposed: when the removed bot's control had focus, focus goes to the remove control of the bot that takes its place in the list, else the previous bot's, else the first add-bot button (Easy). Only on the screen that removed it
- **Hover** shows only where the device hovers (`@media (hover: hover)`), so a tap on a phone leaves no stuck hover look

States with no new board:

- **Host alone after a removal, player screen:** `bot-waiting-p-alone-light` (v8) stands as this state: "Waiting for more players to join…" with the add-bot control enabled, and no remove control since no bot is left
- **Other players' player screens:** the roster as the v8 boards draw it, bots with their mark and ✓, no remove control and no add-bot row. No board
- **No error, pressed or pending state** is drawn: a refused or stale removal shows nothing

Where the new boards and older ones differ:

- `bot-big-waiting8-light` (v8, 1280×800) draws the hero from before ticket 72 (288px QR, 24px link, no band under the play area, Start game with 30px text, "6 of 8 ready" at 24px) and 24px pills for 8 players. `bot-big-long800-light` draws the built hero (above), Start game with 36px text and the count at 30px as the code has them, the empty 144px band under the play area, and the small pills. The rail is the same on both
- `bot-big-botsonly-dark` (v8, 1920×1080) centres the play area in the full height; `bot-big-one-light` centres it above the 144px band, as the code does
- `bot-big-long720-dark` draws the rail with ticket 71's orientation sizes (12px under the add-bot tile, 6px under the label, 44px rows with 24px names and 30px scores, 4px apart): the code is the truth there, this is no design decision

## Open questions

- **1366×768 with 5 or 6 long names.** Three rows of the built pill (48px, 12px gaps: 168px) are 8px more than the 160px the play area has there, 4px past its box at top and bottom, nothing reaching the band. It needs 5 or 6 names all over about 13 characters. Left as built. Dropping the list's row gap to 8px under 820px tall would close it (160px) and move 1280×800 rooms by 4px when their pills wrap
- **Between the named windows** the built steps are tighter than the pills: at 740px to 761px tall the hero and Start game leave under 154px, and at 820px to 887px under 212px. The rule fits every window the spec names; a fit at every height would need the hero's steps changed, which this brief leaves alone
- **A window 1080px tall or more but narrow** (under about 1770px wide) is not one the spec names: a third of its row is too little for a bot's pill at 30px. Say if the cap there should be half the row instead

## Artboards added or changed

Added, in a new row under the title note "12 · Bots · remove control and long-name pills (tickets 48, 73)" (`t48-73-bots`, y 45874), below the "11 · Bots" row, at y 46154. No existing board changed.

- `bot-big-long800-light.dc.html`: big screen, 1280×800, light. Waiting, 8 players: 5 people with names of 17 to 20 characters (one of twenty W's, cut with an ellipsis) and 3 bots, each bot's pill with its mark, ✓ and remove control. Small pills in 4 rows, "6 of 8 ready", Start game enabled, add-bot control disabled with "Room full". Easy bot's remove control with keyboard focus, Hard bot's with the hover look
- `bot-big-long720-dark.dc.html`: big screen, 1280×720, dark. The same 8 players and controls at the shortest window, 160px QR. Easy bot 2's remove control with keyboard focus
- `bot-big-one-light.dc.html`: big screen, 1920×1080, light, in a 2400×1080 frame. Waiting with one person after a removal: no bots, Start game disabled with "Need at least 2 players", add-bot control enabled, no remove control. Right of the screen, outside its 1920×1080, a 480px callout with one bot pill at its 1920×1080 size: 30px name, 26px bot mark, 44×44 remove control with a 24px glyph
- `bot-remove-p8-dark.dc.html`: host's player screen, 375×667, dark, portrait. Waiting, 8 players with 3 bots, before voting (I'm ready), add-bot control disabled with "Room full". Remove control on each bot row, Hard bot's with keyboard focus
- `bot-remove-l7-light.dc.html`: host's player screen, 667×375, light, landscape. Waiting, 7 players with 2 bots, before voting, add-bot control enabled. Remove control on each bot row, resting
- `bot-remove-c7-dark.dc.html`: host's player screen, 1024×640, dark, computer. Waiting, 7 players with 2 bots, before voting, add-bot control enabled. Easy bot's remove control with the hover look, Hard bot's with keyboard focus

`project/canvas.json` gained the six boards, their places in `order` and the title note. Canvas: https://claude.ai/artifact/123TNq7nwcKGoXDaroSGcM
