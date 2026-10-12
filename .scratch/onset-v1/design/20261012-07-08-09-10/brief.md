Canvas: https://claude.ai/artifact/123TNq7nwcKGoXDaroSGcM. Written against docs/design-system.md version 1, 2026-10-12.

# Design brief: Onset, devices-first screens (tickets 07, 08, 09, 10)

Draw the boards on the canvas above. It is empty: every board you add is new.

## Context

Onset is real-time multiplayer Set in the browser. It used to be Jackbox-style: a shared big screen showed the cards and phones were only controllers. It is now devices-first: each player plays on their own **player screen** (a phone or a computer), and a shared **big screen** (a TV or laptop the table can see) is optional. These four tickets make the player screen stand alone and change how a game starts and how others are invited.

Users: friends at a table or on a call, each on their own phone or computer, mostly on phones. Glances, not reading: everything must read at arm's length.

Terms the screens show (from the glossary):

- **Player screen**: one player's own view of a game, on a phone or a computer, from which they call SET!, pick cards and vote. Never "phone", "controller" or "remote" in user-facing text
- **Big screen**: an optional shared display of a game. It is not a player. Never "board", "TV" or "host screen"
- **Room**: one game, identified by its six-character room code (letters A-Z and digits 2-9, no 0/O/1/I), from waiting through play to the end
- **Board**: the face-up cards in play, 12 to 18 of them
- **Set**: three cards whose four attributes are each all the same or all different
- **Claim**: a player's call of SET!, which gives them the sole right to pick three cards in 15 seconds
- **Lockout**: the five seconds after a wrong or timed-out claim during which that player cannot claim again
- **No Set call**: a 15-second countdown any player starts when they believe the board holds no Set; when every active player agrees, or it runs out, three more cards are dealt
- **Ready vote**: the vote every player casts to start a room, or to play again once it has ended
- **Standings**: every player in a room ranked by score, ties sharing a rank

The site address shown to players (`join_host`) is `onset.joaotorr.es`. Use realistic names such as Alex, Sam, Priya, Jonas, Mei, Tomás, Ada, Leo, and room code `K7QF3M`.

The screens below are already built for the old design; the code is the truth for everything this brief does not change. There are no boards of them yet, so nothing here is a redraw: draw each screen as this brief describes it.

## What to design

### 1. Landing `/` (ticket 08)

Widths: phone 375×667, desktop 1280×800 (split at Tailwind `md:`, 768px).

- Brand on the left: the **Onset** wordmark, a one-line tagline, three fanned cards that form a Set with a caption saying why
- Actions on the right: the Standard / First to 5 toggle above one **Start a game** button with its sub-line; then **Have a room code?** field plus **Join**
- States: default (Standard selected), First to 5 selected, "Room not found" after a bad code
- On phones the join form comes first

### 2. Join page `/games/:code/players/join` (ticket 08)

Width: portrait 375×667.

- States: a joiner (default); the creator (same page plus the **Use this screen as the big screen instead** link); a field error (name blank or taken, color taken); the base error (game already started) in a red box; every color taken (none selected)

### 3. Player screen, Waiting with the invite (ticket 10)

Widths: portrait 375×667, landscape 667×375, computer 1024×640.

- States: 1 player (just the creator); 8 players before voting; after voting ("Ready ✓ · waiting for n more"); the link button as **Copy link**, as **Copied ✓**, as **Couldn't copy**, and as **Share link** (touch screens); the **Show QR** sheet open

### 4. Player screen during play (ticket 09)

Widths: portrait 375×667, landscape 667×375, computer 1024×640. Draw each with 8 players and 18 cards (the worst case), and portrait also with 3 players and 12 cards.

- States, in every layout: idle; idle with the deck empty (End game vote); claiming (mine), with 1 card selected; someone else claiming; No Set countdown, before agreeing and after ("You agreed · waiting for n more"); locked out ("Wrong! −1" and "Time's up! −1"); the found-set banner over idle; cards just dealt with the green arrive outline
- The computer layout is new: its exact layout is yours to propose

### 5. Player screen, Game over with standings (ticket 07)

Widths: portrait 375×667, landscape 667×375, and computer 1024×640 (layouts are chosen by the viewport alone, so game over needs one there too).

- States: 8 players, the viewer 2nd, before voting; after voting; a tie for first ("Tied for first", ranks "1, 1, 3"); the viewer winning; a long name truncated

## Spec facts, per screen

Quoted from `SPEC.md`, with the heading each sits under.

### Shared

