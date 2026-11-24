Canvas: https://claude.ai/artifact/123TNq7nwcKGoXDaroSGcM. Written against docs/design-system.md v9, 2026-11-24.

# Design brief: tickets 48 and 73

## Context

Onset is a real-time multiplayer web version of the card game Set. Each player plays on their own player screen, a phone or a computer, and an optional big screen (a TV or laptop) shows the room to the whole table. Every page comes in two themes, Dark and Light, picked per browser in the settings menu. A light screen changes colors only: every element, size and position is the dark screen's (Shared: Rules added in v6).

Glossary term these screens show: **Bot**: "A player Onset plays itself, added (and removed) by the host while the room is waiting, at Easy, Medium or Hard. It only claims Sets, after a delay its level sets, and never votes." User-facing text says "bot". The **host** is the browser holding the room's `host_game` cookie.

Two tickets, drawn together because both change the big screen's waiting pills:

- **48: the host can remove a bot from a waiting room.** A remove control on each bot's pill on the big screen's waiting state and on each bot's row in the waiting roster of the host's own player screen. One tap removes the bot, no confirmation. The bots themselves (the bot mark, the add-bot control, the waiting boards) were drawn in the previous round (ticket 47, design system v8, canvas row "11 · Bots") and v8 left room for this control. Those bots are not built yet; the boards are the reference.
- **73: the big screen's waiting pills fit laptops 800px tall and shorter with long names.** With 8 players whose names run to 20 characters, the 1280px-wide waiting screen wraps its pills to four rows, which pushes the join hero off the window at 1280×800 and shorter. The pills need a long-name layout.

## What to design

Six boards, no more. Each is self-contained (imports no themed component, as the "11 · Bots" boards are) and is added in a new row under the title note "12 · Bots · remove control and long-name pills (tickets 48, 73)", below the "11 · Bots" row. One theme per board, alternating so both themes show the remove control: a light screen changes colors only (Shared: Rules added in v6), so a second theme of the same size would draw the same layout again.

Big screen (the waiting state; the player pills sit in the play area, the add-bot tile heads the rail as `bot-big-waiting8-light` draws it):

1. **`bot-big-long800-light`, 1280×800, light.** Waiting, 8 players: 5 people with names of 17 to 20 characters (for example "Alexandria Pemberton", 20; "Bartholomew Nakamura", 20; "Maximilian Oyelaran", 19; "Samuel Wainwright", 17; "Priyanka Ramanathan", 19) and 3 bots ("Easy bot", "Easy bot 2", "Hard bot"), each bot's pill with its bot mark, its ✓ and its remove control. "6 of 8 ready", Start game enabled, the add-bot control disabled with "Room full" (every color taken). One bot's remove control with keyboard focus, another with the hover look. The QR at least 160px, the join link on one line under its tile, the room code on one line, everything inside the play area and above the announcement band, no page scroll. Show where each name truncates, if any.
2. **`bot-big-long720-dark`, 1280×720, dark.** The same 8 players, the same controls, at the shortest window the spec names. The QR at least 160px and nothing under the announcement band. One bot's remove control with keyboard focus. Show every name that still truncates with its ellipsis, and that the dot, ✓, bot mark and remove control stay in full.
3. **`bot-big-one-light`, 1920×1080, light.** Waiting after a removal that leaves one person: the one person's pill, no bots, Start game disabled with "Need at least 2 players" as the built `l-big-waiting1` draws it, the add-bot control enabled (the removal freed a color), no remove control anywhere (a person is never removed and no bot is left). The 1920 sizes are as built. Because no bot pill is on this board, add one small callout beside the screen, outside its 1920×1080 frame, that draws a single bot pill (bot mark 26px, 30px name) with its remove control at its 1920×1080 size, so the return can give that size.

Host's own player screen, waiting (the remove control on a bot's roster row; the add-bot row under the roster as `bot-waiting-p8-dark`, `bot-waiting-l7-dark` and `bot-waiting-c7-light` draw it; no page scroll):

