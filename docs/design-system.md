# Onset design system, version 3

The tokens, components and visual rules the views use, and the devices-first screens drawn for tickets 07, 08, 09 and 10. Kind: visual tickets wait for an entry under `## Changelog` that covers them (loop-rules gate 2).

Boards for every screen and state are on the canvas named in `docs/design-handoff.md`. Where this file and a board differ, this file wins; tell the design tool in the next brief.

## Tokens

From `app/assets/tailwind/application.css` (`@theme`), on top of the Tailwind default palette:

| Token | Value | Use |
|---|---|---|
| `--font-display` | Bricolage Grotesque, ui-sans-serif, system-ui, sans-serif | Display text only |
| `--animate-shake` | `shake 0.4s ease-in-out 1`, ±8px | Locked-out player screen panel |
| `--animate-arrive` | `arrive 3s ease-out forwards`, green-400 outline to transparent from 50% | Cards dealt by the last replace |
| `.found-set-flash` | `found-set-fade-out 3s`, opaque until 50% | Correct-claim panels and the found-set banner |

Card palette (`app/views/cards/_card.html.erb`): blue `#648FFF`, orange `#FE6100`, magenta `#DC267F`.

Player colors (`PlayersController::PRESET_COLORS`): `#E74C3C #2ECC71 #F1C40F #9B59B6 #1ABC9C #E91E63 #00BCD4 #8BC34A`.

Byline logo colours (v3, `--wm-*`): light on `:root` green `#009C3B`, blue `#002776`, red `#C60B1E`, gold `#E08A00`; dark on `.byline-footer`, the values every Onset screen uses: green `#22C35E`, blue `#5B8CFF`, red `#FF4F5E`, gold `#FFD21F`.

v2 adds no tokens: every new color is from the Tailwind default palette.

## Components

ERB partials, no component library.

- `cards/_card`: the card SVG, 200×280 viewBox, sized only by its 5:7 wrapper
- `games/_ring`: big screen countdown ring, size-24, seconds inside
- `games/_scoreboard`: big screen score rows, sorted by score
- `games/_start_button`: Start game with "n of m ready", or disabled with the reason
- `games/_announcement`: the 9rem announcement band and its tinted panels
- `players/controller/_header`: header with dot, name and score, on Waiting and Game over
- `players/controller/_board_strip`: the play card grid with the deck line, sized by the card size rule in portrait and landscape
- `players/controller/_button_ring`: thin ring around the round SET! button
- `players/controller/_small_ring`: countdown ring with seconds, any size
- `players/controller/_secondary_action`: the pill under SET!: No Set, the End game vote, or during a No Set countdown I agree, no Set (filled purple) or the waiting text (outlined purple)
- `players/controller/_scoreboard` (v2): the play scoreboard, every player in score order. Portrait: chips, 4 per row, at most 2 rows, the Locked tag a red badge on the chip's top-right corner. Landscape and computer: one row per player, the Locked tag inline before the score. Own entry `gray-800` with a `gray-500` border; claiming entry solid `yellow-400` with `gray-950` text; locked entry content at 45% opacity
- `players/controller/_status_panel` (v2): one fixed slot above SET!, portrait 64px tall, landscape 144×104, computer 248×76. Variants:
  - claim bar: `yellow-400`, ring, "Your SET!", "Tap 3 cards", n/3
  - someone else claiming: `gray-900` with a `yellow-400` border, "Alex is calling SET!"
  - No Set: `purple-950` with a `purple-500` border, ring, "No Set called by Alex", "n/m agreed"
  - locked out: `red-950` with a `red-600` border, "Wrong! −1" or "Time's up! −1", `animate-shake`
  - idle: empty, the slot keeps its size
