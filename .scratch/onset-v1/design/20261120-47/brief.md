Canvas: https://claude.ai/artifact/123TNq7nwcKGoXDaroSGcM. Written against docs/design-system.md v7, 2026-11-19.

# Design brief: ticket 47

## Context

Onset is a real-time multiplayer web version of the card game Set. Each player plays on their own player screen, a phone or a computer, and an optional big screen (a TV or laptop) shows the room to the whole table. Every page comes in two themes, Dark and Light, picked per browser in the settings menu.

This round is ticket 47, the AI opponent: the host can add bots to a waiting room, at Easy, Medium or Hard, so a room can play with fewer people, a single person included. The host sees an add-bot control on the big screen's waiting state and on their own player screen while waiting. Everyone sees bots wherever a player shows: rosters, pills, scoreboards, standings, the podium and the announcements, each with a bot mark beside the name. A bot only claims Sets; it never votes.

A later round (ticket 48, held for this one) adds a remove control on each bot's pill on the big screen and on its row in the host's player screen roster. Do not draw it now, but leave room for it: a small control at the end of a bot's pill and roster row should fit later without moving anything else.

Glossary terms these screens show or touch:

- **Bot**: A player Onset plays itself, added (and removed) by the host while the room is waiting, at Easy, Medium or Hard. It only claims Sets, after a delay its level sets, and never votes. _Avoid_: AI, computer, CPU
- **Player screen**: One player's own view of a game, on a phone or a computer, from which they call SET!, pick cards and vote. _Avoid_: Controller, phone, remote
- **Big screen**: An optional shared display of a game, such as a TV or laptop the whole table can see. It is not a player. _Avoid_: Board, TV, host screen
- **Room**: One game, identified by its six-character room code, from waiting through play to the end. _Avoid_: Lobby, session, match
- **Ready vote**: The vote every player casts to start a room, or to play again once it has ended.
- **Claim**: A player's call of SET!, which gives them the sole right to pick three cards and submit them before the claim window closes.
- **Standings**: Every player in a room ranked by score, ties sharing a rank. _Avoid_: Leaderboard, podium (the podium is the big screen's top three)
- **Board**: The face-up cards in play, 12 to 18 of them. _Avoid_: Table, grid

User-facing text says "bot", never "AI", "computer" or "CPU".

## What to design

New parts, each with its dark and light values:

1. **The add-bot control**, with its three levels Easy, Medium and Hard picked with each add, in its enabled and disabled (every color taken) states, its keyboard focus and its accessible name. It sits on the big screen's waiting state and on the host's own player screen while waiting, nowhere else. If your control has an open state (a level picker that opens), draw that state too, as one extra board, portrait light
2. **The bot mark**, beside a bot's name everywhere a player shows, at every size those places use: big screen pills, rail scoreboard rows, the announcement band and the podium; player screen roster, scoreboard chips (portrait) and rows (landscape, computer), the status panel, the found-set banner, the winner line and the standings. Give it an accessible text, so a screen reader hears that the player is a bot
3. **Start game's new disabled reason**, "Need a person to play", in the existing disabled `_start_button`

Boards, ten (eleven with the open state). Each new element appears in both themes across them; draw each board in the one theme named, since a light screen changes colors only (design rules below). Add a canvas title note "11 · Bots · add-bot control and bot mark (ticket 47)" above the row, below the error pages' row.

| # | Board | Screen | Size | Theme | State |
|---|---|---|---|---|---|
| 1 | `bot-big-waiting8-light` | Big screen, waiting | 1280×800 | Light | 8 players: Ana (host), Ben, Chloé, Dev, Eli and Easy bot, Easy bot 2, Hard bot. "6 of 8 ready" (the three bots and Ana, Ben, Chloé ready). Start game enabled. Add-bot control disabled: every color taken. The narrowest big screen the spec allows, with 8 pills and the control |
| 2 | `bot-big-botsonly-dark` | Big screen, waiting | 1920×1080 | Dark | The host has added two bots, Easy bot and Medium bot, before anyone joined. Start game disabled, "Need a person to play". Add-bot control enabled |
| 3 | `bot-waiting-p-alone-light` | Player screen, Waiting, portrait, host | 375×667 | Light | The host alone: "Waiting for more players to join…" in place of I'm ready, the add-bot control enabled. The one-person room that a bot unblocks |
| 4 | `bot-waiting-p8-dark` | Player screen, Waiting, portrait, host | 375×667 | Dark | 8 players, 3 of them bots, the host has voted: "Ready ✓ · waiting for 2 more" (people only). Add-bot control disabled. No page scroll |
| 5 | `bot-waiting-l7-dark` | Player screen, Waiting, landscape, host | 667×375 | Dark | 7 players, 2 of them bots, before voting: I'm ready. Add-bot control enabled. No page scroll (the two-column roster is 4 rows at 7 as at 8) |
| 6 | `bot-waiting-c7-light` | Player screen, Waiting, computer, host | 1024×640 | Light | As board 5. No page scroll |
| 7 | `bot-play-p8-other-dark` | Player screen, play, portrait 8/18 | 375×667 | Dark | Someone else claiming: Hard bot is calling SET!, its chip solid yellow; the status panel shows its dot, name and bot mark; the other bots' chips carry the mark |
| 8 | `bot-big-claiming-light` | Big screen, playing | 1920×1080 | Light | Claiming band: ring, "Hard bot is calling SET!" with the bot mark; Hard bot's rail row solid yellow; the other bots' rows carry the mark |
| 9 | `bot-gameover-p-light` | Player screen, Game over, portrait | 375×667 | Light | The viewer is 2nd; winner line "★ Hard bot wins with 9"; 8 standings rows, 3 bots among them; Play again |
| 10 | `bot-big-ended-dark` | Big screen, ended | 1920×1080 | Dark | "Game over", "Hard bot wins"; podium with Hard bot first and a person and Easy bot below; Play again |

What the boards leave to the code, from the rules below: a non-host player screen while waiting shows the bots in its roster with their mark and ✓, and no add-bot control; the landscape and computer play scoreboards, the found-set banner ("Easy bot found a Set") and the big screen's Correct band take the mark as boards 7 and 8 show it. Say in the return how the mark sits in each of those.

Every state the spec gives these screens:

- **Default**: boards 1, 5, 6 (control enabled with players), 7 to 10
- **Empty**: board 2 (no person yet), board 3 (host alone)
- **Loading**: none. Every action answers 204 and the broadcast updates every screen (spec below), so a tap shows no pending state; the bot simply appears
- **Errors**: the control disabled when every color is taken (boards 1 and 4); Start game disabled with "Need a person to play" (board 2). A refused request (403 from a browser that is not the host, 429 over the rate limit, an add ignored because no color is free) shows nothing on the screen
- **Success**: the bot appears in every roster, pill and count at once, ready (✓), boards 1, 4, 5, 6

No Favicon board: the design system has no `## Favicon` section, so the app has its own.

## Spec facts, per screen

### Everything about bots

From **AI opponent** (intro): "A **bot** is a player Onset plays itself (`GLOSSARY.md`), so a room can play with fewer people, a single person included. The host adds bots while the room is waiting, and each plays by the same claim rules as a person: first to reach the server wins (§6). User-facing text says "bot"."

From **AI opponent > Adding a bot**:

- "**Who**: the host, the browser holding the room's `host_game` cookie, from the big screen's waiting state and from the host's own player screen while waiting (§8). `POST /games/:code/bots` (§5) checks the cookie, as Start game does"
- "**When**: only while the room is waiting; once play starts the control goes, as late joining is blocked. Bots stay in the room for Play again, their scores reset with everyone's"
- "**Levels**: **Easy**, **Medium** and **Hard**, picked with each add. A room may hold several bots, of any levels, up to its eight colors. With every color taken the control is disabled, as Join is on a full room"
- "**Name and color**: "Easy bot", "Medium bot", "Hard bot"; a second bot at the same level is "Easy bot 2", and so on, so names stay unique (§4). A new bot takes the lowest free name of its level, so after a removal (Removing a bot) "Easy bot" is used again before "Easy bot 3". The first free color in preset order, as the join page selects one"
- "**Ready at once**: a bot counts as voted in the ready vote from the moment it joins, so its ✓ shows at once. A room starts with at least 2 players, bots included, and at least one person: the ready vote starts it when every person has voted, and the big screen's Start game is disabled while every player is a bot, since nobody could call No Set or vote to end"
- "**Shown everywhere a player is**: the waiting roster and pills, both scoreboards, the standings, the podium and the announcements ("Easy bot is calling SET!", "Easy bot found a Set", "Easy bot wins"), with a bot mark beside the name. The control's look, where it sits on each screen and the bot mark come from the design pass"
- "**Telemetry**: the tap sends `bot_added` (§17)"

From **AI opponent > How a bot plays**:

- Delays per level: "Easy 30 to 50 s", "Medium 15 to 30 s", "Hard 6 to 15 s"
- "**Its claim** shows on every screen as a person's, with the ring. After 2 seconds it submits its three cards, judged as any Submit (§11), so a bot never makes a wrong claim and is never locked out"
- "**It never votes** (§2 Edge cases): no No Set call, agreement or refusal, no End game or Play again vote."

From **Shared: 2. Game Rules > Edge cases**: "A bot (AI opponent) plays only by claiming. It never calls No Set, agrees, refuses or votes to end or play again, and it is never active, so every vote above that counts active players counts people only. The ready vote to start counts it as voted."

From **Shared: 4. Data Model > `Player`**: "`name` | string | 1–20 chars, displayed"; "`color` | string | Hex code, chosen at join: one of the 8 presets (`Player::PRESET_COLORS`), so a room holds at most 8 players." And under The 8-player cap: "Eight presets, each unique in a room, cap a room at 8 players, people and bots alike (AI opponent)." "A bot add that loses either race is ignored, still `204`, as an add with no color free (§5)."

From **Shared: 4. Data Model > `Game`**, `host_player_id`: "the player who joined from the host browser, set at join. The host is the browser that created the room, marked by its `host_game` cookie (§8 Landing), not a player: this column only tells which player screen shows the bot control (AI opponent), and every host action still checks the cookie"

From **Shared: 5. Routes**:

- "| POST | `/games/:code/bots` | The host (the browser holding `host_game`, `403` otherwise) adds a bot at `level` `easy`, `medium` or `hard` (AI opponent). Ignored, still `204`, unless the room is waiting, the level is one of the three and a color is free |"
- "| POST | `/games/:code/start` | The host (the browser holding `host_game`, `403` otherwise) starts the game from the big screen. Ignored, still `204`, unless the room is waiting and holds 2 or more players, at least one a person (AI opponent) ... |"
- "| POST | `/games/:code/ready` | A player votes to start; the game starts when every player (2+, at least one a person) has voted, a bot counting as voted (AI opponent). ... |"
- Rate limits: "**The host's bot controls** (ticket 62): adding and removing a bot in the waiting room (`POST /bots`, `DELETE /bots/:id`), one count across the two, 30 a minute, keyed as Start game and Play again are, by the room the `host_game` cookie names and by IP without it, but a count of its own ... A refused add adds no bot and a refused removal leaves the bot in the room." And: "A refused in-game action shows nothing on the screen: the `429` has no body, so the screen stays as it was until the next broadcast"

From **Shared: 7. Realtime > Actions answer 204, broadcasts update the screen**: "Every POST from a player screen or the big screen (SET!, a card pick, Submit, No Set, agree, End game, ready, Start game, Play again) answers `204 No Content`. Turbo leaves the page alone, and the broadcast the action triggers updates every screen, including the one that acted."

From **Shared: 8. Settings menu**, Opening it: "It never moves SET!, the pill slot or the board, and it keeps the player screen's and the big screen's no-page-scroll rules"

### Big screen (boards 1, 2, 8, 10)

From **8. Big screen (`/games/:code`)**:

- "Full screen, built for a TV at 2m, and must also fit a laptop down to 1280px wide. Two columns: the play area (`#board` over `#announcement`) and a 26rem right rail with the room tile (room code and the site address to open, `join_host`, no QR) and the **Players** scoreboard. The room tile is hidden while waiting, since the join hero carries the code, and appears once the game starts without a reload."
- "**Scoreboard**: rows sorted by score, dot, name, big score. The claiming player's row turns solid yellow. A locked-out player is greyed with a red **Locked** tag."
- "**Waiting**: a join hero with a 288px QR and, under it, a **Join from this computer →** link that opens the join page in a new tab, for someone playing on the same computer as the big screen. ... Beside the QR, "Scan to join, or open HOST and enter" and the room code at up to 10rem, shrinking with the viewport so it never runs past the play area into the rail. The hero's text wraps or shrinks the same way. Player pills with a ✓ once ready, bots included with their bot mark (AI opponent). `#start_button`: **Start game** with "n of m ready" beside it, or disabled with "Need at least 2 players", or with "Need a person to play" when every player is a bot. The **add-bot control** (AI opponent) sits in the waiting state, and each bot's pill carries a **remove control** (AI opponent, Removing a bot), both shown on every big screen and accepted from the host only, as Start game is."
- "**Announcement band**: always 9rem tall so the grid never jumps. ... Claiming (yellow): countdown ring, "Alex is calling SET!"."
- "**Ended**: "Game over", then "Alex wins" or "It's a tie". Podium in 2-1-3 order; bars carry the real rank, so a tie reads #1 #1, and only a sole winner gets the ★. **Play again**, which restarts the room at once whatever the player screens have voted."

The remove control in that Waiting paragraph is ticket 48's, for the next round: do not draw it.

### Player screen, Waiting (boards 3 to 6)

From **8. Player screen (`/games/:code/controller`)**: "Full height, no page scroll. A strip of the player's color across the top, "Room CODE" footer. ... Waiting and game over keep a header with dot, name and score, since their bodies already list every player." Layouts: "**Portrait** (narrower than tall, under 1024px wide)", "**Landscape** (wider than tall, under 1024px wide)", "**Computer** (1024px wide and up, Tailwind `lg:`)".

From **8. Player screen**, state 1, **Waiting**:

- ""You're in", a two-column roster with "you" and ✓ marks, then **I'm ready** (the ready vote, §5 `POST /games/:code/ready`). Once voted: "Ready ✓ · waiting for n more", n counting people only, since a bot is always ready. Alone in the room, a player cannot vote: "Waiting for more players to join…" takes the place of I'm ready, so the voted line never reads "waiting for 0 more". A bot in the room counts as a player here, so a person with a bot can vote and play (AI opponent). Bots sit in the roster with their bot mark and ✓."
- "On the host's own player screen (the player who joined from the host browser, §4 `host_player_id`) the waiting screen also carries the **add-bot control** (AI opponent), and each bot in the roster a **remove control** (AI opponent, Removing a bot). Other player screens show the bots, not the controls."
- "Every player's waiting screen also carries the **invite** ...: The room code in large type, with "or open HOST and enter the code" (`join_host`), as on the big screen. **Copy link** ... **Show QR** ... **Show on a big screen →**"
- "With 8 players and the invite, and on the host's screen the add-bot control and the remove controls, there is no page scroll at 375×667 portrait, 667×375 landscape and 1024×640. The exact layout comes from the design pass."

The remove controls are ticket 48's: leave room for them, do not draw them.

### Player screen, play (board 7)

From **8. Player screen**, Shared by all three during play: "**Scoreboard**: every player in score order, ties in join order, each a dot, the name (truncated) and the score. The claiming player's entry turns solid yellow and a locked-out player's is greyed with a red **Locked** tag, as on the big screen. The player's own entry has a surface tint, as in the game over standings. Portrait fits 8 players in at most two rows." And: "With 8 players and 18 cards there is no page scroll at 375×667 portrait, 667×375 landscape and 1024×640 computer, in every state: the cards shrink to fit."

State 4, "**Someone else claiming**: caller's dot and name, "is calling SET!", a yellow ring around the disabled SET! with the seconds inside. No Set disabled."

State 7, "**Found-set banner**: when anyone finds a Set, a banner across the top shows the cards, "Alex found a Set" and "+1", then fades. It ignores taps."

### Player screen, Game over (board 9)

From **8. Player screen**, state 8, **Game over**: "the player's rank ("2nd"), "of N players · P points", the winner line ("★ Alex wins with 9", "★ You win with 9" when the player is the sole winner, or "★ Tied for first at 9"), the standings, then a green **Play again** button, the ready vote ... Once voted: "Ready ✓ · waiting for n more", n being the active players who have not voted."

"The standings list every player in the room, as many as "of N players" counts, one compact row each: rank, dot, name and score. Rows run by score, ties in join order, and tied players share a rank ("1, 1, 3"), as on the big screen podium. No ★, Locked tag or ready marks in the rows: the winner line carries the ★. Names truncate with an ellipsis. The player's own row is highlighted with a surface tint, not a color from the §10 meaning table, and says "you" after the name, as the waiting roster does. ... With 8 players, one per preset color, the screen keeps no page scroll at 375×667 portrait, 667×375 landscape and 1024×640 computer."

## Design rules, quoted verbatim from docs/design-system.md v7

### Shared: Tokens (excerpt)

"| `--font-display` | Bricolage Grotesque, ui-sans-serif, system-ui, sans-serif | Display text only |"

"| `muted` (v7, dark only) | `#7C8390`, on the gray hue a third of the way from `gray-500` to `gray-400`, outside the Tailwind palette | Dark muted text and dark form placeholders (Shared: Themes (v6), Text). Light muted stays `gray-500` |"

"Player colors (`PlayersController::PRESET_COLORS`): `#E74C3C #2ECC71 #F1C40F #9B59B6 #1ABC9C #E91E63 #00BCD4 #8BC34A`."

"v2 adds no tokens: every new color is from the Tailwind default palette. v7 adds `muted`, the one color outside it."

### Shared: Themes (v6) (excerpt)

"Two themes, Dark and Light, each color one CSS value per theme keyed on `<html>`, on the same markup. Dark is every value this file gave before v6, but for the three dark rows v7 raises to contrast (ticket 46): muted text, placeholders and the field border at rest. Ratios are WCAG contrast on the value's own ground: the light page (`gray-50` `#F9FAFB`) unless stated; dark ratios, where given, on `gray-950` `#030712` unless stated. Every value is from the Tailwind default palette but dark `muted` `#7C8390` (Shared: Tokens). The light theme sheet on the canvas (`LightSheet`) shows each pair; the dark contrast sheet (`DarkSheet`) shows the v7 dark values on each ground they sit on, beside light."

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

"Meaning colors as fills with white text are the same in both themes: `blue-600`, `violet-600`, `purple-700`, `red-600`, `green-700`, `orange-700`. So is the claim fill, `yellow-400` with `gray-950` text."

Meaning colors as tinted panels (excerpt)

| Panel | Dark | Light |
|---|---|---|
| Someone else claiming | `gray-900`, 2px `yellow-400` | white, 2px `yellow-500` |
| Found-set banner | `green-950`, `green-500`, +1 `green-400` | `green-50`, `green-600`, +1 `green-700` |
| Ready ✓ waiting | `green-700` at 12%, `green-700` border, `green-300` text | `green-50`, `green-700` border, `green-800` text |
| Band, Claiming | `yellow-400` 10%, 2px `yellow-400` ring, name and seconds `yellow-400` | `yellow-50`, `yellow-500` ring, name and seconds `yellow-800` |
| Band, Correct | `green-500` 10%, `green-500` ring, `green-400` | `green-50`, `green-600` ring, `green-700` |

Meaning colors as text (excerpt)

| Role | Dark | Light | Light ratio |
|---|---|---|---|
| Green (✓, all the same, Right: +1) | `green-400` | `green-700` | 4.80:1 |
| Podium ★ | `yellow-400` | `yellow-700` | 4.70:1 |

Disabled, rings, outlines and the rest (excerpt)

| Role | Dark | Light |
|---|---|---|
| Disabled filled pill (v5 rule) | `purple-700` 35% + `purple-200`; `blue-600` 35% + `blue-200` | `purple-100` + `purple-700` (5.92:1); `blue-100` + `blue-700` (5.49:1) |
| Disabled gray button (Start game with 1 player, Join when full) | `gray-800` + `gray-500` (not `muted`: disabled labels are exempt, v7) | `gray-200` + `gray-600` (6.10:1) |
| Countdown progress | `yellow-400`, `red-500`, `purple-400` | `yellow-600` (2.81:1, the seconds inside carry the count), `red-600`, `purple-600` |
| Countdown track | `gray-800` (player screen), `gray-700` (big screen) | `gray-300` |
| Focus outline, 2px, offset 2px | `blue-500` | `blue-500` (3.52:1, 3.68:1 on white) |
| Segmented control, selected (landing mode toggle Standard, settings menu) | `gray-700` + white | `gray-800` + white (14.68:1) |
| Segmented control, unselected text | `gray-400` | `gray-600` |
| Segmented track | `gray-950` on a panel, `gray-900` on the page | `gray-100` on a panel, white on the page |
| Shadows | cards `rgba(0, 0, 0, 0.55)`; banner and menu `rgba(0, 0, 0, 0.6)` | cards `rgba(3, 7, 18, 0.16)`; banner 0.12; menu 0.18 |

### Shared: Rules added in v2 (excerpt)

- "White text on green uses `green-700` (`#15803D`); `green-600` is about 3.3:1, as with `orange-700`. I'm ready and Play again on the player screen"
- "Player screen card size, in every layout: `cw = floor(min((boardW - (cols - 1) * gap) / cols, ((boardH - 2 * gap) / 3) * 5 / 7))`, `cols = cards / 3`, gap 5px on phones and 12px on computer. At 8 players and 18 cards: portrait 54×76, landscape 55×77, computer 106×148. Portrait at 3 players and 12 cards: 71×99. Landscape shrinks the cards to fit the width, with no sideways scroll; at 12 cards they fill the height"
- "SET! slot 128×128 in every layout, the button 104px (108px on computer). Ring states put a 128px ring around a 100px disabled `gray-800` button"
- "Portrait keeps the status slot at 64px in every state, so the board never resizes on a state change"
- "Copy link feedback stays neutral gray: green and red are reserved by the meaning table"

### Shared: Rules added in v5

- "A disabled filled pill keeps its label legible: the fill at 35% with the light tint of its color as text at full opacity (blocked No Set: `purple-700` at 35%, `purple-200`; disabled Submit: `blue-600` at 35%, `blue-200`), never the whole button faded"

### Shared: Rules added in v6 (excerpt)

- "Two themes, Dark and Light. A light screen changes colors only, plus the card wrapper's edge: every element, size and position is the dark screen's. Values in Shared: Themes (v6)"
- "A panel with no border (big screen room tile and player pills, How to play panels, the QR tile) gets a 1px `gray-200` inset edge in light, as a `box-shadow`, so nothing resizes. Panels that already have a border keep it, recoloured"
- "Light tinted panels use the 50 tint of their color, a 600 border or ring (yellow: 500) and text in 700 or 800. Meaning fills with white text are the same in both themes"
- "Light muted text (`gray-500`) sits only on the page or on white in light, never on `gray-100`. Dark muted: Shared: Rules added in v7"
- "The v5 disabled-pill rule in light: the 100 tint of the color as fill, its 700 as text, at full opacity"
- "Card wrapper edge, light only: on the card's wrapper, never inside `_card`, wherever a card sits on a light surface (board, tray, found-set banner, band, landing fan, How to play)"
- "The settings button never moves SET!, the pill slot or the board, and adds no page scroll. On the player screen it lives in the "Room CODE" footer row"

### Shared: Rules added in v7

- "Dark muted text and dark placeholders are `muted` `#7C8390`, never `gray-500`. Dark muted sits only on `gray-950`, `gray-900` (the placeholders in their fields) or the No Set band, never on `gray-800` (3.85:1)"
- "The player screen settings button icon follows muted in both themes (dark `#7C8390`, 5.28:1; its bar is 3:1 as a graphic), so the "Room CODE" footer row stays one shade"
- "The two form fields' border at rest is `gray-500` in both themes. Their error border is unchanged (`red-500` dark, `red-600` light)"
- "Stays as built: disabled controls keep `gray-800` with `gray-500` text, and every `gray-700` border that is not a form field stays `gray-700` (the mode toggle's track, the Join, Copy link and Show QR buttons, the settings menu, the QR sheet, the empty tray slot's dashed border)"
- "Built dark boards still draw muted `gray-500` and the `gray-700` field border; this file and `DarkSheet` win. The code is the truth for each built screen's layout"

### Shared: Visual rules, SPEC §10 Visual system (excerpt)

- "`font-display`: Bricolage Grotesque (Google Fonts link in the layout). Only for display text: wordmark, room code, scores, SET!, headlines, countdown digits. Body copy stays on the default sans."
- "**Text** at least 4.5:1 on its ground, the page or the panel it sits on, whatever its size: body, secondary and muted text alike ... The labels of disabled controls are exempt, as WCAG makes them, and keep the disabled looks `docs/design-system.md` gives"

"Each color means one thing everywhere:

| Color | Meaning |
|---|---|
| blue-600 | SET! and primary actions |
| violet-600 | quick game |
| yellow-400 | a claim in progress (big screen panel, scoreboard entries, player screen claim bar) |
| purple | No Set. It used to be red; red now only means wrong or locked |
| red | wrong claim, timeout, lockout |
| green | ready, correct, start, play again (`green-700` for white text; `green-600` is only about 3.3:1) |
| orange | deck empty and the End game vote (`orange-700` for white text; `orange-600` is only about 3.3:1) |"

"Player colors are the 8 presets in `PlayersController::PRESET_COLORS`, deliberately apart from both card palettes (Palette above). They show as dots, the player screen's top border strip and podium bars."

"Countdown rings: `r=45` in a 100 viewBox, gray track, colored progress with round caps, rotated -90° so they drain clockwise from the top. Seconds sit inside the ring, or inside the button the ring surrounds."

### Components (excerpt)

- "`games/_ring`: big screen countdown ring, size-24, seconds inside"
- "`games/_scoreboard`: big screen score rows, sorted by score"
- "`games/_start_button`: Start game with "n of m ready", or disabled with the reason"
- "`games/_announcement`: the 9rem announcement band and its tinted panels. ..."
- "`players/controller/_header`: header with dot, name and score, on Waiting and Game over"
- "`players/controller/_scoreboard` (v2): the play scoreboard, every player in score order. Portrait: chips, 4 per row, at most 2 rows, the Locked tag a red badge on the chip's top-right corner. Landscape and computer: one row per player, the Locked tag inline before the score. Own entry `gray-800` with a `gray-500` border; claiming entry solid `yellow-400` with `gray-950` text; locked entry content at 45% opacity"
- "`players/controller/_status_panel` (v2): one fixed slot above SET!, portrait 64px tall, landscape 144×104, computer 248×76. Variants: ... someone else claiming: `gray-900` with a `yellow-400` border, "Alex is calling SET!""
- "`players/controller/_found_banner` (v2): `green-950` panel with a `green-500` border, the 3 cards small, the caller's dot, "Alex found a Set" and "+1" in `green-400`. Absolutely positioned over the top of the board area, over the scoreboard in portrait. `pointer-events: none`, `.found-set-flash`"
- "`players/controller/_roster` (v2): the Waiting roster, two columns, each a dot, the name, "you" for the player and a `green-400` ✓ once ready"
- "`players/controller/_invite` (v2): the room code in display type, "or open onset.joaotorr.es and enter the code" (`join_host`), the link button (Copy link, Copied ✓, Couldn't copy, Share link), a Show QR button and the "Show on a big screen →" text link"
- "`players/controller/_standings` (v2): game over rows, each rank, dot, truncated name, "you" for the player, score. Own row `gray-800` with a `gray-600` border, other rows transparent. Rows 32px portrait, 34px landscape, 44px computer (computer list in a `gray-900` panel)"
- "Landing mode toggle (v2): two radios styled as a segmented control inside the Start a game form, on a `gray-950` (desktop) or `gray-900` (phone) track with a `gray-700` border. Selected Standard `gray-700`, selected First to 5 `violet-600`, unselected `gray-400` text on transparent. Light (v6): the segmented control rows of Shared: Themes (v6); First to 5 stays `violet-600`"
- Settings button: "Player screen: 40×28 (40×32 in the computer Waiting and Game over footers), radius 8, no border, 16px icon (18px on computer), icon in muted text. It sits in the "Room CODE" footer row, outside `#controller_status`, at the row's right end, and adds no height". "Big screen: 56×56"

### Screens (excerpt)

"Drawn for v2. Sizes are the boards': portrait 375×667, landscape 667×375, computer 1024×640, landing desktop 1280×800. v6 adds a light board of each screen beside the dark ones, Classic cards unless the board says Color-blind, and the settings button on every screen; the page boards with the byline footer are 375×727 and 1280×860."

Settings button placement:

- "Player screen, portrait: in the "Room CODE" footer, 8px from the right edge, in every state; the menu opens 8px from the right and 46px from the bottom"
- "Player screen, landscape: play, on the Room line at the foot of the scores column (that line becomes a 28px row); Waiting, on the Room line under the invite; Game over, on the Room line under Play again"
- "Player screen, computer: ... Waiting and Game over: 40px from the right of the 32px footer; the menu opens 40px from the right and 48px from the bottom"
- "Big screen: 56×56, bottom-right, 40px in from both edges, under the rail; the menu opens 40px from the right and 108px from the bottom"

Big screen (tickets 21, 40):

- "Drawn in light for every state (`l-big-*`, `BigScreenTh`), and in dark for waiting and ended (`d-big-waiting4`, `d-big-waiting1`, `d-big-ended`), which had no dark board before v6"
- "The room tile, the player pills and the QR tile get the light inset edge; band panels follow the light tinted panel rows; the podium ★ is `yellow-700` in light"

Player screen, Waiting (ticket 10):

- "Header, then "You're in", the roster, the invite and I'm ready (`green-700`). Once voted: "Ready ✓ · waiting for n more" as outlined `green-700` text on a 12% `green-700` tint, `green-300` text"
- "Landscape and computer put the roster and the invite side by side"
- "The link button's feedback states (Copied ✓, Couldn't copy) stay neutral gray"
- "The QR sheet is `_qr_sheet`; the "Room CODE" footer stays"

Player screen, during play (ticket 09):

- "Portrait, top to bottom: the scoreboard, the board at full width, the status slot (64px, empty in idle), the 128×128 SET! slot and its pill"
- "Someone else claiming: the disabled SET! shows the seconds large with a small "SET!" label under them, inside the yellow ring"
- "Read-only boards (someone else claiming, No Set, locked out) are not dimmed"

Player screen, Game over (ticket 07):

- "Header, the rank in display type (64px portrait, 60px landscape, 120px computer), "of N players · P points" in `gray-400`, the winner line, the standings, Play again (`green-700`) or "Ready ✓ · waiting for n more" as on Waiting"
- "The standings scroll inside themselves when they do not fit; the page never does"

Open question still open: "A 20-character name at 1280px wide pushes a big screen headline (No Set, claiming) to three lines and out of the 9rem band. ... the No Set and claiming headlines wait for a request of their own". Bot names are at most 12 characters ("Medium bot 2"), so they do not meet it.

### Changed since the boards

None: the canvas was last handed off at v7, the version this brief is written against. Note the v7 rule above, though: built dark boards still draw muted `gray-500`; every new dark board here uses `muted` `#7C8390`.

## Boundaries

- Change no existing board. Add the ten (or eleven) boards above in a new row, below the error pages' row, with the title note
- Build each new board from the themed components already on the canvas (WaitingTh, PlayPortraitTh, GameOverTh, BigScreenTh) where they fit. You may add props to them for bots and the host's control, but each new prop must default to today's look, so every board that imports them now renders unchanged
- These screens are built. The existing boards were left as drawn: what shipped since them (the v6 light builds and ticket 46's dark contrast) does not touch the roster, pills, Start game, scoreboards or announcements this brief extends, and the code is the truth for every part of these screens the brief does not touch
- No remove control (ticket 48, next round), no other screen, no change to any behaviour the spec quotes above. A choice the spec does not cover goes under "Decisions the spec does not cover" in the return, not into the boards as fact

## The return

At the end of the work, write the return in exactly this format:

```
Design return for tickets 47.

## New tokens
## New components
## New or changed rules
## Decisions the spec does not cover
## Open questions
## Artboards added or changed
```

Write `None` under a heading with nothing in it. Begin the return with the `Design return` line: no command such as `/request` or `/design-entry`, since a pasted command does not run. Give every new color as a Tailwind default name with its dark and light value and its contrast on the ground it sits on. Under New components, give the add-bot control's and the bot mark's sizes in each place they sit, their states and their accessible names, and how the mark sits in the places no board draws (named under What to design).

## How every reply ends

End every reply with:

1. **Pending decisions:** what you need from me before going on, each
   a bullet with a bold title, explained so I can decide without opening
   anything else, its options numbered with your recommendation first.
   The numbers run on through all the decisions, never restarting, so I
   can answer with numbers alone ("1, 4"). `None` when there are none.
2. Only once the design is done: the line `Paste this into Claude
   Code:`, then the return alone, in the format above, in a fenced
   block of its own. Nothing after that block.