4. **`bot-remove-p8-dark`, 375×667, dark, portrait.** 8 players with 3 bots, before voting (I'm ready shown), the add-bot control disabled with "Room full". Remove control on each bot row, one with keyboard focus.
5. **`bot-remove-l7-light`, 667×375, light, landscape.** 7 players with 2 bots, before voting, the add-bot control enabled. Remove control on each bot row.
6. **`bot-remove-c7-dark`, 1024×640, dark, computer.** 7 players with 2 bots, before voting, the add-bot control enabled. Remove control on each bot row, one with the hover look and one with keyboard focus.

States the design must cover, each on the board named:

- **Resting, hover and keyboard focus** of the remove control (boards 1, 2, 4 and 6). Hover exists only where the device hovers (computer and the big screen), so no hover on phone boards 4 and 5
- **Pressed or pending:** none. The action answers 204 and the broadcast removes the bot, so the control does not change, as the add-bot control does not (SPEC Removing a bot, Actions answer 204)
- **After a removal that leaves one person:** the big screen (board 3) reads "Need at least 2 players". The player screen reads "Waiting for more players to join…": `bot-waiting-p-alone-light` (v8) already draws that state with the add-bot control enabled, so no new board draws it. State in the return that it stands as the host-alone state after a removal
- **Other players' player screens** show the bots with their mark and ✓ and no remove control (SPEC Player screen, 1. Waiting): no board, say so in the return
- **No error state.** A removal over its rate limit answers 429 and changes nothing, and a stale one is ignored (still 204): the screen shows nothing for either, as it shows nothing for an add. Draw no error state
- **Light and dark:** both themes through the boards above; the return gives the remove control's color in each theme and its contrast

Things the design tool decides (visual choices, recorded under "Decisions the spec does not cover"): the remove control's glyph and size per place, its hit area (at least 24 CSS px square, WCAG 2.2 AA, on every place; larger where the pill or row has room), its color in each state (never red or green: Each color means one thing), its hover and focus look, and, for ticket 73, the pills' long-name layout (columns, smaller text or both), the text size at each height, and where a name truncates. Give the pill layout's rule in words and numbers the build can follow at 1280×800 and 1280×720, and say what 1366×768, 1440×900 and 1280×1024 take (the spec asks the fit from 1280×720 up).

## Spec facts, per screen

Quoted from `SPEC.md`, each with its heading.

### Everything about removing a bot (AI opponent, Removing a bot)

- "**Who and where**: the host, as for adding one (`host_game` cookie), with the remove control on each bot: its pill on the big screen's waiting state and its row in the waiting roster of the host's own player screen (§8). `DELETE /games/:code/bots/:id` (§5) checks the cookie, as Start game does. Its accessible name is "Remove Easy bot", the bot's name after "Remove"; its look comes from the design pass"
- "**When**: only while the room is waiting, as adding; once play starts the controls go and a bot stays to Play again and beyond. The server checks the room is waiting inside the game lock, as starting does (§6 Key invariants), so a removal racing the start (the last ready vote or Start game) either lands first, and the bot never plays, or is ignored, and the bot plays. A person is never removed: the control is on bots only and the server ignores any other id"
- "**At once, no confirmation**: one tap removes the bot, because adding it back is one tap too. The `Player` row is deleted: a waiting bot has no claims and no timer yet, its timers start with play (How a bot plays)"
- "**What follows**: the bot leaves every roster, pill and count on every screen at once, by broadcast (§7), its color goes back to the free ones and its name can be taken again (Adding a bot). It leaves the ready vote with it: "n of m ready" and the player count drop, and a room left with one person reads "Need at least 2 players" on the big screen and "Waiting for more players to join…" on the player screen again. A removal never starts the game: a room in which every person had voted would already be playing. With a color free again, a disabled add-bot control comes back at once, and the join page, which does not update live (§8), offers that color on its next load"
- "**Telemetry**: the tap sends `bot_removed` (§17)" (Shared: 17. Telemetry, Custom events: `bot_removed`, `level`: `easy`, `medium` or `hard`, the removed bot's)

### Everything about bots on these screens (AI opponent, Adding a bot)

- "A **bot** is a player Onset plays itself (`GLOSSARY.md`), so a room can play with fewer people, a single person included"
- "**Name and color**: "Easy bot", "Medium bot", "Hard bot"; a second bot at the same level is "Easy bot 2", and so on, so names stay unique (§4). A new bot takes the lowest free name of its level, matched case-insensitively as §4 matches names, so after a removal (Removing a bot) "Easy bot" is used again before "Easy bot 3", and a name a person already took ("easy bot") is skipped. The first free color in preset order, as the join page selects one"
- "**Ready at once**: a bot counts as voted in the ready vote from the moment it joins, so its ✓ shows at once. A room starts with at least 2 players, bots included, and at least one person: the ready vote starts it when every person has voted, and the big screen's Start game is disabled while every player is a bot, since nobody could call No Set or vote to end"
- "**Shown everywhere a player is**: ... with a bot mark beside the name. The mark is not decoration: it reads "bot" to a screen reader (`role="img"`, `aria-label="bot"`), so "Easy bot, bot" is heard in every list, pill, row and announcement"
- "With every color taken the three buttons are disabled, as Join is on a full room, with the reason "Room full" beside them" (the add-bot control; a removal frees a color and the control comes back at once)
- Shared: 4. Data Model, `Player`: "`name` string 1–20 chars, displayed"; "The 8-player cap. Eight presets, each unique in a room, cap a room at 8 players, people and bots alike"

### Shared: 7. Realtime, Actions answer 204

"Every action a player screen or the big screen sends (SET!, a card pick, Submit, No Set, agree, There's a Set, End game, ready, Start game, Play again, adding and removing a bot) answers `204 No Content`. The answers a stale page or a script meets instead (`403`, `404`, `406`, `422`, `429`) are listed in §5, URL surface. Turbo leaves the page alone, and the broadcast the action triggers updates every screen, including the one that acted."

Shared: 5. Routes, URL surface and Rate limits: `DELETE /games/:code/bots/:id`, "The host (`host_game`, `403` otherwise) removes that bot from the room (AI opponent, Removing a bot). Ignored, still `204`, unless the room is waiting and `:id` is a bot of this room: a person is never removed, and a second tap on a bot already gone changes nothing". "The host's bot controls (ticket 62): adding and removing a bot in the waiting room, one count across the two, 30 a minute ... A refused add adds no bot and a refused removal leaves the bot in the room." A `429` "changes nothing", so there is no refusal state to draw.

### Big screen, waiting (8. Big screen (`/games/:code`), Waiting)

"**Waiting**: a join hero with a 288px QR (smaller on shorter windows: Fit, below) and, under it, a **Join from this computer →** link that opens the join page in a new tab, for someone playing on the same computer as the big screen. A browser holds one player (one `player_token` cookie), so a second player on that computer needs a private window or another browser. Beside the QR, "Scan to join, or open HOST and enter" and the room code at up to 10rem, shrinking with the viewport so it never runs past the play area into the rail. The hero's text wraps or shrinks the same way. Player pills with a ✓ once ready, bots included with their bot mark (AI opponent). `#start_button`: **Start game** with "n of m ready" beside it, or disabled with "Need at least 2 players", or with "Need a person to play" when every player is a bot. The **add-bot control** (AI opponent) sits in the waiting state, and each bot's pill carries a **remove control** (AI opponent, Removing a bot), both shown on every big screen and accepted from the host only, as Start game is."

### Big screen, Fit (8. Big screen, Fit), the heart of ticket 73

"**Fit**: with 8 players, their names up to the 20 characters a name may have (§4), the play area keeps everything inside its own box, under the top padding and above the announcement band, waiting and ended alike, on every window from 1280×720 up (1280×720, 1366×768, 1280×800, 1440×900 and 1280×1024 among them, as at 1920×1080). On a shorter window the join hero (the QR on its tile, the **Join from this computer →** link, the hero text and the room code), the player pills and `#start_button`, and once ended "Game over", the headline, the podium and **Play again**, shrink with the window's height, the code choosing the sizes; at 1280×800 the hero takes the design system's 1280×800 board sizes where they fit (an 80px room code, 24px and 20px hero text, 24px pills with 16px dots, an 80px Start game). The QR is never under 160px, so a phone still scans it, and the link stays on one line under its tile, no wider than it. Long names do not push the hero under that floor: 8 pills of 20-character names wrap to four rows at 1280px wide, so the pills take the long-name layout the design system draws (Screens > Big screen), and each pill shows its whole name where that layout fits it; a name that still does not fit truncates with an ellipsis, as the rail's rows do, while the dot, the ✓, the bot mark and the remove control always show in full. The winner's name is never cut: a long one wraps the headline to a second line, and the play area still fits. At 1920×1080 every size is as built for names of up to 10 characters."

So, for ticket 73 the pills take a layout the design pass draws: at 1280×800 and 1280×720 with 8 players, 20-character names, the QR at least 160px, nothing under the announcement band (always 9rem), and nothing in the rail changing (the rail's rows already truncate; tickets 67 and 71 own its sizes; the No Set and claiming headlines' long names stay out, DESIGN Open questions). At 1920×1080 the pills are as built.

### Big screen rail while waiting (8. Big screen, Scoreboard; AI opponent, Adding a bot)

"The room tile is hidden while waiting" and the add-bot tile heads the rail in its place (`bot-big-waiting8-light`); with 8 players every row shows in full and the rail ends above the settings button on every window from 1280×720 up. This brief changes neither; draw the rail as `bot-big-waiting8-light` does (52px rows at 1280×800, tighter under 800px tall, the code choosing: SPEC Scoreboard, tickets 67 and 71). The removed bot leaves the rail's Players list as well.

### Player screen, Waiting (8. Player screen, 1. Waiting)

- "**Waiting**: "You're in", a two-column roster with "you" and ✓ marks, then **I'm ready** ... Alone in the room, a player cannot vote: "Waiting for more players to join…" takes the place of I'm ready ... A bot in the room counts as a player here, so a person with a bot can vote and play (AI opponent). Bots sit in the roster with their bot mark and ✓."
- "On the host's own player screen (the player who joined from the host browser, §4 `host_player_id`) the waiting screen also carries the **add-bot control** (AI opponent), and each bot in the roster a **remove control** (AI opponent, Removing a bot). Other player screens show the bots, not the controls."
- "With 8 players and the invite, and on the host's screen the add-bot control and the remove controls, there is no page scroll at 375×667 portrait, 667×375 landscape and 1024×640. The exact layout comes from the design pass."
- The roster is two columns, each row a dot, the name (truncated), "you" for the player, the bot mark for a bot and a ✓ once ready. The remove control sits after the ✓ at the row's right end (design system v8, Room for ticket 48's remove control).

### Settings button (8. Settings menu)

The menu and its button never move SET!, the pill slot or the board, and keep the no-page-scroll rules. On the big screen the button is 56×56, bottom-right, 40px in from both edges, under the rail.

## Design rules, quoted verbatim from docs/design-system.md v9

### Shared: Tokens (excerpt)

| Token | Value | Use |
|---|---|---|
| `--font-display` | Bricolage Grotesque, ui-sans-serif, system-ui, sans-serif | Display text only |
| `muted` (v7, dark only) | `#7C8390`, on the gray hue a third of the way from `gray-500` to `gray-400`, outside the Tailwind palette | Dark muted text and dark form placeholders (Shared: Themes (v6), Text). Light muted stays `gray-500` |

Player colors (`Player::PRESET_COLORS`): `#E74C3C #2ECC71 #F1C40F #9B59B6 #1ABC9C #E91E63 #00BCD4 #8BC34A`.

v2 adds no tokens: every new color is from the Tailwind default palette. v7 adds `muted`, the one color outside it. v8 adds none: the bot mark and the add-bot control use existing roles (secondary text, raised bordered, the disabled gray button, the focus outline, the band name colors).

### Shared: Themes (v6) (excerpt)

Two themes, Dark and Light, each color one CSS value per theme keyed on `<html>`, on the same markup. Dark is every value this file gave before v6, but for the three dark rows v7 raises to contrast (ticket 46): muted text, placeholders and the field border at rest. Ratios are WCAG contrast on the value's own ground: the light page (`gray-50` `#F9FAFB`) unless stated; dark ratios, where given, on `gray-950` `#030712` unless stated. Every value is from the Tailwind default palette but dark `muted` `#7C8390` (Shared: Tokens).

Surfaces and borders

| Role | Dark | Light | Light ratio |
|---|---|---|---|
| Page | `gray-950` | `gray-50` `#F9FAFB` | ground |
| Panel | `gray-900` | white; a panel with no border gets an `inset 0 0 0 1px` `gray-200` edge | ground |
| Raised, bordered (Join, Copy link, Show QR) | `gray-800`, border `gray-700` | `gray-100`, border `gray-300` | `gray-900` text 16.12:1 |
| Own scoreboard entry | `gray-800`, border `gray-500` | `gray-100`, border `gray-500` | |
| Raised, borderless (SET! while unavailable, Join with a room code) | `gray-800` | `gray-200` | `gray-800` text 11.85:1 |
| Border, strong (toggle tracks, settings menu, QR sheet) | `gray-700` | `gray-300` | decorative |
| Border, subtle (panel borders, header rule, dividers, settings button) | `gray-800` | `gray-200` | decorative |

Text

| Role | Dark | Light | Light ratio |
|---|---|---|---|
| Primary | `gray-50` (white on the big screen) | `gray-900` | 16.98:1, 17.74:1 on white |
| Values (`gray-200`: host name, How to play values, tip text) | `gray-200` | `gray-800` | 14.05:1 |
| Body (`gray-300`: tagline, sub-lines, captions, "is calling SET!") | `gray-300` | `gray-700` | 9.86:1, 10.31:1 on white |
| Secondary (`gray-400`: labels, deck line, "you", byline) | `gray-400` | `gray-600` | 7.23:1, 7.56:1 on white |
| Muted (Room CODE footer, tray slot numbers, player screen settings icon, big screen empty band, "No one yet" and a locked player's row, the "/N" of the No Set count, join page hint) | `muted` `#7C8390` (v7, was `gray-500`): 5.28:1 on `gray-950`, 4.88:1 on the No Set band (`#130F29`), 4.65:1 on `gray-900`; never on `gray-800` (3.85:1) | `gray-500` | 4.63:1, 4.84:1 on white, 4.51:1 on the No Set band (`purple-50`); never on `gray-100` (4.40:1) |

Dark text ladder on `gray-950` (v7): primary 19.27:1, values 16.25:1, body 13.66:1, secondary 7.93:1 (6.99:1 on `gray-900`), muted 5.28:1.

Meaning colors as tinted panels (the rows these screens use)

| Panel | Dark | Light |
|---|---|---|
| Ready ✓ waiting | `green-700` at 12%, `green-700` border, `green-300` text | `green-50`, `green-700` border, `green-800` text |

Meaning colors as text

| Role | Dark | Light | Light ratio |
|---|---|---|---|
| Green (✓, all the same, Right: +1) | `green-400` | `green-700` | 4.80:1 |
| Red (field errors, ✗, Wrong) | `red-400` (`red-300` label, `red-200` value in the Not a Set row) | `red-700` (label), `red-800` (value) | 6.19:1, 7.60:1 on `red-50` |

Disabled, rings, outlines and the rest (the rows these screens use)

| Role | Dark | Light |
|---|---|---|
| Disabled gray button (Start game with 1 player, Join when full) | `gray-800` + `gray-500` (not `muted`: disabled labels are exempt, v7) | `gray-200` + `gray-600` (6.10:1) |
| Focus outline, 2px, offset 2px | `blue-500` | `blue-500` (3.52:1, 3.68:1 on white) |
| QR tile | white, dark modules | the same, plus the 1px `gray-200` inset edge |
| Shadows | cards `rgba(0, 0, 0, 0.55)`; banner and menu `rgba(0, 0, 0, 0.6)` | cards `rgba(3, 7, 18, 0.16)`; banner 0.12; menu 0.18 |
| `theme-color` | `#030712` | `#F9FAFB` |

### Shared: Rules added in v2 (excerpt)

- Taken color swatch: the preset blended 30% over the page (`gray-950`, light `gray-50`) with the initial in `gray-300` (light `gray-700`), not opacity, which would fade the initial too

### Shared: Rules added in v6 (excerpt)

- Two themes, Dark and Light. A light screen changes colors only, plus the card wrapper's edge: every element, size and position is the dark screen's. Values in Shared: Themes (v6)
- A panel with no border (big screen room tile and player pills, How to play panels, the QR tile) gets a 1px `gray-200` inset edge in light, as a `box-shadow`, so nothing resizes. Panels that already have a border keep it, recoloured
- Light muted text (`gray-500`) sits only on the page or on white in light, never on `gray-100`. Dark muted: Shared: Rules added in v7
- The settings button never moves SET!, the pill slot or the board, and adds no page scroll. On the player screen it lives in the "Room CODE" footer row

### Shared: Rules added in v7

- Dark muted text and dark placeholders are `muted` `#7C8390`, never `gray-500`. Dark muted sits only on `gray-950`, `gray-900` (the placeholders in their fields) or the No Set band, never on `gray-800` (3.85:1)
- The player screen settings button icon follows muted in both themes (dark `#7C8390`, 5.28:1; its bar is 3:1 as a graphic), so the "Room CODE" footer row stays one shade
- Stays as built: disabled controls keep `gray-800` with `gray-500` text, and every `gray-700` border that is not a form field stays `gray-700` (the mode toggle's track, the Join, Copy link and Show QR buttons, the settings menu, the QR sheet, the empty tray slot's dashed border)

### Shared: Rules added in v8

- A bot shows the bot mark (Components > Bot mark) right after its name everywhere a player's name shows: big screen pills, rail scoreboard rows, the announcement band, the ended headline and the podium; player screen roster, play scoreboard chips and rows, the status panel, the found-set banner, the winner line and the standings. It comes after "you" where both show, and before the ✓, the Locked tag and the score, so it never moves those
- The mark takes secondary text (`gray-400` dark, `gray-600` light); on a claim-filled entry (`yellow-400`) the entry's `gray-950` text; in a band the band's name color
- The add-bot control (Components > Add-bot control) sits on the big screen's waiting rail and under the host's own waiting roster, nowhere else. It exists only while waiting, so it never moves SET!, the pill slot or the board
- Room for ticket 48's remove control: on a bot's big screen pill, after the ✓ (pills are content-sized and wrap; `bot-big-waiting8-light` leaves a third pill row free at 1280×800); on a roster row, after the ✓ at the row's right end, where it truncates the name further rather than moving anything
- New dark boards (v8 on) draw muted as `muted` `#7C8390` (the "Room CODE" footer, the player screen settings icon)

### Shared: Rules added in v9

- A locked player's entry quiets its text with a color, never with opacity: text faded by opacity falls under 4.5:1 on its ground. Muted on a plain entry, as the big screen's locked row; secondary on the player's own entry, since muted never sits on `gray-800` (dark) or `gray-100` (light). Only the player's dot keeps the 45% fade
- Built boards still draw the locked entry at 45% opacity; this file wins

### Shared: Visual rules, SPEC §10 (excerpt)

- "**Text** at least 4.5:1 on its ground, the page or the panel it sits on, whatever its size ... The labels of disabled controls are exempt, as WCAG makes them, and keep the disabled looks `docs/design-system.md` gives"

Each color means one thing everywhere:

| Color | Meaning |
|---|---|
| blue-600 | SET! and primary actions |
| violet-600 | quick game |
| yellow-400 | a claim in progress (big screen panel, scoreboard entries, player screen claim bar) |
| purple | No Set. It used to be red; red now only means wrong or locked |
| red | wrong claim, timeout, lockout |
| green | ready, correct, start, play again (`green-700` for white text; `green-600` is only about 3.3:1) |
| orange | deck empty and the End game vote (`orange-700` for white text; `orange-600` is only about 3.3:1) |

Player colors are the 8 presets in `Player::PRESET_COLORS`, deliberately apart from both card palettes. They show as dots, the player screen's top border strip and podium bars.

### Components (excerpt)

- `games/_start_button`: Start game with "n of m ready", or disabled with the reason. v8: the reason "Need a person to play" while every player is a bot, in the disabled gray button with the reason beside it in secondary text at the size of "Need at least 2 players", tied to the button with `aria-describedby` (board `bot-big-botsonly-dark`)
- `players/controller/_roster` (v2): the Waiting roster, two columns, each a dot, the name, "you" for the player and a `green-400` ✓ once ready. v8: a bot's row carries the bot mark after the name, and its ✓ from the start
- `players/controller/_invite` (v2): the room code in display type, "or open onset.joaotorr.es and enter the code" (`join_host`), the link button (Copy link, Copied ✓, Couldn't copy, Share link), a Show QR button and the "Show on a big screen →" text link

Bot mark (v8): the Lucide-style "bot" glyph (a rounded head with an antenna, two eyes and two ears), inline stroke SVG, 24 viewBox, stroke 2 (2.4 at 11px), round caps and joins, `stroke="currentColor"`. Not decorative: it is the one sign of a bot that does not rely on the name, so it carries accessible text (what it reads: SPEC, AI opponent). Its color and place: Shared: Rules added in v8. Contrast, as a graphic (3:1 bar):
  - `gray-600` light: 7.56:1 on white, 7.23:1 on `gray-50`, 6.8:1 on the `gray-100` own row
  - `gray-400` dark: 7.8:1 on `gray-950`, 6.8:1 on `gray-900`, 5.6:1 on the `gray-800` own entry
- Sizes, per place; the gap to the name is the row's own (4 to 12px):
  - Big screen waiting pills: 26px at 1920 (30px names), 22px at 1280 (24px names)
  - Big screen rail scoreboard rows: 26px
  - Player screen waiting roster: 14px portrait, 13px landscape, 16px computer
- Portrait chips are 83px wide, so a bot's name truncates there ("Easy…") like any long name; the mark and the dot still tell it apart

Add-bot control (v8): a group of three equal buttons, one per level, Easy, Medium and Hard, each a 2.5-stroke "+" glyph then the level, in the Raised, bordered style of Copy link and Show QR (dark `gray-800`, `gray-700` border, `gray-50` text; light `gray-100`, `gray-300` border, `gray-900` text, 16.12:1). No picker and no open state. What a tap does, its accessible names and its disabled reason's words: SPEC, AI opponent
  - Big screen: a panel tile at the top of the rail while waiting, in the room tile's place (the room tile is hidden while waiting); gone once play starts. Panel, radius 24, padding 20, the light inset edge. "ADD A BOT" label 18px uppercase, 0.1em tracking, secondary text, as "ROOM" and "PLAYERS". Then the three buttons, 56px tall, radius 14, gap 10, 22px semibold, 18px "+". Tile 136px tall, 16px shorter than the room tile, so the rail is no taller while waiting than in play
  - Player screen, host only, while waiting: one row right under the roster, before the invite. The label "Add a bot" in a fixed column on the left, then the three buttons. Portrait: 44px tall, label column 72px, 14px semibold label, 15px buttons, 14px "+", radius 12, gap 8. Landscape: 40px tall, label column 64px, 13px label, 14px buttons, 13px "+", in the roster column. Computer: 48px tall, label column 88px, 16px label and buttons, 16px "+", inside the roster panel
  - Focus: the 2px `blue-500` outline at 2px offset on the focused button (boards `bot-big-botsonly-dark`, `bot-waiting-p-alone-light`)
  - Pressed or pending: none. The action answers 204 and the broadcast adds the bot; the control does not change
  - Disabled, every color taken: all three take the disabled gray button (`gray-800` + `gray-500` dark, `gray-200` + `gray-600` light, 6.10:1; labels exempt), the border set to the fill so nothing resizes, `disabled` and `aria-describedby` on the reason. The reason sits at the right of the big screen tile's label row (18px, secondary) and under "Add a bot" in the player screen's label column (12px, secondary) (boards `bot-big-waiting8-light`, `bot-waiting-p8-dark`)
  - No size moves between states

Settings button (v6): ... Big screen: 56×56, radius 16, 26px icon ... Where it sits on each screen: Screens below. Settings button placement: "Big screen: 56×56, bottom-right, 40px in from both edges, under the rail; the menu opens 40px from the right and 108px from the bottom"; "Player screen, portrait: in the "Room CODE" footer, 8px from the right edge, in every state".

### Screens (excerpt)

Sizes are the boards': portrait 375×667, landscape 667×375, computer 1024×640, landing desktop 1280×800.

Big screen (tickets 21, 40, 47):
- Drawn in light for every state (`l-big-*`, `BigScreenTh`), and in dark for waiting and ended (`d-big-waiting4`, `d-big-waiting1`, `d-big-ended`), which had no dark board before v6
- The room tile, the player pills and the QR tile get the light inset edge; band panels follow the light tinted panel rows
- Bots (v8): `bot-big-waiting8-light` (1280×800, 8 players with 3 bots, add-bot control disabled), `bot-big-botsonly-dark` (bots only, "Need a person to play", add-bot control focused) ... Waiting: the add-bot tile heads the rail, the Players scoreboard under it. Each board is self-contained and imports no themed component
- `bot-big-waiting8-light` draws the 1280×800 waiting state smaller than 1920: room code 80px, hero text 24px and 20px, pills 24px with 16px dots, Start game 80px tall, rail rows 52px (padding 8px 16px, 36px scores, 6px gaps) so 8 rows fit under the add-bot tile and clear the settings button. The code is the truth for how the built hero and rail shrink; the rail's clearance at 1280: SPEC §8 Big screen, Scoreboard (triage 67)

Player screen, Waiting (tickets 10, 47):
- Header, then "You're in", the roster, the invite and I'm ready (`green-700`). Once voted: "Ready ✓ · waiting for n more" as outlined `green-700` text on a 12% `green-700` tint, `green-300` text
- Landscape and computer put the roster and the invite side by side
- Host's screen (v8): the add-bot control's row right under the roster, before the invite in portrait, in the roster column in landscape and inside the roster panel on computer; no page scroll with 8 players in portrait and 7 in landscape and computer (the two-column roster is 4 rows at 7 as at 8). Boards `bot-waiting-p-alone-light`, `bot-waiting-p8-dark`, `bot-waiting-l7-dark`, `bot-waiting-c7-light`. Other players' screens: the roster as those boards draw it, bots with their mark and ✓, and no add-bot row (the roster runs straight into the invite)
- Host alone (v8): `bot-waiting-p-alone-light` draws "Waiting for more players to join…" as plain secondary text centred in the 56px I'm ready slot; the built `waiting-p-1` look wins where it differs

### Changed since the boards

The canvas was last handed off at v8. The design system is at v9. Two v9 entries came after; neither redraws a board, and the boards do not show them yet. Apply them to any board this brief touches:

- "v9, 2026-11-24: ticket 82, the records corrected to the build, nothing new designed: the portrait tray's empty slot number is 24px (`text-2xl`), as built, not 22px." (Touches the play screen only; no board here.)
- "v9, 2026-11-24: ticket 76, a small visual fix, not from a design pass: a locked entry on the player screen's play scoreboard keeps its name and score at full opacity in muted text, secondary on the player's own entry, so both read at 4.5:1 or more in both themes; only the dot stays faded (Components > players/controller/_scoreboard, Shared: Rules added in v9)." (Play scoreboard only; no board here.)

Where the code and a board differ for a built screen, the code is the truth: the big screen's waiting hero at 1280×800 and below is built (ticket 72, deployed): the room code 80px, hero text 24px and 20px, pills 24px with 16px dots, Start game 80px, the QR shrinking down to 160px. The new big screen boards 1 and 2 start from those sizes, and from the rail of `bot-big-waiting8-light` (tickets 67 and 71 own the rail's sizes), and replace the long-name layout only.

## Boundaries

- Change no existing board. This brief adds the six boards above under a new title note and changes nothing else on the canvas
- `l-big-waiting4`, `l-big-waiting1`, `d-big-waiting4` and `d-big-waiting1` (1920×1080, as built: ticket 72 left 1920 as it was) stay as they are, and so does every `bot-*` board of the "11 · Bots" row: their screens (bots, the add-bot control) are not built yet (tickets 68 to 70), so the design tool still owns them and this brief only adds beside them. Where a new board and an older one differ, say so in the return
- Draw the bots and the add-bot control as the "11 · Bots" boards do; do not redesign them. Ticket 62's rate limit, ticket 68's add route and ticket 70's host row are not changed here
- The No Set and claiming headlines' long names, the rail's rows and the playing and ended states stay out of this brief
- Add the six boards to `project/canvas.json` and no other board

## The return

When the design is done, write the return in the format below, and begin it with the `Design return` line: no command such as `/request` or `/design-entry`, since a pasted command does not run. Write `None` under a heading with nothing in it.

```
Design return for tickets 48, 73.

## New tokens
## New components
## New or changed rules
## Decisions the spec does not cover
## Open questions
## Artboards added or changed
```

What each heading must hold for these tickets:

- **New components:** the remove control: its glyph, its size and hit area on each place (big screen at 1280 and at 1920, host's player screen in portrait, landscape and computer), its resting, hover and focus looks in both themes with colors and contrast, and its accessible name ("Remove Easy bot", the bot's name after "Remove")
- **New or changed rules:** the big screen waiting pills' long-name layout (ticket 73): the rule in words and numbers a build can follow at 1280×800 and 1280×720, what the pill sizes are at each height, where a name truncates (the number of characters or the width), that the dot, ✓, bot mark and remove control stay in full, and what 1366×768, 1440×900 and 1280×1024 take. The QR floor of 160px and the 9rem band stay
- **Decisions the spec does not cover:** each visual choice you made, and, as a behaviour a user would notice, anything the spec does not decide (for example where keyboard focus goes after the focused bot is removed)
- **Artboards added or changed:** the six boards, with each one's state, size and theme, and the title note

## How every reply ends

End every reply with:

1. **Pending decisions:** what you need from me before going on, each
   a bold title on a line of its own, not a bullet, explained so I can
   decide without opening anything else, then each option a line of its
   own starting with its bold number, `**1.**`, never a list item, your
   recommendation first.
   The numbers run on through all the decisions, never restarting, so I
   can answer with numbers alone ("1, 4"). `None` when there are none.
2. Only once the design is done: the line `Paste this into Claude
   Code:`, then the return alone, in the format above, in a fenced
   block of its own. Nothing after that block.
