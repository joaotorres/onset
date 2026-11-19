# Onset design system, version 7

The tokens, components and visual rules the views use, and the devices-first screens drawn for tickets 07, 08, 09 and 10, the No Set refusal drawn for ticket 21, the claim's Submit button drawn for ticket 37, the light theme, the settings menu and the two card palettes drawn for tickets 40 and 41, the static error pages drawn for ticket 42 and the dark contrast shades drawn for ticket 46. Kind: visual tickets wait for an entry under `## Changelog` that covers them (loop-rules gate 2).

Boards for every screen and state are on the canvas named in `docs/design-handoff.md`. Where this file and a board differ, this file wins; tell the design tool in the next brief.

## Shared: Tokens

From `app/assets/tailwind/application.css` (`@theme`), on top of the Tailwind default palette:

| Token | Value | Use |
|---|---|---|
| `--font-display` | Bricolage Grotesque, ui-sans-serif, system-ui, sans-serif | Display text only |
| `--animate-shake` | `shake 0.4s ease-in-out 1`, ±8px | Locked-out player screen panel |
| `--animate-arrive` | `arrive 3s ease-out forwards`, green-400 outline to transparent from 50% | Cards dealt by the last replace |
| `.found-set-flash` | `found-set-fade-out 3s`, opaque until 50% | Correct-claim panels and the found-set banner |
| `muted` (v7, dark only) | `#7C8390`, on the gray hue a third of the way from `gray-500` to `gray-400`, outside the Tailwind palette | Dark muted text and dark form placeholders (Shared: Themes (v6), Text). Light muted stays `gray-500` |

Card palettes (v6), card color 0, 1, 2, the same in both themes, picked per browser under Card colors. Ratios against the `#FAFAFA` face; shapes are graphics, so 3:1 is the bar:

| Palette | Color 0 | Color 1 | Color 2 |
|---|---|---|---|
| Classic (the default) | red `#C1121F`, 5.96:1 | green `#198A1E`, 4.28:1 | purple `#5E2CA5`, 8.45:1 |
| Color-blind, with the color mark | blue `#648FFF`, 2.91:1 | orange `#FE6100`, 2.91:1 | magenta `#DC267F`, 4.35:1 |

The Classic shades sit darker than the player presets and apart in hue: red `#C1121F` (hue 356°, 41% lightness) against `#E74C3C` (6°, 57%) and `#E91E63` (340°, 52%); green `#198A1E` (123°, 32%) against `#2ECC71` (145°, 49%) and `#8BC34A` (88°, 53%); purple `#5E2CA5` (265°, 41%) against `#9B59B6` (283°, 53%). Luminance ratio between each Classic shade and its nearest preset: 1.63, 2.13, 1.89. Before v6 every card used the Color-blind colors, without the mark.

Player colors (`PlayersController::PRESET_COLORS`): `#E74C3C #2ECC71 #F1C40F #9B59B6 #1ABC9C #E91E63 #00BCD4 #8BC34A`.

Byline logo colours (v3, `--wm-*`): light on `:root` green `#009C3B`, blue `#002776`, red `#C60B1E`, gold `#E08A00`; dark on `.byline-footer` in the dark theme: green `#22C35E`, blue `#5B8CFF`, red `#FF4F5E`, gold `#FFD21F`; under the light theme (`@variant light`) `.byline-footer` takes the light values again (SPEC §8 Byline footer, Logo colours).

v2 adds no tokens: every new color is from the Tailwind default palette. v7 adds `muted`, the one color outside it.

## Shared: Themes (v6)

Two themes, Dark and Light, each color one CSS value per theme keyed on `<html>`, on the same markup. Dark is every value this file gave before v6, but for the three dark rows v7 raises to contrast (ticket 46): muted text, placeholders and the field border at rest. Ratios are WCAG contrast on the value's own ground: the light page (`gray-50` `#F9FAFB`) unless stated; dark ratios, where given, on `gray-950` `#030712` unless stated. Every value is from the Tailwind default palette but dark `muted` `#7C8390` (Shared: Tokens). The light theme sheet on the canvas (`LightSheet`) shows each pair; the dark contrast sheet (`DarkSheet`) shows the v7 dark values on each ground they sit on, beside light.

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
| Field border at rest (the landing's room code field, the join page's name field) | `gray-500` (v7, was `gray-700`): 3.67:1 against `gray-900`, 4.16:1 against `gray-950`, so 3:1 against fill and surround on the landing phone, the landing desktop actions card and the join page; `gray-600` is 2.34:1 on `gray-900` | `gray-500` | 4.84:1 on white, 4.63:1 on `gray-50` |
| Field border with an error | `red-500` | `red-600` | 4.62:1 |
| Input fill | `gray-950` (desktop), `gray-900` (phone) | white | ground |
| Empty tray slot border (dashed) | `gray-700` | `gray-400` | decorative |

Text