- `players/controller/_found_banner` (v2): `green-950` panel with a `green-500` border, the 3 cards small, the caller's dot, "Alex found a Set" and "+1" in `green-400`. Absolutely positioned over the top of the board area, over the scoreboard in portrait. `pointer-events: none`, `.found-set-flash`
- `players/controller/_roster` (v2): the Waiting roster, two columns, each a dot, the name, "you" for the player and a `green-400` ✓ once ready
- `players/controller/_invite` (v2): the room code in display type, "or open onset.joaotorr.es and enter the code" (`join_host`), the link button (Copy link, Copied ✓, Couldn't copy, Share link), a Show QR button and the "Show on a big screen →" text link
- `players/controller/_qr_sheet` (v2): overlay `gray-950` at 85%. Portrait: a bottom sheet. Landscape: a centered card, QR on the left, code and Done on the right. Computer: a centered 352px modal. QR on a white tile, 288px in portrait and computer, 300px in landscape, the code under it, Done in `blue-600`
- `players/controller/_standings` (v2): game over rows, each rank, dot, truncated name, "you" for the player, score. Own row `gray-800` with a `gray-600` border, other rows transparent. Rows 32px portrait, 34px landscape, 44px computer (computer list in a `gray-900` panel)
- Landing mode toggle (v2): two radios styled as a segmented control inside the Start a game form, on a `gray-950` (desktop) or `gray-900` (phone) track with a `gray-700` border. Selected Standard `gray-700`, selected First to 5 `violet-600`, unselected `gray-400` text on transparent
- `layouts/_byline_footer` (v3): "by joaotorr.es" after `main` on the landing, How to play and the join page, never on the big screen or player screen. `gray-400` 14px weight 500 with a 1px red underline; on hover or keyboard focus the dot hops and the domain fades into the logo colours (`--wm-*`), held until the next page load. Styles in `app/assets/tailwind/application.css` (`.byline`, `.wm-*`), fixed across joaotorr.es apps
- Stimulus: `card-selection` (picks sent to the server, tray, count), `countdown` (rings and seconds)

## Screens

Drawn for v2. Sizes are the boards': portrait 375×667, landscape 667×375, computer 1024×640, landing desktop 1280×800.

### Landing (ticket 08)

- Desktop: brand on the left (wordmark 136px, tagline 24px `gray-300`, three fanned cards with the caption in `gray-400`), actions on the right in a 448px `gray-900` card with a `gray-800` border: the mode toggle, Start a game (`blue-600`, 60px, display type), its sub-line in `gray-400`, a divider, then "Have a room code?", the code field and a `gray-800` Join button
- Phone, top to bottom: wordmark and tagline, the join form, a divider, the mode toggle and Start a game, then the fanned cards and caption at the bottom
- Room not found: "Room not found" in `red-400` under the code field, the field empty with a `red-500` border

### Join page (ticket 08)

- "Joining room" in `gray-400`, the code at 60px in display type
- Base error (game already started): a `red-950` box with a `red-700` border and `red-200` text, under the code
- Field errors in `red-400` under their field, the field with a `red-500` border
- Color grid 4×2, 56px swatches. Selected: a white ring offset by `gray-950`, with a white ✓. Taken: the preset blended 30% over `gray-950`, the taker's initial in `gray-300` in display type
- Join at the bottom (`blue-600`, 56px). For the creating browser, "Use this screen as the big screen instead" under it as a `blue-300` text link
- Full room (every color taken, triage 08): "This room is full" in the base error box, no swatch selected, Join disabled as `gray-800` with `gray-500` text, as the big screen's disabled Start game. Wins over the join-full board, which shows no message

### Player screen, Waiting (ticket 10)

- Header, then "You're in", the roster, the invite and I'm ready (`green-700`). Once voted: "Ready ✓ · waiting for n more" as outlined `green-700` text on a 12% `green-700` tint, `green-300` text
- Landscape and computer put the roster and the invite side by side
- The link button's feedback states (Copied ✓, Couldn't copy) stay neutral gray
- The QR sheet is `_qr_sheet`; the "Room CODE" footer stays

### Player screen, during play (ticket 09)