§1 Overview: "Each player plays on their own **player screen** (`/games/:code/controller`), on a phone or a computer, from which they call SET!, pick the three cards and vote. A **big screen** (`/games/:code`) is an optional shared display of the same room: the board, the scores and the announcements, for everyone at the table. Any room can open it at any time, before or during play; it is a URL, not a mode stored on the game, so every game is the same. Since the big screen is optional, the player screen is meant to stand alone"

§1 Overview: "This spec and every user-facing text say **player screen** and **big screen** (`GLOSSARY.md`), never "phone", "controller" or "TV" for the screens."

§4 Data Model, Player: "`name` | string | 1–20 chars, displayed"; "`color` | string | Hex code, chosen at join. UI offers 8 distinct presets."; "`(game_id, name)` unique-case-insensitive (no two players in the same game can share a name). `(game_id, color)` unique". So a room holds at most 8 players.

§2 Game Rules, Round flow: "The board shows 12 face-up cards drawn from the deck." "On resolution: deal 3 additional cards from the deck (board grows to 15, then 18 if called again). Hard cap at **18 cards**."

### 1. Landing

§8 Landing: "One page for phones and desktops, split at `md:`. Brand on the left: the **Onset** wordmark, a one-line tagline and three fanned cards that form a Set, with a caption saying why. The tagline says each player plays on their own screen and a big screen is optional, in the §1 terms. Actions on the right:

- A two-option toggle, **Standard** (selected by default) and **First to 5**, above one **Start a game** button with the sub-line "Play from this screen, then invite the others". Both sit in one form, with no JS: the toggle submits `mode` (`quick` for First to 5). Start a game creates the room in that mode, gives this browser the `host_game` cookie and opens the creator's join page (Join page below). Every room is the same: nothing about a big screen is stored on it.
- **Have a room code?** field plus **Join**. `GET /join?code=` upcases the code and redirects to the room's join page, or back with "Room not found".

On phones the join form comes first, since joining is what phones come here for."

§2 Round flow: "In quick mode the game ends when a player reaches 5 points (`Game::QUICK_WIN_SCORE`)."

Note for the toggle: with no JS, it is two radio inputs styled as a segmented control.

### 2. Join page

§8 Join page: "Portrait. "Joining room" with the code in large type, since the code is what people check. The creator sees the same page after **Start a game**. **Your name** (max 20). **Pick a color**: a 4×2 grid of swatches that select with a white ring and ✓, no JS. Taken colors are faded with the taker's initial. The first free color, in preset order, comes selected, so a player can join with a name alone. If the chosen color was taken between render and submit, the form comes back with the color error and the next free color after it selected (preset order, wrapping); any other re-render keeps the player's free choice. With every color taken, none is selected. The page does not update live as others join. **Join** sits at the bottom, under the thumb. In the browser that created the room (its `host_game` cookie matches), a **Use this screen as the big screen instead** text link sits under Join and opens the room's big screen `/games/:code` in the same tab; other browsers do not show it. Joining does not make the creator `host_player_id`: hosting stays with the browser, which gets the big screen's **Start game** and **Play again**, and on player screens everyone starts and plays again by the ready vote. Field errors show under their field; base errors (game already started) in a red box."

### 3 to 5. Player screen, all states

§8 Player screen: "Full height, no page scroll. A strip of the player's color across the top, "Room CODE" footer. The player screen stands alone (§1): in every playing state it shows the board, the scoreboard and the deck count, so a room needs no big screen. Waiting and game over keep a header with dot, name and score, since their bodies already list every player. Three layouts, chosen by the viewport alone, whatever the input:

- **Portrait** (narrower than tall, under 1024px wide): the scoreboard across the top, the board under it at the full width, then the state's panel, SET! and its pill at the bottom, under the thumb.
- **Landscape** (wider than tall, under 1024px wide): three columns, the board on the left, a 9rem action column, a scores column.
- **Computer** (1024px wide and up, Tailwind `lg:`): a board-sized card grid on the left and a side panel with the scoreboard and, beside it, the state's panel, SET! and its pill. The exact layout comes from the design pass."

§8 Player screen, "Shared by all three during play:

