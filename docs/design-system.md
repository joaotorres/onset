# Onset design system, version 1

The tokens, components and visual rules the views use today. Kind: visual tickets wait for an entry under `## Changelog` that covers them (loop-rules gate 2).

## Tokens

From `app/assets/tailwind/application.css` (`@theme`), on top of the Tailwind default palette:

| Token | Value | Use |
|---|---|---|
| `--font-display` | Bricolage Grotesque, ui-sans-serif, system-ui, sans-serif | Display text only |
| `--animate-shake` | `shake 0.4s ease-in-out 1`, ±8px | Locked-out phone panel |
| `--animate-arrive` | `arrive 3s ease-out forwards`, green-400 outline to transparent from 50% | Cards dealt by the last replace |
| `.found-set-flash` | `found-set-fade-out 3s`, opaque until 50% | Correct-claim panels |

Card palette (`app/views/cards/_card.html.erb`): blue `#648FFF`, orange `#FE6100`, magenta `#DC267F`.

Player colors (`PlayersController::PRESET_COLORS`): `#E74C3C #2ECC71 #F1C40F #9B59B6 #1ABC9C #E91E63 #00BCD4 #8BC34A`.

## Components

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

## Visual rules

Quoted from `SPEC.md`.

### SPEC §10. Cards and visual system

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

---

## Changelog

- v1, 2026-10-12: taken from the code and SPEC §10 as built at deploy-20261011-1849.