- Portrait, top to bottom: the scoreboard, the board at full width, the status slot (64px, empty in idle), the 128×128 SET! slot and its pill
- Landscape: the board on the left, a 9rem action column (status panel, SET!, pill), a scores column
- Computer: the board on the left; a 248px side column with the scoreboard stacked above the status panel, SET! and its pill
- Deck: "N cards left in the deck" with the board, or an orange "Deck is empty" pill
- Claiming (mine): portrait, the claim bar takes the status slot and the 3-slot tray replaces SET! and its pill. Landscape and computer: one yellow block replaces the panel and SET!, and the pill slot is empty
- Someone else claiming: the disabled SET! shows the seconds large with a small "SET!" label under them, inside the yellow ring
- Read-only boards (someone else claiming, No Set, locked out) are not dimmed
- Found-set banner: in portrait it covers the scoreboard for its 3s; the board under it shows the replaced cards with the arrive outline

### Player screen, Game over (ticket 07)

- Header, the rank in display type (64px portrait, 60px landscape, 120px computer), "of N players · P points" in `gray-400`, the winner line, the standings, Play again (`green-700`) or "Ready ✓ · waiting for n more" as on Waiting
- Landscape: rank, winner line and Play again in a 250px left column, the standings on the right
- Computer: a 360px left column, the standings in a `gray-900` panel on the right
- The standings scroll inside themselves when they do not fit; the page never does

## Rules added in v2

- White text on green uses `green-700` (`#15803D`); `green-600` is about 3.3:1, as with `orange-700`. I'm ready and Play again on the player screen
- Filled purple pills (No Set, I agree, no Set) use `purple-700` with white text. The waiting text after agreeing is outlined `purple-500` with `purple-200` text
- Card face `#FAFAFA` with a `#E5E5E5` border. Selected: a 4px `blue-400` ring and scale 0.95. Arrive: a 3px `green-400` ring
- Taken color swatch: the preset blended 30% over `gray-950` with the initial in `gray-300`, not opacity, which would fade the initial too
- Player screen card size, in every layout: `cw = floor(min((boardW - (cols - 1) * gap) / cols, ((boardH - 2 * gap) / 3) * 5 / 7))`, `cols = cards / 3`, gap 5px on phones and 12px on computer. At 8 players and 18 cards: portrait 54×76, landscape 55×77, computer 106×148. Portrait at 3 players and 12 cards: 71×99. Landscape shrinks the cards to fit the width, with no sideways scroll; at 12 cards they fill the height
- SET! slot 128×128 in every layout, the button 104px (108px on computer). Ring states put a 128px ring around a 100px disabled `gray-800` button
- Portrait keeps the status slot at 64px in every state, so the board never resizes on a state change
- Copy link feedback stays neutral gray: green and red are reserved by the meaning table

## Visual rules

Quoted from `SPEC.md`.

### SPEC §10. Cards and visual system

#### Palette

Colorblind-safe (IBM 3-color palette):

- **Blue**: `#648FFF`
- **Orange**: `#FE6100`
- **Magenta**: `#DC267F`

Background: near-white (`#FAFAFA`). Card border: subtle, `#E5E5E5`. Selected card on the player screen: `ring-4 ring-blue-400 scale-95`.

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
  - **Striped**: `fill="url(#stripes-#{color}-#{suffix})"`, a 40° hatch of 3.5px lines on a 7px pitch. Each SVG defines its own `<pattern>`, with an id unique to that rendered SVG, never to the card alone: the same card can appear twice on one page, and a browser resolves `url(#id)` to the first element with that id, so a duplicate inside a hidden element paints the shape empty. A copy made in the browser (the player screen tray, §11) gets fresh ids too.

The SVG fills its wrapper; wrappers set the size with a 5:7 aspect ratio. The partial is never restyled, only sized.