| Role | Dark | Light | Light ratio |
|---|---|---|---|
| Primary | `gray-50` (white on the big screen) | `gray-900` | 16.98:1, 17.74:1 on white |
| Values (`gray-200`: host name, How to play values, tip text) | `gray-200` | `gray-800` | 14.05:1 |
| Body (`gray-300`: tagline, sub-lines, captions, "is calling SET!") | `gray-300` | `gray-700` | 9.86:1, 10.31:1 on white |
| Secondary (`gray-400`: labels, deck line, "you", byline) | `gray-400` | `gray-600` | 7.23:1, 7.56:1 on white |
| Muted (Room CODE footer, tray slot numbers, player screen settings icon, big screen empty band, "No one yet" and a locked player's row, the "/N" of the No Set count, join page hint) | `muted` `#7C8390` (v7, was `gray-500`): 5.28:1 on `gray-950`, 4.88:1 on the No Set band (`#130F29`), 4.65:1 on `gray-900`; never on `gray-800` (3.85:1) | `gray-500` | 4.63:1, 4.84:1 on white, 4.51:1 on the No Set band (`purple-50`); never on `gray-100` (4.40:1) |
| Placeholder (v7: room code and name fields) | `muted` `#7C8390`: 4.65:1 on the `gray-900` fill, 5.28:1 on the `gray-950` desktop fill | `gray-500` | 4.84:1 on white |

Dark text ladder on `gray-950` (v7): primary 19.27:1, values 16.25:1, body 13.66:1, secondary 7.93:1 (6.99:1 on `gray-900`), muted 5.28:1. Muted stays a step apart from secondary rather than merging into `gray-400`, so the footer, the empty band, "No one yet" and a locked player's row stay quieter than labels and the deck line, and dark keeps the five steps light has.

Meaning colors as fills with white text are the same in both themes: `blue-600`, `violet-600`, `purple-700`, `red-600`, `green-700`, `orange-700`. So is the claim fill, `yellow-400` with `gray-950` text.

Meaning colors as tinted panels. Light: the 50 tint, a 600 border or ring (yellow uses 500), text in 700 or 800

| Panel | Dark | Light |
|---|---|---|
| Someone else claiming | `gray-900`, 2px `yellow-400` | white, 2px `yellow-500` |
| No Set status panel | `purple-950`, `purple-500`, sub `purple-200` | `purple-50`, `purple-600`, sub `purple-800`, title `gray-900` |
| Refused status panel | `gray-900`, `purple-500`, `gray-300` text | white, `purple-600`, `gray-700` text |
| Locked out | `red-950`, `red-600`, `red-200` text | `red-50`, `red-600`, `red-700` text |
| Found-set banner | `green-950`, `green-500`, +1 `green-400` | `green-50`, `green-600`, +1 `green-700` |
| Ready ✓ waiting | `green-700` at 12%, `green-700` border, `green-300` text | `green-50`, `green-700` border, `green-800` text |
| Base error box | `red-950`, `red-700` border, `red-200` | `red-50`, `red-600` border, `red-800` |
| Band, Claiming | `yellow-400` 10%, 2px `yellow-400` ring, name and seconds `yellow-400` | `yellow-50`, `yellow-500` ring, name and seconds `yellow-800` |
| Band, No Set and Refused | `purple-500` 10%, `purple-500` ring, name `purple-400`, seconds `purple-300` | `purple-50`, `purple-600` ring, name `purple-700`, seconds `purple-800` |
| Band, Correct | `green-500` 10%, `green-500` ring, `green-400` | `green-50`, `green-600` ring, `green-700` |
| Band, Wrong / Time's up | `red-500` 10%, `red-500` ring, `red-400` | `red-50`, `red-600` ring, `red-700` |
| Big screen Locked pill | `red-500` 15%, `red-400` | `red-100`, `red-700` |
| Big screen Deck is empty pill | `orange-500` 15%, ring `orange-500/40`, `orange-400` | `orange-50`, ring `orange-600/45`, `orange-800` |
| How to play rings and rows | `green-500/40`, `red-500/40` with a `red-500` 10% row, `blue-500` 10% panels with `blue-500/40`, `purple-800` ring | `green-600/45`, `red-600/45` with a `red-50` row, `blue-50` panels with `blue-600/35`, `purple-300` ring |

Meaning colors as text

| Role | Dark | Light | Light ratio |
|---|---|---|---|
| Green (✓, all the same, Right: +1) | `green-400` | `green-700` | 4.80:1 |
| Red (field errors, ✗, Wrong) | `red-400` (`red-300` label, `red-200` value in the Not a Set row) | `red-700` (label), `red-800` (value) | 6.19:1, 7.60:1 on `red-50` |
| Links and step numbers | `blue-300`, `blue-400` | `blue-700` | 6.41:1 |
| Purple titles and band names | `purple-300`, `purple-400` | `purple-700` | 6.68:1 |
| Locked label under SET! | `red-300` on `gray-800` | `red-700` on `gray-200` | 5.22:1 |
| Podium ★ | `yellow-400` | `yellow-700` | 4.70:1 |

Disabled, rings, outlines and the rest

| Role | Dark | Light |
|---|---|---|
| Disabled filled pill (v5 rule) | `purple-700` 35% + `purple-200`; `blue-600` 35% + `blue-200` | `purple-100` + `purple-700` (5.92:1); `blue-100` + `blue-700` (5.49:1) |
| Disabled gray button (Start game with 1 player, Join when full) | `gray-800` + `gray-500` (not `muted`: disabled labels are exempt, v7) | `gray-200` + `gray-600` (6.10:1) |
| Countdown progress | `yellow-400`, `red-500`, `purple-400` | `yellow-600` (2.81:1, the seconds inside carry the count), `red-600`, `purple-600` |
| Countdown track | `gray-800` (player screen), `gray-700` (big screen) | `gray-300` |
| Focus outline, 2px, offset 2px | `blue-500` | `blue-500` (3.52:1, 3.68:1 on white) |
| Selected card ring, 4px | `blue-400` | `blue-500` |
| Arrive outline, 3px | `green-400` | `green-600` (3.15:1) |
| Card wrapper edge | none | `0 0 0 1px #D1D5DB, 0 1px 3px rgba(3, 7, 18, 0.12)` |
| Overlay behind the QR sheet | `gray-950` at 85% | `gray-950` at 45%; the sheet white with a `gray-300` top border |
| Segmented control, selected (landing mode toggle Standard, settings menu) | `gray-700` + white | `gray-800` + white (14.68:1) |
| Segmented control, unselected text | `gray-400` | `gray-600` |
| Segmented track | `gray-950` on a panel, `gray-900` on the page | `gray-100` on a panel, white on the page |
| Join swatch, selected | 3px `gray-950` gap, 3px white ring | 3px `gray-50` gap, 3px `gray-900` ring |
| Join swatch, taken | preset 30% over `gray-950`, initial `gray-300` | preset 30% over `gray-50` (`#E74C3C` gives `#F4C6C2`), initial `gray-700`, 6.7:1 or more on every preset |
| QR tile | white, dark modules | the same, plus the 1px `gray-200` inset edge |
| Byline at rest | `gray-400`, 1px underline `#FF4F5E` | `gray-600`, underline `#C60B1E` (5.79:1) |
| Shadows | cards `rgba(0, 0, 0, 0.55)`; banner and menu `rgba(0, 0, 0, 0.6)` | cards `rgba(3, 7, 18, 0.16)`; banner 0.12; menu 0.18 |
| `theme-color` | `#030712` | `#F9FAFB` |

## Shared: Rules added in v2

- White text on green uses `green-700` (`#15803D`); `green-600` is about 3.3:1, as with `orange-700`. I'm ready and Play again on the player screen
- Filled purple pills (No Set, I agree, no Set) use `purple-700` with white text. The waiting text after agreeing is outlined `purple-500` with `purple-200` text
- Card face `#FAFAFA` with a `#E5E5E5` border. Selected: a 4px `blue-400` ring and scale 0.95. Arrive: a 3px `green-400` ring. Light shades of both rings in Shared: Themes (v6)
- Taken color swatch: the preset blended 30% over the page (`gray-950`, light `gray-50`) with the initial in `gray-300` (light `gray-700`), not opacity, which would fade the initial too
- Player screen card size, in every layout: `cw = floor(min((boardW - (cols - 1) * gap) / cols, ((boardH - 2 * gap) / 3) * 5 / 7))`, `cols = cards / 3`, gap 5px on phones and 12px on computer. At 8 players and 18 cards: portrait 54×76, landscape 55×77, computer 106×148. Portrait at 3 players and 12 cards: 71×99. Landscape shrinks the cards to fit the width, with no sideways scroll; at 12 cards they fill the height
- SET! slot 128×128 in every layout, the button 104px (108px on computer). Ring states put a 128px ring around a 100px disabled `gray-800` button
- Portrait keeps the status slot at 64px in every state, so the board never resizes on a state change
- Copy link feedback stays neutral gray: green and red are reserved by the meaning table

## Shared: Rules added in v5

- A disabled filled pill keeps its label legible: the fill at 35% with the light tint of its color as text at full opacity (blocked No Set: `purple-700` at 35%, `purple-200`; disabled Submit: `blue-600` at 35%, `blue-200`), never the whole button faded

## Shared: Rules added in v6

- Two themes, Dark and Light. A light screen changes colors only, plus the card wrapper's edge: every element, size and position is the dark screen's. Values in Shared: Themes (v6)
- A panel with no border (big screen room tile and player pills, How to play panels, the QR tile) gets a 1px `gray-200` inset edge in light, as a `box-shadow`, so nothing resizes. Panels that already have a border keep it, recoloured
- Light tinted panels use the 50 tint of their color, a 600 border or ring (yellow: 500) and text in 700 or 800. Meaning fills with white text are the same in both themes
- Light muted text (`gray-500`) sits only on the page or on white in light, never on `gray-100`. Dark muted: Shared: Rules added in v7
- The v5 disabled-pill rule in light: the 100 tint of the color as fill, its 700 as text, at full opacity
- Both disabled No Set pills, while someone else claims and blocked after a refusal, follow the v5 rule in both themes: dark `purple-700` at 35% with `purple-200` text at full opacity, never the whole button at 35%. The old dark boards still draw the whole button faded; this rule wins
- Countdown rings in light: progress in the 600 shade, track `gray-300`. The seconds digits carry the count
- The segmented control's selected segment is `gray-800` in light, so it reads on both the white and the `gray-100` track
- Card wrapper edge, light only: on the card's wrapper, never inside `_card`, wherever a card sits on a light surface (board, tray, found-set banner, band, landing fan, How to play)
- Card colors: Classic is the default; Color-blind is the IBM palette plus the color mark (`cards/_card`). Words that name a card color follow the setting: How to play's Color captions ("red, green, purple" or "blue, orange, magenta") and the Not a Set row ("two red, one green" or "two blue, one orange")
- The settings button never moves SET!, the pill slot or the board, and adds no page scroll. On the player screen it lives in the "Room CODE" footer row
- Page boards carry the byline footer under a viewport-tall `main`: landing and join page at 375×727 (667 + 60) and 1280×860 (800 + 60)

## Shared: Rules added in v7

- Dark muted text and dark placeholders are `muted` `#7C8390`, never `gray-500`. Dark muted sits only on `gray-950`, `gray-900` (the placeholders in their fields) or the No Set band, never on `gray-800` (3.85:1)
- The player screen settings button icon follows muted in both themes (dark `#7C8390`, 5.28:1; its bar is 3:1 as a graphic), so the "Room CODE" footer row stays one shade
- The two form fields' border at rest is `gray-500` in both themes. Their error border is unchanged (`red-500` dark, `red-600` light)
- Stays as built: disabled controls keep `gray-800` with `gray-500` text, and every `gray-700` border that is not a form field stays `gray-700` (the mode toggle's track, the Join, Copy link and Show QR buttons, the settings menu, the QR sheet, the empty tray slot's dashed border)
- Built dark boards still draw muted `gray-500` and the `gray-700` field border; this file and `DarkSheet` win. The code is the truth for each built screen's layout

## Shared: Visual rules

Quoted from `SPEC.md`.

### SPEC §10. Cards and visual system

#### Palette

Two card palettes. Each browser picks one in the settings menu (§8, Settings menu), under **Card colors**:

- **Classic** (the default): Set's own red, green and purple, far apart in hue so they read at a glance. The exact shades come from the design pass (`docs/design-system.md`). Each stays clearly apart from the other two, reads on the card face, and stays apart from the player colors, which already hold a red, a green and a purple of their own (`PlayersController::PRESET_COLORS`).
- **Color-blind**: the IBM colorblind-safe palette, the one every card used before Classic: **Blue** `#648FFF`, **Orange** `#FE6100`, **Magenta** `#DC267F`. It also draws a **color mark** on every card: one small mark per color, the same on every card of that color, so the three colors can be told apart without seeing color at all. The mark never changes the shapes, their number or their shading, the card's other three features, and cannot be mistaken for one of them. It sits inside the card's SVG, so card sizes and every layout stay as they are. Its form and place come from the design pass. Its blue and orange measure 2.91:1 on the card face, just under the 3:1 bar for graphics; they stay as IBM sets them, because this is the palette players already know and the color mark tells the three apart by form, not by contrast.

Card color 0, 1 and 2 (§4, Card) are red, green and purple in Classic and blue, orange and magenta in Color-blind, so a Set is the same Set under both.

- **Stored per browser**, as the theme is (Themes below): a `card_colors` cookie, `colorblind`, path `/`, a year long, SameSite Lax, not HttpOnly so the settings menu can write it. Classic deletes it. The layout renders the choice on `<html>`, so the first paint already has the right colors
- **Never in a broadcast.** Cards render inside Turbo Stream partials shared by every screen in a room (§7), so the `_card` partial draws the same markup for every viewer: the card colors come from CSS keyed on `<html>`, and the color mark is always in the markup, shown only under Color-blind
- **Picking applies at once** to every card on the page, with no reload, as a theme does. Other open tabs take it on their next page load, every kind of page load the theme names (Themes below), from the cookie as it is then
- **Independent of the theme**: each palette, and the color mark, is the same in the dark and light themes
- **Everywhere a card renders**: the big screen board and announcement band, the player screen board, tray and found-set banner, the landing's fanned cards and the How to play diagrams. Words that name a card color follow the setting the same way, both versions in the markup and CSS showing the one that matches: How to play's color captions (red, green, purple or blue, orange, magenta) and its Not a Set example ("two red, one green" or "two blue, one orange")

Card face, the same under both palettes: near-white (`#FAFAFA`). Card border: subtle, `#E5E5E5`. Selected card on the player screen: `ring-4 ring-blue-400 scale-95`, the ring `blue-500` in the light theme (`light:ring-blue-500`).

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

The SVG fills its wrapper; wrappers set the size with a 5:7 aspect ratio. The partial is never restyled, only sized; its colors and color mark follow the card colors setting through CSS alone (Palette above).

- **Big screen grid**: 3 rows flowing into columns, centered, no horizontal scroll at 18 cards. Cards are `15rem` tall at 1080px and shrink with the viewport (`min(15rem, (100dvh - 22rem) / 3)`) so the third row never runs under the announcement band.
- **Player screen, portrait**: in every playing state the grid fits the width (`auto-cols-fr`) and shrinks to the height left, so SET! and its pill never leave the screen.
- **Player screen, landscape**: 3 rows flowing into columns, the cards shrinking to fit the board's width and height, with no sideways scroll; at 12 cards they fill the height.
- **Player screen, computer**: 3 rows flowing into columns, sized to the board's width and height, no horizontal scroll at 18 cards.

On the player screen, in every layout, a card takes the largest size at which `cards / 3` columns fit the board's width and 3 rows its height, with a 5px gap on phones and 12px on computer.

Triage 09 rewrote the landscape line in `SPEC.md` to match the v2 card size rule.

#### Visual system

Two themes, dark and light, on every page the app renders (Themes below). In the dark theme the cards are the only bright surfaces. Tailwind default palette plus these tokens in `app/assets/tailwind/application.css`:

- `font-display`: Bricolage Grotesque (Google Fonts link in the layout). Only for display text: wordmark, room code, scores, SET!, headlines, countdown digits. Body copy stays on the default sans.
- `animate-shake`: once, 0.4s. Locked-out player screen panel.
- `animate-arrive`: green outline that holds 1.5s and fades by 3s. Cards dealt by the last replace (`Game#last_dealt`), on the big screen and the player screen board.
- `.found-set-flash`: holds 1.5s, fades by 3s. Correct-claim panels on the big screen and the player screen.

Surfaces, dark theme: page `gray-950`, panels `gray-900`, borders `gray-700`/`gray-800`. Secondary text `gray-400`. The light theme's surfaces, borders and text shades, and the dark muted text and field border shades, come from the design pass (`docs/design-system.md`). Both themes hold the same contrast:

- **Text** at least 4.5:1 on its ground, the page or the panel it sits on, whatever its size: body, secondary and muted text alike (the "Room CODE" footer, the big screen's empty band text, "No one yet" and a locked player's entry on its scoreboard, the "/N" of a No Set vote count, the join page's hint under the colors, the tray slot numbers), and the placeholders in form fields, as the white-on-color rules in the meaning table below are. The labels of disabled controls are exempt, as WCAG makes them, and keep the disabled looks `docs/design-system.md` gives
- **A form field's border at rest** at least 3:1 against the field's fill and against the surface around it, because a field sits on a surface close to its fill and its border is all that shows it. Today the room code field on the landing and the name field on the join page

History: until ticket 46, dark muted text was `gray-500` (4.16:1 on `gray-950`, 3.67:1 on `gray-900`) and the dark field border at rest `gray-700` (1.72:1 on `gray-900`); ticket 40 left them so, since it kept dark as built, and deferred them to ticket 46.

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

Player colors are the 8 presets in `PlayersController::PRESET_COLORS`, deliberately apart from both card palettes (Palette above). They show as dots, the player screen's top border strip and podium bars.

Countdown rings: `r=45` in a 100 viewBox, gray track, colored progress with round caps, rotated -90° so they drain clockwise from the top. Seconds sit inside the ring, or inside the button the ring surrounds.

QR codes: dark modules on a white tile. Inverted codes fail on some phone cameras.

#### Themes

**Dark** is the look every screen had before themes. **Light** puts dark text on light surfaces. Each browser picks one in the settings menu (§8, Settings menu): **Match device** (the default), **Light** or **Dark**. Match device follows the device's light or dark setting (`prefers-color-scheme`), live: switching the device's setting while a page is open switches the page with it. A device that states no preference gets dark.

- **The theme never reaches a broadcast.** Turbo Stream partials (§7) are rendered once for every screen in a room, so nothing in them depends on the viewer's theme: every themed color comes from CSS keyed on `<html>`, never from markup rendered per theme
- **Same in both themes:** the cards (the `_card` partial is never restyled, its near-white face and border included; on light surfaces the design pass may give the card's wrapper an edge so it reads), the card palettes (which one shows is the card colors setting, Palette above, not the theme), the player colors, what each color means (the meaning table above; the light theme may use other shades of the same color for contrast), the QR tile (dark modules on white), the layouts, sizes and animations
- **Every page the app renders** takes the theme: the landing, How to play, the join page, the big screen, the player screen and the byline footer, which uses the light logo colours in the light theme and the dark ones in the dark theme (§8, Byline footer)

`SPEC.md` §10 Themes also holds the `theme` cookie, the no-flash rule, `color-scheme` and the static error pages, which take both themes in Onset's own surfaces and text shades (Screens > Static error pages, v7).

## Components

ERB partials, no component library.

### cards/_card
- `cards/_card`: the card SVG, 200×280 viewBox, sized only by its 5:7 wrapper. v6: its three colors come from CSS keyed on `<html>` (Classic or Color-blind, Shared: Tokens), and it always renders the color mark, which CSS hides under Classic. Face, border, shapes and shading do not change
  - Color mark (v6, Color-blind only): one solid mark per card color, filled in the card's own color, no stroke, never shaded. It sits in the top-left corner and again, turned 180°, in the bottom-right, like a playing card's index, so it reads as a corner label rather than a shape or a count. Each fits a 28-unit box, centred at (22, 20) and at (178, 260), in the free bands above y 40 and below y 240 and clear of the shape stack (x 45 to 155). Points in units from the box centre; the bottom-right copy negates them:
    - Color 0 (blue): a triangle, (0, −14) (14, 12) (−14, 12)
    - Color 1 (orange): a plus, arms 14 long and 9 thick: (−4.5, −14) (4.5, −14) (4.5, −4.5) (14, −4.5) (14, 4.5) (4.5, 4.5) (4.5, 14) (−4.5, 14) (−4.5, 4.5) (−14, 4.5) (−14, −4.5) (−4.5, −4.5)
    - Color 2 (magenta): a five-point star, outer radius 15, inner 6.2, nudged 1.5 down: (0, −13.5) (3.64, −3.52) (14.27, −3.14) (5.9, 3.42) (8.82, 13.64) (0, 7.7) (−8.82, 13.64) (−5.9, 3.42) (−14.27, −3.14) (−3.64, −3.52)
    - About 7.6px at the smallest card (54×76), about 24px on the big screen (171×240)
  - Card wrapper edge (v6, light only): on the wrapper, never inside the partial (Shared: Rules added in v6)
### games/_ring
- `games/_ring`: big screen countdown ring, size-24, seconds inside
### games/_scoreboard
- `games/_scoreboard`: big screen score rows, sorted by score
### games/_start_button
- `games/_start_button`: Start game with "n of m ready", or disabled with the reason
### games/_announcement
- `games/_announcement`: the 9rem announcement band and its tinted panels. Refused (v4): the No Set panel's tint, ring and type; the ring counts the block down (`purple-400` progress, `purple-300` seconds), "Alex says there's a Set" in 48px display bold with the name in `purple-400`, "No Set is back when the ring runs out" in 24px `gray-300`, nothing on the right. At 1280px wide the headline wraps onto two balanced lines inside the band, as "Alex called No Set" does
### players/controller/_header
- `players/controller/_header`: header with dot, name and score, on Waiting and Game over
### players/controller/_board_strip
- `players/controller/_board_strip`: the play card grid with the deck line, sized by the card size rule in portrait and landscape
### players/controller/_button_ring
- `players/controller/_button_ring`: thin ring around the round SET! button
### players/controller/_small_ring
- `players/controller/_small_ring`: countdown ring with seconds, any size
### players/controller/_secondary_action
- `players/controller/_secondary_action`: the pill under SET!: No Set, the End game vote, or during a No Set countdown I agree, no Set (filled purple) or the waiting text (outlined purple). v4 variants:
  - refusal pair, while the player may refuse: two equal pills side by side, There's a Set on the left (outlined, 2px `purple-400` border, no fill, white bold text), I agree, no Set on the right (filled `purple-700`, white text). The pair fills its column: portrait the status slot's width (351px at 375, 8px gap, 16px labels), landscape the 9rem column (two 69×44 pills, 6px gap, 13px labels on two lines), computer 248×46 (two 120px pills, 8px gap, 15px labels). SET! does not move. Once this board's refusal is used, the lone I agree, no Set sits as before (220×44 in portrait, centered)
  - blocked No Set, after a refusal: the No Set pill at its usual size (portrait 220×44, landscape 144×44, computer 248×46), disabled, `purple-700` at 35% with `purple-200` text, "No Set in 12 s" with the seconds in display type. The block's seconds show only here, not in the status panel
  - disabled No Set while someone else claims (v6): the same look as blocked No Set, "No Set", in both themes (Shared: Rules added in v6). Light: `purple-100` with `purple-700` text
### players/controller/_submit
- `players/controller/_submit` (v5): the Submit pill in the pill slot during the player's own claim, at the slot's usual size (portrait 220×44, landscape 144×44, computer 248×46), body font 16px/700 (15px in landscape). States:
  - disabled, fewer than 3 picks: `blue-600` at 35% with `blue-200` text, "Submit"
  - enabled, exactly 3 picks: `blue-600`, white text, "Submit", glow `0 0 24px rgba(37, 99, 235, 0.55)` (SET!'s glow without the 8px ring)
  - submitted, from the tap until the resolving broadcast: `blue-600`, white text, disabled, an inline check icon (18px, stroke 3) then "Submitted", `aria-label` "Submitted, waiting for the result". Full strength, not the disabled look, so a frozen screen reads as sent, not as not yet allowed
### players/controller/_scoreboard
- `players/controller/_scoreboard` (v2): the play scoreboard, every player in score order. Portrait: chips, 4 per row, at most 2 rows, the Locked tag a red badge on the chip's top-right corner. Landscape and computer: one row per player, the Locked tag inline before the score. Own entry `gray-800` with a `gray-500` border; claiming entry solid `yellow-400` with `gray-950` text; locked entry content at 45% opacity
### players/controller/_status_panel
- `players/controller/_status_panel` (v2): one fixed slot above SET!, portrait 64px tall, landscape 144×104, computer 248×76. Variants:
  - claim bar: `yellow-400`, ring, "Your SET!", "Tap 3 cards", n/3
  - someone else claiming: `gray-900` with a `yellow-400` border, "Alex is calling SET!"
  - No Set: `purple-950` with a `purple-500` border, ring, "No Set called by Alex", "n/m agreed"
  - locked out: `red-950` with a `red-600` border, "Wrong! −1" or "Time's up! −1", `animate-shake`
  - refused (v4): `gray-900` with a `purple-500` border, laid out as someone else claiming in each layout: the refuser's dot, the name bold and "says there's a Set" in `gray-300`. No ring. `gray-900`, not `purple-950`, so it does not read as a call still running
  - idle: empty, the slot keeps its size
### players/controller/_found_banner
- `players/controller/_found_banner` (v2): `green-950` panel with a `green-500` border, the 3 cards small, the caller's dot, "Alex found a Set" and "+1" in `green-400`. Absolutely positioned over the top of the board area, over the scoreboard in portrait. `pointer-events: none`, `.found-set-flash`
### players/controller/_roster
- `players/controller/_roster` (v2): the Waiting roster, two columns, each a dot, the name, "you" for the player and a `green-400` ✓ once ready
### players/controller/_invite
- `players/controller/_invite` (v2): the room code in display type, "or open onset.joaotorr.es and enter the code" (`join_host`), the link button (Copy link, Copied ✓, Couldn't copy, Share link), a Show QR button and the "Show on a big screen →" text link
### players/controller/_qr_sheet
- `players/controller/_qr_sheet` (v2): overlay `gray-950` at 85%. Portrait: a bottom sheet. Landscape: a centered card, QR on the left, code and Done on the right. Computer: a centered 352px modal. QR on a white tile, 288px in portrait and computer, 300px in landscape, the code under it, Done in `blue-600`
### players/controller/_standings
- `players/controller/_standings` (v2): game over rows, each rank, dot, truncated name, "you" for the player, score. Own row `gray-800` with a `gray-600` border, other rows transparent. Rows 32px portrait, 34px landscape, 44px computer (computer list in a `gray-900` panel)
### Landing mode toggle
- Landing mode toggle (v2): two radios styled as a segmented control inside the Start a game form, on a `gray-950` (desktop) or `gray-900` (phone) track with a `gray-700` border. Selected Standard `gray-700`, selected First to 5 `violet-600`, unselected `gray-400` text on transparent. Light (v6): the segmented control rows of Shared: Themes (v6); First to 5 stays `violet-600`
### layouts/_byline_footer
- `layouts/_byline_footer` (v3): "by joaotorr.es" after `main` on the landing, How to play and the join page, never on the big screen or player screen. `gray-400` 14px weight 500 with a 1px red underline; on hover or keyboard focus the dot hops and the domain fades into the logo colours (`--wm-*`), held until the next page load. Styles in `app/assets/tailwind/application.css` (`.byline`, `.wm-*`), fixed across joaotorr.es apps
### Settings button
- Settings button (v6): an icon button, `aria-label="Settings"`, `aria-expanded` true while the menu is open, the Lucide gear icon (stroke 2). Closed: transparent, icon in secondary text. Open: the raised fill, icon in primary text. In the `layouts/_settings` partial, which each page's own view renders, outside every broadcast target. Two sizes:
  - Pages (landing, join page, How to play) and the big screen: 44×44, radius 12, 1px subtle border, 20px icon. Big screen: 56×56, radius 16, 26px icon
  - Player screen: 40×28 (40×32 in the computer Waiting and Game over footers), radius 8, no border, 16px icon (18px on computer), icon in muted text. It sits in the "Room CODE" footer row, outside `#controller_status`, at the row's right end, and adds no height
  - Where it sits on each screen: Screens below
### Settings menu
- Settings menu (v6): a popover, 304×278, radius 16, panel fill, strong border, menu shadow, 16px padding, 14px gaps, `role="dialog"`, `aria-label="Settings"`. No overlay and no dimming. With its button in the `layouts/_settings` partial, which each page's own view renders, outside every broadcast target. Top to bottom:
  - "Settings" (17px/700) with a close button on the right (36×36, × icon, `aria-label="Close settings"`)
  - Fieldset "Theme": legend 12px/600 uppercase, 0.08em tracking, secondary text. A segmented control like the landing mode toggle (track, strong border, radius 14, 4px padding and gap) of three 56px segments, each an 18px icon over a 12px/600 label: Match device (a half-filled circle), Light (a sun), Dark (a moon)
  - Fieldset "Card colors": the same control with two segments, Classic and Color-blind, each a 54×16 chip on the card face (`#FAFAFA`) over a 13px/600 label. Classic shows three 9px dots in the Classic red, green and purple; Color-blind shows the three color marks in blue, orange and magenta
  - Each option is a radio. The current choice is the selected segment (dark `gray-700`, light `gray-800`, white text), its radio checked. Keyboard focus: a 2px `blue-500` outline, offset 2px, on the focused segment (board `s-play-p-picked-light`)
  - Placement: it opens away from its button, right-aligned to it, 8px from it, 12px on the big screen (`mb-3`, 108px from the bottom over the 96px-high corner button, as Screens > Settings button placement gives): below a top-right button (landing, join page, How to play), above a footer or corner button (Screens below). It covers SET! and part of the board while open on the player screen
### Stimulus controllers
- Stimulus: `card-selection` (picks sent to the server, tray, count, Submit and the freeze after it), `countdown` (rings and seconds), `settings` (v6: the settings button and menu, writes the `theme` and `card_colors` cookies)

## Screens

Drawn for v2. Sizes are the boards': portrait 375×667, landscape 667×375, computer 1024×640, landing desktop 1280×800. v6 adds a light board of each screen beside the dark ones, Classic cards unless the board says Color-blind, and the settings button on every screen; the page boards with the byline footer are 375×727 and 1280×860.

### Settings button placement (tickets 40, 41)

- Landing: top-right, phone 20px from the top and 16px from the right, desktop 28px and 32px
- Join page: top-right, 16px and 16px
- How to play: in the nav row, after the "Onset" wordmark, 12px gap
- Player screen, portrait: in the "Room CODE" footer, 8px from the right edge, in every state; the menu opens 8px from the right and 46px from the bottom
- Player screen, landscape: play, on the Room line at the foot of the scores column (that line becomes a 28px row); Waiting, on the Room line under the invite; Game over, on the Room line under Play again
- Player screen, computer: play, at the right end of the Room footer under the deck line, on the board column's right edge; the menu opens with its right edge there, 46px from the bottom. Waiting and Game over: 40px from the right of the 32px footer; the menu opens 40px from the right and 48px from the bottom
- Big screen: 56×56, bottom-right, 40px in from both edges, under the rail; the menu opens 40px from the right and 108px from the bottom

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
- Light (v6): selected swatch a `gray-900` ring offset by `gray-50`; taken swatches blended over `gray-50` with the initial in `gray-700` (Shared: Themes (v6))

### How to play (tickets 39, 40, 41)

- First drawn in v6, as the code renders it, in the 944px content box with prose at 65ch that ticket 39 built (SPEC §8 Views & UX, Width): phone and desktop, light and dark (`l-htp-p`, `s-htp-p-dark`, `HowToPlayTh`, `d-htp-d`)
- Top to bottom: the nav row ("← Back", the "Onset" wordmark, the settings button), the header, Every card has four features (four panels), What makes a Set (two green-ringed panels), Almost, but not a Set (a red-ringed panel, then Quick check and Tip on blue tints), Playing Onset (four numbered panels, then No Set on the table? and End of the game), Ready to play?, the byline footer
- Color captions and the Not a Set row name the card colors of the current setting (Shared: Rules added in v6); `cb-htp-d-dark` and `cb-htp-d-light` draw the Color-blind words

### Big screen (tickets 21, 40)

- Drawn in light for every state (`l-big-*`, `BigScreenTh`), and in dark for waiting and ended (`d-big-waiting4`, `d-big-waiting1`, `d-big-ended`), which had no dark board before v6
- The room tile, the player pills and the QR tile get the light inset edge; band panels follow the light tinted panel rows; the podium ★ is `yellow-700` in light

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
- Claiming (mine): portrait, the claim bar takes the status slot and the 3-slot tray and Submit replace SET! and its pill. Landscape and computer: one yellow block replaces the panel and SET!, and Submit takes the pill slot (v5)
- Portrait tray (v5): a 128px row of three 72×101 slots, 14px apart, above the 44px pill slot holding Submit, 4px between, 176px in all, the height SET! and its pill take, so nothing else moves. An empty slot is a dashed `gray-700` box with its number (1, 2, 3) centred in display type, 22px/700, in muted text (dark `#7C8390` since v7, light `gray-500`); a filled slot shows the picked card. Slots fill in pick order
- Submitted (v5): the board's cards are disabled, the three picks keep the selected ring, the tray and the n/3 count stay as at 3/3, the countdown ring keeps draining and Submit shows its submitted state. The board never dims, at 3 picks or after the tap
- Someone else claiming: the disabled SET! shows the seconds large with a small "SET!" label under them, inside the yellow ring
- Read-only boards (someone else claiming, No Set, locked out) are not dimmed
- No Set countdown, may refuse (v4): the No Set status panel, SET!, and the refusal pair in the pill slot. Locked out at the same time: the No Set panel keeps the status slot, since the call is the news; SET! shows the lockout ring with the seconds and "Locked", as in Locked out, and the chip shows the Locked tag
- No Set blocked after a refusal (v4): idle with the refused status panel and the blocked No Set pill; SET! stays round blue and enabled
- Found-set banner: in portrait it covers the scoreboard for its 3s; the board under it shows the replaced cards with the arrive outline

### Player screen, Game over (ticket 07)

- Header, the rank in display type (64px portrait, 60px landscape, 120px computer), "of N players · P points" in `gray-400`, the winner line, the standings, Play again (`green-700`) or "Ready ✓ · waiting for n more" as on Waiting
- Landscape: rank, winner line and Play again in a 250px left column, the standings on the right
- Computer: a 360px left column, the standings in a `gray-900` panel on the right
- The standings scroll inside themselves when they do not fit; the page never does

### Static error pages (ticket 42)

- The five pages in `public/` (400, 404, 406 unsupported browser, 422, 500) keep the Rails scaffold's layout, sizes, font, header graphic and messages; only their colors change, to Onset's in each theme. No settings menu, no byline footer, no link, no wordmark (SPEC §10 Themes). Boards: `err-404-p-dark`, `err-404-p-light` (phone 375×667), `err-500-d-dark`, `err-500-d-light` (computer 1280×800, the line break after the first sentence shown); 400, 406 and 422 take the same values
- Layout as the scaffold: one column centred in the viewport (`min-height: 100dvh`), text centred, 2em padding, 1em gaps; the header graphic at most 12em wide (SVG, viewBox 480×172); one paragraph at most 30em wide at 75% of the body size, its first sentence bold; body the system sans stack at `clamp(1rem, 2.5vw, 2rem)`, line height 1.4
- The scaffold's one text color splits in two: the bold first sentence in primary, the rest of the paragraph in body

| Part | Dark | Light |
|---|---|---|
| Page | `gray-950` | `gray-50` |
| Bold first sentence | `gray-50`, 19.27:1 | `gray-900`, 16.98:1 |
| Rest of the paragraph | `gray-300`, 13.66:1 | `gray-700`, 9.86:1 |
| Numerals (the status code in the SVG) | `gray-800`, 1.37:1 | `gray-200`, 1.18:1 |
| Status name (in the SVG) | `red-400`, 7.28:1 on the page, 5.31:1 over the numerals | `red-700`, 6.19:1 on the page, 5.23:1 over the numerals |
| `theme-color` | `#030712` | `#F9FAFB` |

- The numerals take the subtle border role of each theme, as faint as the scaffold's (1.36:1, 1.14:1): a backdrop graphic under the status name, not text. The red status name and the paragraph carry the message, and the page title and the SVG's label name the code. SPEC §10 Themes exempts them from the 4.5:1 text rule (triage 42)

## Known gaps

None

## Open questions

- The dark Locked out boards (`-wrong`, `-timeup`) still draw the 5-second ring, though lockout is 15 s since ticket 20. The v6 light boards draw it at 15 s (12 s left). Redraw the dark ones in the next brief that touches lockout
- Answered by triage 40, then by v7: dark muted text (`gray-500`, 4.16:1 on `gray-950`, 3.67:1 on `gray-900`) and the dark field border at rest (`gray-700`, 1.72:1 on `gray-900`) stayed as built in ticket 40; ticket 46's design pass raises them to `muted` `#7C8390` and `gray-500` (Shared: Themes (v6), Shared: Rules added in v7)
- Answered by triage 42 in SPEC §10 Themes: the static error pages' status code numerals (1.37:1 dark, 1.18:1 light) are a backdrop graphic, not text, so the 4.5:1 text rule does not reach them; the status name, the page title and the graphic's accessible name carry the code
- Answered by triage 41 in SPEC §10 Palette: the Color-blind blue and orange stay at 2.91:1 against the card face, below 3:1 for graphics, as IBM sets them; the color marks keep them apart by form
- Answered by triage 40: the light field border at rest is `gray-500` (4.84:1 on white), not the boards' `gray-400` (Shared: Themes (v6))
- Answered by triage 40: the player screen settings button stays 40×28 (40×32 in the computer Waiting and Game over footers), above the WCAG 2.2 AA 24px minimum; the footer does not grow, so the board keeps its size
- A 20-character name at 1280px wide pushes a big screen headline (No Set, claiming) to three lines and out of the 9rem band. The design tool recommends truncating the name with an ellipsis so the headline stays within two lines. Triage 21 took it for the Refused headline in SPEC §8; the No Set and claiming headlines wait for a request of their own
- Answered by triage 07 in SPEC §8 Player screen > 8. Game over: a tied rank stays a plain "1st", and the winner line reads "★ You win with 7" when the viewer wins, as the code already does. Redraw the -win boards to match in the next brief that touches game over

---

## Changelog

- v7, 2026-11-19: ticket 42, the static error pages in Onset's dark and light: page, the bold first sentence in primary and the rest in body, faint numerals in the subtle border shade and the status name in the red text shade, layout and messages as the scaffold has them (Screens > Static error pages), with boards of 404 on a phone and 500 on a computer in both themes.
- v7, 2026-11-19: ticket 46, dark contrast: the new `muted` token `#7C8390` for dark muted text and placeholders (5.28:1 on `gray-950`, 4.65:1 on `gray-900`), kept a step below secondary; the dark field border at rest `gray-500`; the player screen settings icon following muted; disabled labels and non-field borders as built (Shared: Themes (v6), Shared: Rules added in v7), on the `DarkSheet` board.
- v6, 2026-11-17: ticket 53, the records corrected to the build, nothing new designed: `.byline-footer` holds the dark logo colours in the dark theme and the light ones under the light theme, How to play's 944px box is built, the settings menu opens 12px from the big screen's corner button, and the quoted SPEC §10 Palette matches SPEC again.
- v6, 2026-11-15: ticket 49, the records corrected to the build, nothing new designed: the settings button and menu sit in the `layouts/_settings` partial each page's own view renders, the menu measures 304×278, and on the player screen it opens 46px from the bottom in portrait and computer play, 48px in the computer Waiting and Game over footers.
- v6, 2026-11-15: ticket 40, a light theme and the settings menu: the light value of every surface, border, text and meaning color (Shared: Themes (v6)), the card wrapper's edge and inset panel edges in light, the settings button on every screen and the settings menu with its Theme option, light boards of every screen, the readable disabled No Set pills in both themes.
- v6, 2026-11-15: ticket 41, card colors: the Classic red, green and purple as the default card palette, the Color-blind palette with the color mark in `cards/_card`, the Card colors option in the settings menu, and Color-blind boards of every place a card renders in both themes.
- v5, 2026-10-25: ticket 37, Submit for a claim: `_submit` in the pill slot in every layout (disabled below 3 picks, enabled at 3, submitted after the tap), the portrait tray resized to fit it, the submitted state of the claiming screen and the disabled filled pill rule.
- v4, 2026-10-16: ticket 21, refusing a No Set call: the refusal pill pair and the blocked No Set pill in `_secondary_action`, the refused `_status_panel` variant, the Refused `_announcement` panel, the lockout ring on SET! during a No Set countdown, and the first big screen board.
- v3, 2026-10-16: ticket 24, the byline footer `_byline_footer` and the `--wm-*` logo colours, taken from the cross-app byline brief as built in d7f1cc8, not from a design pass.
- v2, 2026-10-12: ticket 07, game over standings on the player screen in portrait, landscape and computer: `_standings`, own row `gray-800`, Play again on `green-700`.
- v2, 2026-10-12: ticket 08, devices-first landing (mode toggle, one Start a game, phone order) and the join page with the creator's big screen link, field and base errors, and taken swatches blended over `gray-950`.
- v2, 2026-10-12: ticket 09, the player screen during play stands alone in portrait, landscape and a new computer layout: `_scoreboard`, `_status_panel`, `_found_banner`, the card size rule with no landscape sideways scroll, the 128px SET! slot, filled purple pills on `purple-700`.
- v2, 2026-10-12: ticket 10, the waiting invite on every player screen: `_roster`, `_invite`, `_qr_sheet`, I'm ready on `green-700`, neutral Copy link feedback.
- v1, 2026-10-12: taken from the code and SPEC §10 as built at deploy-20261011-1849.