- **Scoreboard**: every player in score order, ties in join order, each a dot, the name (truncated) and the score. The claiming player's entry turns solid yellow and a locked-out player's is greyed with a red **Locked** tag, as on the big screen. The player's own entry has a surface tint, as in the game over standings. Portrait fits 8 players in at most two rows.
- **Deck**: "N cards left in the deck" with the board, or an orange "Deck is empty" pill once it runs out.
- **Board**: cards dealt by the last replace get the green outline that fades over 3s (§10 `animate-arrive`), in every state that shows the board. The board is read-only in every state but idle and claiming (mine).
- Other players' wrong claims and time's ups show only on the scoreboard (their Locked tag and score), with no banner.
- With 8 players and 18 cards there is no page scroll at 375×667 portrait, 667×375 landscape and 1024×640 computer, in every state: the cards shrink to fit.

SET! sits in the same fixed slot across idle, locked out, someone else claiming and the No Set countdown, so the thumb never has to move. The pill slot under it holds the state's secondary action: **No Set**, the **End game** vote or **I agree, no Set**."

§10 Component: "**Player screen, portrait**: in every playing state the grid fits the width (`auto-cols-fr`) and shrinks to the height left, so SET! and its pill never leave the screen." "**Player screen, landscape**: the grid fills the height and scrolls sideways." "**Player screen, computer**: 3 rows flowing into columns, sized to the height as on the big screen, no horizontal scroll at 18 cards."

### 3. Waiting with the invite

§8 Player screen, 1. Waiting: ""You're in", a two-column roster with "you" and ✓ marks, then **I'm ready** (the ready vote, §5 `POST /games/:code/ready`). Once voted: "Ready ✓ · waiting for n more".

Every player's waiting screen also carries the **invite**, so anyone in the room can bring in the next player; it goes once play starts, since late joining stays blocked, remote players included:
- The room code in large type, with "or open HOST and enter the code" (`join_host`), as on the big screen.
- **Copy link**: copies the join page URL (`/games/:code/players/join`, the URL the big screen QR encodes) and reads "Copied ✓" for 2s. Where the browser has the Web Share API and a touch screen (`pointer: coarse`), it reads **Share link** and opens the native share sheet with that URL and "Room CODE" instead. A cancelled share changes nothing; a failed copy reads "Couldn't copy" for 2s, the code and host staying on screen to share by hand.
- **Show QR**: opens a sheet over the player screen with the join URL's QR on a white tile, as large as fits up to 18rem, the room code under it and **Done** to close it. The QR stays behind this tap so the waiting screen fits without it. Any room update (someone joins or votes) re-renders `#controller_status` and closes the sheet; one tap reopens it.
- **Show on a big screen →**: a text link that opens the room's big screen `/games/:code` in a new tab, as **Join from this computer →** does, so the player screen stays open.

With 8 players and the invite there is no page scroll at 375×667 portrait, 667×375 landscape and 1024×640. The exact layout comes from the design pass."

§5 Routes: "POST | `/games/:code/ready` | A player votes to start; the game starts when every player (2+) has voted."

§8 Big screen, Waiting (for wording to match): "Beside the QR, "Scan to join, or open HOST and enter" and the room code"; "`#start_button`: **Start game** with "n of m ready" beside it, or disabled with "Need at least 2 players"."

### 4. During play

§8 Player screen:

"2. **Idle**: round blue **SET!** with a halo, a purple **No Set** pill under it. Deck empty: an orange **End game** vote with "Deck empty · n/m voted". Tapping a card on the board, in every layout, calls SET! and, once the claim is this player's, starts it with that card selected. Only the first tap counts until the screen changes. If someone else wins the race the tap does nothing, and it never selects a card in a later claim.
3. **Claiming (mine)**: a solid yellow bar with the countdown ring, "Your SET!", "Tap 3 cards" and an n/3 count. Portrait adds a tray of three slots that fill as cards are tapped. A claim started by tapping a card opens with that card selected (1/3) if it is still on the board. Tap a card to select, tap again to deselect, auto-submit per §11.
4. **Someone else claiming**: caller's dot and name, "is calling SET!", a yellow ring around the disabled SET! with the seconds inside. No Set disabled.
5. **No Set countdown**: a purple status panel (ring, "No Set called by Alex", n/m agreed in every layout) above the round blue **SET!**, which cancels the call, and a purple **I agree, no Set** pill under SET!. After agreeing, or for the caller, the pill slot shows "You agreed · waiting for n more". Locked out, SET! shows disabled.
6. **Locked out** (after a wrong claim or a timeout): the panel tints red and shakes once. "Wrong! −1" or "Time's up! −1". SET! becomes the 5-second countdown with "Locked".
7. **Found-set banner**: when anyone finds a Set, a banner across the top shows the cards, "Alex found a Set" and "+1", then fades. It ignores taps."