- **Big screen grid**: 3 rows flowing into columns, centered, no horizontal scroll at 18 cards. Cards are `15rem` tall at 1080px and shrink with the viewport (`min(15rem, (100dvh - 22rem) / 3)`) so the third row never runs under the announcement band.
- **Player screen, portrait**: in every playing state the grid fits the width (`auto-cols-fr`) and shrinks to the height left, so SET! and its pill never leave the screen.
- **Player screen, landscape**: 3 rows flowing into columns, the cards shrinking to fit the board's width and height, with no sideways scroll; at 12 cards they fill the height.
- **Player screen, computer**: 3 rows flowing into columns, sized to the board's width and height, no horizontal scroll at 18 cards.

On the player screen, in every layout, a card takes the largest size at which `cards / 3` columns fit the board's width and 3 rows its height, with a 5px gap on phones and 12px on computer.

Triage 09 rewrote the landscape line in `SPEC.md` to match the v2 card size rule.

#### Visual system

Dark UI where the cards are the only bright surfaces. Tailwind default palette plus these tokens in `app/assets/tailwind/application.css`:

- `font-display`: Bricolage Grotesque (Google Fonts link in the layout). Only for display text: wordmark, room code, scores, SET!, headlines, countdown digits. Body copy stays on the default sans.
- `animate-shake`: once, 0.4s. Locked-out player screen panel.
- `animate-arrive`: green outline that holds 1.5s and fades by 3s. Cards dealt by the last replace (`Game#last_dealt`), on the big screen and the player screen board.
- `.found-set-flash`: holds 1.5s, fades by 3s. Correct-claim panels on the big screen and the player screen.

Surfaces: page `gray-950`, panels `gray-900`, borders `gray-700`/`gray-800`. Secondary text `gray-400`, muted `gray-500` (not `gray-600`, which fails contrast on `gray-950`).

Each color means one thing everywhere:

| Color | Meaning |
|---|---|
| blue-600 | SET! and primary actions |
| violet-600 | quick game |
| yellow-400 | a claim in progress (big screen panel, scoreboard entries, player screen claim bar) |
| purple | No Set. It used to be red; red now only means wrong or locked |
| red | wrong claim, timeout, lockout |
| green | ready, correct, start, play again |
| orange | deck empty and the End game vote (`orange-700` for white text; `orange-600` is only about 3.3:1) |

Player colors are the 8 presets in `PlayersController::PRESET_COLORS`, deliberately apart from the card palette. They show as dots, the player screen's top border strip and podium bars.

Countdown rings: `r=45` in a 100 viewBox, gray track, colored progress with round caps, rotated -90° so they drain clockwise from the top. Seconds sit inside the ring, or inside the button the ring surrounds.

QR codes: dark modules on a white tile. Inverted codes fail on some phone cameras.

## Known gaps

None

## Open questions

- Answered by triage 07 in SPEC §8 Player screen > 8. Game over: a tied rank stays a plain "1st", and the winner line reads "★ You win with 7" when the viewer wins, as the code already does. Redraw the -win boards to match in the next brief that touches game over

---

## Changelog

- v3, 2026-10-16: ticket 24, the byline footer `_byline_footer` and the `--wm-*` logo colours, taken from the cross-app byline brief as built in d7f1cc8, not from a design pass.
- v2, 2026-10-12: ticket 07, game over standings on the player screen in portrait, landscape and computer: `_standings`, own row `gray-800`, Play again on `green-700`.
- v2, 2026-10-12: ticket 08, devices-first landing (mode toggle, one Start a game, phone order) and the join page with the creator's big screen link, field and base errors, and taken swatches blended over `gray-950`.
- v2, 2026-10-12: ticket 09, the player screen during play stands alone in portrait, landscape and a new computer layout: `_scoreboard`, `_status_panel`, `_found_banner`, the card size rule with no landscape sideways scroll, the 128px SET! slot, filled purple pills on `purple-700`.
- v2, 2026-10-12: ticket 10, the waiting invite on every player screen: `_roster`, `_invite`, `_qr_sheet`, I'm ready on `green-700`, neutral Copy link feedback.
- v1, 2026-10-12: taken from the code and SPEC §10 as built at deploy-20261011-1849.