§11 Selection submission UX: "After the third tap on the player screen, **auto-submit with a 250ms delay** so a player can deselect a misclick before commit. The card grid dims to 50% during the delay. Each tap also copies the card into the portrait tray's next free slot and updates the n/3 count."

§2 Round flow: "The claiming player has **15 seconds** (`Game::CLAIM_TIMEOUT`) to tap 3 cards"; "**Wrong Set**: −1 point, claiming player is locked out for 5 seconds"; "**Timeout (no submission within 15s)**: same penalty as a wrong Set"; "A 15-second countdown begins, visible on the big screen and every player screen"; "If anyone calls **"SET!"** during the countdown, the No-Set call is **cancelled**"; "Once the deck is empty, players can also end early: every active player taps **"End game"**."

§2 Edge cases: "Wrong-claim lockout (5s) only prevents that player from calling SET; they can still observe and join No-Set votes."

### 5. Game over

§8 Player screen, 8. Game over: "the player's rank ("2nd"), "of N players · P points", the winner line ("★ Alex wins with 9" or "Tied for first"), the standings, then a green **Play again** button, the ready vote (§5 `POST /games/:code/ready`). Once voted: "Ready ✓ · waiting for n more", n being the active players who have not voted. The room restarts with the same mode, fresh deck and zero scores once every active player has voted, straight into play.

The standings list every player in the room, as many as "of N players" counts, one compact row each: rank, dot, name and score. Rows run by score, ties in join order, and tied players share a rank ("1, 1, 3"), as on the big screen podium. No ★, Locked tag or ready marks in the rows: the winner line carries the ★. Names truncate with an ellipsis. The player's own row is highlighted with a surface tint, not a color from the §10 meaning table, and says "you" after the name, as the waiting roster does. With 8 players, one per preset color, the screen keeps no page scroll at 375×667 portrait and 667×375 landscape. On a shorter screen the list scrolls inside itself, never the page."

## Design rules, quoted verbatim from docs/design-system.md v1

### Tokens

From `app/assets/tailwind/application.css` (`@theme`), on top of the Tailwind default palette:

| Token | Value | Use |
|---|---|---|
| `--font-display` | Bricolage Grotesque, ui-sans-serif, system-ui, sans-serif | Display text only |
| `--animate-shake` | `shake 0.4s ease-in-out 1`, ±8px | Locked-out phone panel |
| `--animate-arrive` | `arrive 3s ease-out forwards`, green-400 outline to transparent from 50% | Cards dealt by the last replace |
| `.found-set-flash` | `found-set-fade-out 3s`, opaque until 50% | Correct-claim panels |

Card palette (`app/views/cards/_card.html.erb`): blue `#648FFF`, orange `#FE6100`, magenta `#DC267F`.

Player colors (`PlayersController::PRESET_COLORS`): `#E74C3C #2ECC71 #F1C40F #9B59B6 #1ABC9C #E91E63 #00BCD4 #8BC34A`.

### Components

ERB partials, no component library.

- `cards/_card`: the card SVG, 200×280 viewBox, sized only by its 5:7 wrapper
- `games/_ring`: big screen countdown ring, size-24, seconds inside
- `games/_scoreboard`: big screen score rows, sorted by score
- `games/_start_button`: Start game with "n of m ready", or disabled with the reason
- `games/_announcement`: the 9rem announcement band and its tinted panels
- `players/controller/_header`: portrait header, dot, name, score
- `players/controller/_info_column`: landscape right column, dot, name, score
- `players/controller/_board_strip`: landscape read-only card grid
- `players/controller/_button_ring`: thin ring around the round SET! button, portrait
- `players/controller/_small_ring`: countdown ring with seconds, any size
- `players/controller/_secondary_action`: the pill under SET!, No Set, the End game vote, or during a No Set countdown I agree, no Set (filled purple) or the waiting text (outlined purple)
- Stimulus: `card-selection` (selection, tray, count, auto-submit), `countdown` (rings and seconds)

### Visual rules (quoted in the design system from SPEC §10)

#### Palette

Colorblind-safe (IBM 3-color palette):

- **Blue**: `#648FFF`
- **Orange**: `#FE6100`
- **Magenta**: `#DC267F`

Background: near-white (`#FAFAFA`). Card border: subtle, `#E5E5E5`. Selected card on phone: `ring-4 ring-blue-400 scale-95`.

#### Component

Single ERB partial: `app/views/cards/_card.html.erb` taking a `card:` local. Renders an SVG with a `viewBox` of `0 0 200 280`. Inside:

- Rounded rect background.
- Stack of `card.number + 1` shapes (1, 2, or 3) centered vertically.
- Each shape is one of:
  - **Oval**: ellipse.
  - **Squiggle**: a fixed `<path>` with the canonical Set squiggle curve (hardcoded).
  - **Diamond**: rotated square (rhombus path).
- Shading:
  - **Solid**: `fill=color`.
  - **Outline**: `fill=none stroke=color stroke-width=5`.
  - **Striped**: `fill="url(#stripes-#{color})"`, a 40° hatch of 3.5px lines on a 7px pitch. Each SVG defines its own `<pattern>`.

The SVG fills its wrapper; wrappers set the size with a 5:7 aspect ratio. The partial is never restyled, only sized.

- **Board grid**: 3 rows flowing into columns, centered, no horizontal scroll at 18 cards. Cards are `15rem` tall at 1080px and shrink with the viewport (`min(15rem, (100dvh - 22rem) / 3)`) so the third row never runs under the announcement band.
- **Phone, portrait claim**: the grid fits the width (`auto-cols-fr`), about 84px wide with 12 cards.
- **Phone, landscape**: the grid fills the height and scrolls sideways.

#### Visual system

Dark UI where the cards are the only bright surfaces. Tailwind default palette plus these tokens in `app/assets/tailwind/application.css`:

- `font-display`: Bricolage Grotesque (Google Fonts link in the layout). Only for display text: wordmark, room code, scores, SET!, headlines, countdown digits. Body copy stays on the default sans.
- `animate-shake`: once, 0.4s. Locked-out phone panel.
- `animate-arrive`: green outline that holds 1.5s and fades by 3s. Cards dealt by the last replace (`Game#last_dealt`).
- `.found-set-flash`: holds 1.5s, fades by 3s. Correct-claim panels on the board and the phone.

Surfaces: page `gray-950`, panels `gray-900`, borders `gray-700`/`gray-800`. Secondary text `gray-400`, muted `gray-500` (not `gray-600`, which fails contrast on `gray-950`).

Each color means one thing everywhere:

| Color | Meaning |
|---|---|
| blue-600 | SET! and primary actions |
| violet-600 | quick game |
| yellow-400 | a claim in progress (board panel, scoreboard row, phone claim bar) |
| purple | No Set. It used to be red; red now only means wrong or locked |
| red | wrong claim, timeout, lockout |
| green | ready, correct, start, play again |
| orange | deck empty and the End game vote (`orange-700` for white text; `orange-600` is only about 3.3:1) |

Player colors are the 8 presets in `PlayersController::PRESET_COLORS`, deliberately apart from the card palette. They show as dots, the phone's top border strip and podium bars.

Countdown rings: `r=45` in a 100 viewBox, gray track, colored progress with round caps, rotated -90° so they drain clockwise from the top. Seconds sit inside the ring, or inside the button the ring surrounds.

QR codes: dark modules on a white tile. Inverted codes fail on some phone cameras.

Note: the design system predates the devices-first terms. Where it says "phone" it means the player screen, and "board" in its meaning table means the big screen. The spec now also says a striped pattern's id is unique per rendered SVG; that does not change how a card looks.

## Boundaries

- Change no existing board unless this brief names it. The canvas starts empty, so this only matters for boards a later chat finds there.
- The big screen is out of scope: do not redesign it. Its wording is quoted above only so the player screen can match it.
- Behaviour is decided by the spec quotes above. Where your design would make a user notice something working differently (a new action, a different count, an element added or dropped), put it under "Decisions the spec does not cover" in the return, do not just draw it.
- Use only the tokens, colors and components above. A new token, component or state is fine when a screen needs it: list it in the return.
- Keyboard shortcuts on the computer layout are deferred: draw no key hints.

## Return format

At the end of the work, return exactly this, writing `None` under a heading with nothing in it. Begin the return with the `Design return` line, with no command such as `/request` or `/design-entry` before it, since a pasted command does not run.

```
Design return for tickets 07, 08, 09, 10.

## New tokens
## New components
## New or changed rules
## Decisions the spec does not cover
## Open questions
## Artboards added or changed
```

## How every reply ends

```
End every reply with:

1. **Pending decisions:** what you need from me before going on,
   numbered, each with your recommendation first. `None` when there
   are none.
2. Only once the design is done: the line `Paste this into Claude
   Code:`, then the return alone, in the format above, in a fenced
   block of its own. Nothing after that block.
```
