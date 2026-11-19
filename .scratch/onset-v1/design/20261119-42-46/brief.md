Canvas: https://claude.ai/artifact/123TNq7nwcKGoXDaroSGcM. Written against docs/design-system.md v6, 2026-11-17.

# Design brief: tickets 42, 46

## Context

Onset is a real-time multiplayer web version of the card game Set. Each player plays on their own player screen, a phone or a computer, and an optional big screen (a TV or laptop) shows the room to the whole table. Every page comes in two themes, Dark and Light, picked per browser in the settings menu, Match device by default.

This round is two foundations jobs. Ticket 42: the five static error pages (anyone who opens a bad link or hits a server error sees one) get Onset's own dark and light look instead of the generic Rails one. Ticket 46: in the dark theme, muted text, form placeholders and form field borders at rest are raised to the contrast the light theme already meets. Every player sees those, on every screen.

Glossary terms these screens show or touch:

- **Theme**: Dark or light, the colors every page is drawn in. Each browser picks Match device (the default), Light or Dark in the settings menu. (Avoid "mode": a game's mode is Standard or First to 5.)
- **Settings menu**: the menu on every page Onset renders, all but the static error pages, where a player chooses how Onset looks on their browser, such as the theme or the card colors.
- **Player screen**: one player's own view of a game, on a phone or a computer. **Big screen**: an optional shared display of a game. Never "phone", "controller" or "TV" for the screens.

## What to design

Five new boards. Change no other board.

| Board | Size | Ticket | What |
|---|---|---|---|
| `err-404-p-dark` | 375×667 | 42 | 404 page, phone, dark |
| `err-404-p-light` | 375×667 | 42 | 404 page, phone, light |
| `err-500-d-dark` | 1280×800 | 42 | 500 page, computer, dark |
| `err-500-d-light` | 1280×800 | 42 | 500 page, computer, light |
| `DarkSheet` | 1440 wide, as tall as it needs | 46 | the dark muted text, placeholder and field border shades, each on its real ground, with ratios |

Put the four error page boards in a new canvas section below the last one (section 9), titled "10 · Static error pages, dark and light (ticket 42)". Put `DarkSheet` in section 6, Foundations, to the right of `CardColorsSheet` (80px gap, same top as `LightSheet`), and widen that section's title to span it.

### 1. Static error pages (ticket 42)

One screen, five pages sharing one layout and differing only in their header graphic and message: 400, 404, 406 (unsupported browser), 422, 500. They have no other states: no loading, empty or error state, no links, no forms. Draw 404 on a phone and 500 on a computer, each in both themes; the other three pages take the same layout with their own words, so they need no boards.

What each page is today (the Rails scaffold), which stays except for its colors:

- The whole page is one centred column, vertically and horizontally centred in the viewport (`min-height: 100dvh`), text centred, 2em padding, 1em gaps
- A header graphic, at most 12em wide (an inline SVG, viewBox 480×172): the status code in very large heavy numerals drawn in a faint tone close to the page (light `#f0eff0` on `#FFF`, dark `#2c2c2c` on `#101010`), with the status name in smaller bold type across their middle, in red (light `#d30001`, dark `#FF6161`). The status name is the one in the page's title: "Not Found" for 404, "Internal Server Error" for 500, "Bad Request" for 400, "Not Acceptable" for 406, "Unprocessable Entity" for 422. The numerals and the name are SVG paths, not live text
- Under it, one paragraph at most 30em wide, at 75% of the body size, its first sentence bold
- Body font: the system sans stack (`ui-sans-serif, system-ui, -apple-system, …`), size `clamp(1rem, 2.5vw, 2rem)`, line height 1.4, weight 400. On a 375px phone that is 16px (paragraph 12px); at 1280px, 32px (paragraph 24px)
- Text today: light `#261B23` on `#FFF`, dark `#e0e0e0` on `#101010`

Messages, verbatim, unchanged (bold part in **bold**):

- 400: **The server cannot process the request due to a client error.** Please check the request and try again. If you're the application owner check the logs for more information.
- 404: **The page you were looking for doesn't exist.** You may have mistyped the address or the page may have moved. If you're the application owner check the logs for more information.
- 406: **Your browser is not supported.** Please upgrade your browser to continue. (a line break after the first sentence, shown from 768px wide)
- 422: **The change you wanted was rejected.** Maybe you tried to change something you didn't have access to. If you're the application owner check the logs for more information.
- 500: **We're sorry, but something went wrong.** If you're the application owner check the logs for more information. (a line break after the first sentence, shown from 768px wide, so the 1280 board shows two lines)

What to decide: the page ground, the paragraph text, the bold sentence, the faint numerals and the red status name, in each theme, from Onset's own values (Design rules below). The spec asks for Onset's surfaces and text shades, so the layout, sizes, font and graphic stay as the scaffold has them; anything beyond colors you want to propose goes under "Decisions the spec does not cover" in the return. Where a dark value is one ticket 46 changes (muted text), use the new value this same brief settles.

### 2. DarkSheet (ticket 46)

A sheet in the style of `LightSheet`: each role as a labelled swatch of real text or a real field on its real ground, with the WCAG contrast ratio written beside it. It settles three dark values and records the light ones next to them:

1. **Dark muted text.** Today `gray-500`: 4.16:1 on `gray-950`, 3.67:1 on `gray-900`. The new shade must reach 4.5:1 on every ground muted text sits on, listed below. `gray-400`, the dark secondary shade, is the first Tailwind gray to reach 4.5:1 on `gray-900`, so decide either how muted stays apart from secondary (a value between the two, which would be a new token outside the Tailwind palette) or that the two roles merge into one shade. Say which and why
2. **Dark placeholders** in the two form fields, the same 4.5:1, on the field's own fill
3. **Dark field border at rest** for the two form fields: 3:1 or more against the field's fill and against the surface around it. Today `gray-700`, 1.72:1 on `gray-900`

Draw each place muted text appears, on its ground, in dark with the new shade and in light with the current one (light muted is `gray-500`), so both themes' ratios show:

| Place | Size and type today | Ground (dark) |
|---|---|---|
| Player screen "Room CODE" footer, every state and layout | 12px body | page `gray-950` |
| Player screen tray slot numbers 1, 2, 3 (empty dashed slot, portrait claiming) | 22px/700 display | page `gray-950`, inside the dashed `gray-700` slot |
| Player screen settings button icon, closed (Lucide gear, 16px, 18px on computer) | an icon, not text | page `gray-950` |
| Big screen empty announcement band, "Spot a Set? Hit SET! on your screen." | 24px body | page `gray-950` |
| Big screen scoreboard "No one yet" | 24px body | page `gray-950` |
| Big screen scoreboard, a locked player's whole row (dot, name, score, with the red Locked tag) | 24px name, large display score | page `gray-950` |
| Big screen No Set band, the "/N" of the "n/N agreed" count | display bold, 60px | the band: `purple-500` at 10% over `gray-950`, `purple-500` ring |
| Join page hint under the colors, "Faded colors are taken. The letter shows by whom." | 14px body | page `gray-950` |
| Landing room code field placeholder "Room code" | 16px body, normal weight (the typed code is 22px display bold, uppercase) | field fill `gray-900` on phone, `gray-950` on desktop |
| Join page name field placeholder "Enter your name" | 20px body | field fill `gray-900` |

The settings button icon is a graphic, so the text rule does not reach it and 3:1 is its bar; `gray-500` already clears that. Decide whether it follows the new muted shade or keeps its own, and say so.

The field border contexts, each drawn as a real field at rest with its placeholder, in dark (new border) and light (`gray-500`, unchanged):

| Field | Fill | Surface around it |
|---|---|---|
| Landing room code field, phone | `gray-900` | page `gray-950` |
| Landing room code field, desktop | `gray-950` | the actions card, `gray-900` |
| Join page name field (phone layout at every width) | `gray-900` | page `gray-950` |

Light: fields are white, on the `gray-50` page or the white actions card. Show the error border (`red-500` dark, `red-600` light) beside the rest border for comparison; it does not change.

Not in scope, stay as built: the labels of disabled controls (Join when the room is full, Start game with one player: `gray-800` with `gray-500` text), and every `gray-700` border that is not a form field (the mode toggle's track, the Join, Copy link and Show QR buttons, the settings menu, the QR sheet, the empty tray slot's dashed border).

## Spec facts

From `SPEC.md`, quoted.

### For the static error pages

SPEC, Shared: 10. Cards and visual system > Themes:

> - **The static error pages** in `public/` (400, 404, 406 unsupported browser, 422, 500) are plain HTML files the layout never renders, so they carry the theme in their own inline CSS and script. They take Onset's own surfaces and text shades of each theme (the design pass draws them), not the generic Rails look they shipped with, which follows the device in colors of its own. With no `theme` cookie they follow the device through the media query, a device that states no preference getting dark, as on every other page. The cookie, when set, wins: a few lines of inline script in `<head>` read it before the first paint and set the theme on `<html>`, accepting only `light` or `dark`. With scripts off they follow the device. Their messages stay as they are, and they have no settings menu and no byline footer: they hold no Stimulus controllers

> **Dark** is the look every screen had before themes. **Light** puts dark text on light surfaces. Each browser picks one in the settings menu (§8, Settings menu): **Match device** (the default), **Light** or **Dark**. Match device follows the device's light or dark setting (`prefers-color-scheme`), live: switching the device's setting while a page is open switches the page with it. A device that states no preference gets dark.

SPEC, Shared: 8. Views & UX:

> Every page the app renders carries the settings menu (Settings menu below), all but the static error pages (§10, Themes).

SPEC, 8. Byline footer, Where:

> The big screen and the player screen have none: they are full-screen views with no page scroll. Static error pages and emails have none.

### For the dark contrast (and the error pages, which must meet it too)

SPEC, Shared: 10. Cards and visual system > Visual system:

> Surfaces, dark theme: page `gray-950`, panels `gray-900`, borders `gray-700`/`gray-800`. Secondary text `gray-400`. The light theme's surfaces, borders and text shades, and the dark muted text and field border shades, come from the design pass (`docs/design-system.md`). Both themes hold the same contrast:
>
> - **Text** at least 4.5:1 on its ground, the page or the panel it sits on, whatever its size: body, secondary and muted text alike (the "Room CODE" footer, the big screen's empty band text, "No one yet" and a locked player's entry on its scoreboard, the "/N" of a No Set vote count, the join page's hint under the colors, the tray slot numbers), and the placeholders in form fields, as the white-on-color rules in the meaning table below are. The labels of disabled controls are exempt, as WCAG makes them, and keep the disabled looks `docs/design-system.md` gives
> - **A form field's border at rest** at least 3:1 against the field's fill and against the surface around it, because a field sits on a surface close to its fill and its border is all that shows it. Today the room code field on the landing and the name field on the join page
>
> History: until ticket 46, dark muted text was `gray-500` (4.16:1 on `gray-950`, 3.67:1 on `gray-900`) and the dark field border at rest `gray-700` (1.72:1 on `gray-900`); ticket 40 left them so, since it kept dark as built, and deferred them to ticket 46.

> Two themes, dark and light, on every page the app renders (Themes below). In the dark theme the cards are the only bright surfaces. Tailwind default palette plus these tokens in `app/assets/tailwind/application.css`:

> Each color means one thing everywhere:
>
> | Color | Meaning |
> |---|---|
> | blue-600 | SET! and primary actions |
> | violet-600 | quick game |
> | yellow-400 | a claim in progress (big screen panel, scoreboard entries, player screen claim bar) |
> | purple | No Set. It used to be red; red now only means wrong or locked |
> | red | wrong claim, timeout, lockout |
> | green | ready, correct, start, play again (`green-700` for white text; `green-600` is only about 3.3:1) |
> | orange | deck empty and the End game vote (`orange-700` for white text; `orange-600` is only about 3.3:1) |

SPEC, Shared: 10 > Themes:

> - **The theme never reaches a broadcast.** Turbo Stream partials (§7) are rendered once for every screen in a room, so nothing in them depends on the viewer's theme: every themed color comes from CSS keyed on `<html>`, never from markup rendered per theme

SPEC, 8. Player screen:

> Full height, no page scroll. A strip of the player's color across the top, "Room CODE" footer.

SPEC, 8. Big screen (`/games/:code`):

> - **Scoreboard**: rows sorted by score, dot, name, big score. The claiming player's row turns solid yellow. A locked-out player is greyed with a red **Locked** tag.
> - **Announcement band**: always 9rem tall so the grid never jumps. Empty while playing: "Spot a Set? Hit SET! on your screen." Otherwise one tinted panel:
>   - No Set (purple): ring, "Alex called No Set", "Agree on your screen, or find one first", and "n/m agreed".

SPEC, 8. Landing (`/`):

> - **Have a room code?** field plus **Join**. `GET /join?code=` upcases the code and redirects to the room's join page, or back to the landing with "Room not found" under the field, which comes back empty with a red border.

SPEC, 8. Join page:

> **Your name** (max 20). **Pick a color**: a 4×2 grid of swatches that select with a ring and a white ✓, no JS: the ring white in the dark theme and `gray-900` in the light theme. Taken colors are faded with the taker's initial.

## Design rules

Quoted verbatim from `docs/design-system.md` v6.

### Shared: Themes (v6)

> Two themes, Dark and Light, each color one CSS value per theme keyed on `<html>`, on the same markup. Dark is every value this file gave before v6. Ratios are WCAG contrast on the value's own ground: the light page (`gray-50` `#F9FAFB`) unless stated. Every value is from the Tailwind default palette. The light theme sheet on the canvas (`LightSheet`) shows each pair.

> Surfaces and borders
>
> | Role | Dark | Light | Light ratio |
> |---|---|---|---|
> | Page | `gray-950` | `gray-50` `#F9FAFB` | ground |
> | Panel | `gray-900` | white; a panel with no border gets an `inset 0 0 0 1px` `gray-200` edge | ground |
> | Raised, bordered (Join, Copy link, Show QR) | `gray-800`, border `gray-700` | `gray-100`, border `gray-300` | `gray-900` text 16.12:1 |
> | Own scoreboard entry | `gray-800`, border `gray-500` | `gray-100`, border `gray-500` | |
> | Raised, borderless (SET! while unavailable, Join with a room code) | `gray-800` | `gray-200` | `gray-800` text 11.85:1 |
> | Border, strong (toggle tracks, settings menu, QR sheet) | `gray-700` | `gray-300` | decorative |
> | Border, subtle (panel borders, header rule, dividers, settings button) | `gray-800` | `gray-200` | decorative |
> | Field border at rest | `gray-700` | `gray-500` (triage 40; the boards draw `gray-400`, 2.54:1) | 4.84:1 on white |
> | Field border with an error | `red-500` | `red-600` | 4.62:1 |
> | Input fill | `gray-950` (desktop), `gray-900` (phone) | white | ground |
> | Empty tray slot border (dashed) | `gray-700` | `gray-400` | decorative |

> Text
>
> | Role | Dark | Light | Light ratio |
> |---|---|---|---|
> | Primary | `gray-50` (white on the big screen) | `gray-900` | 16.98:1, 17.74:1 on white |
> | Values (`gray-200`: host name, How to play values, tip text) | `gray-200` | `gray-800` | 14.05:1 |
> | Body (`gray-300`: tagline, sub-lines, captions, "is calling SET!") | `gray-300` | `gray-700` | 9.86:1, 10.31:1 on white |
> | Secondary (`gray-400`: labels, deck line, "you", byline) | `gray-400` | `gray-600` | 7.23:1, 7.56:1 on white |
> | Muted (`gray-500`: Room CODE footer, empty band, tray slot numbers, player screen settings icon) | `gray-500` | `gray-500` | 4.63:1, 4.84:1 on white; never on `gray-100` (4.40:1) |

> Meaning colors as tinted panels. Light: the 50 tint, a 600 border or ring (yellow uses 500), text in 700 or 800
>
> | Panel | Dark | Light |
> |---|---|---|
> | Base error box | `red-950`, `red-700` border, `red-200` | `red-50`, `red-600` border, `red-800` |
> | Band, No Set and Refused | `purple-500` 10%, `purple-500` ring, name `purple-400`, seconds `purple-300` | `purple-50`, `purple-600` ring, name `purple-700`, seconds `purple-800` |

> Meaning colors as text
>
> | Role | Dark | Light | Light ratio |
> |---|---|---|---|
> | Red (field errors, ✗, Wrong) | `red-400` (`red-300` label, `red-200` value in the Not a Set row) | `red-700` (label), `red-800` (value) | 6.19:1, 7.60:1 on `red-50` |

> Disabled, rings, outlines and the rest
>
> | Role | Dark | Light |
> |---|---|---|
> | Disabled gray button (Start game with 1 player, Join when full) | `gray-800` + `gray-500` | `gray-200` + `gray-600` (6.10:1) |
> | Focus outline, 2px, offset 2px | `blue-500` | `blue-500` (3.52:1, 3.68:1 on white) |
> | `theme-color` | `#030712` | `#F9FAFB` |

### Shared: Rules added in v6

> - Two themes, Dark and Light. A light screen changes colors only, plus the card wrapper's edge: every element, size and position is the dark screen's. Values in Shared: Themes (v6)
> - Muted text (`gray-500`) sits only on the page or on white in light, never on `gray-100`
> - The settings button never moves SET!, the pill slot or the board, and adds no page scroll. On the player screen it lives in the "Room CODE" footer row

### Shared: Visual rules (quoted from SPEC §10, Visual system)

> - `font-display`: Bricolage Grotesque (Google Fonts link in the layout). Only for display text: wordmark, room code, scores, SET!, headlines, countdown digits. Body copy stays on the default sans.

> `SPEC.md` §10 Themes also holds the `theme` cookie, the no-flash rule, `color-scheme` and the static error pages, which take both themes in Onset's own surfaces and text shades, not drawn yet (ticket 42).

### Components and screens

Settings button:

> - Player screen: 40×28 (40×32 in the computer Waiting and Game over footers), radius 8, no border, 16px icon (18px on computer), icon in muted text. It sits in the "Room CODE" footer row, outside `#controller_status`, at the row's right end, and adds no height

Player screen, during play:

> - Portrait tray (v5): a 128px row of three 72×101 slots, 14px apart, above the 44px pill slot holding Submit, 4px between, 176px in all, the height SET! and its pill take, so nothing else moves. An empty slot is a dashed `gray-700` box with its number (1, 2, 3) centred in display type, 22px/700, `gray-500`; a filled slot shows the picked card. Slots fill in pick order

Landing:

> - Desktop: brand on the left (wordmark 136px, tagline 24px `gray-300`, three fanned cards with the caption in `gray-400`), actions on the right in a 448px `gray-900` card with a `gray-800` border: the mode toggle, Start a game (`blue-600`, 60px, display type), its sub-line in `gray-400`, a divider, then "Have a room code?", the code field and a `gray-800` Join button
> - Room not found: "Room not found" in `red-400` under the code field, the field empty with a `red-500` border

Join page:

> - Field errors in `red-400` under their field, the field with a `red-500` border
> - Full room (every color taken, triage 08): "This room is full" in the base error box, no swatch selected, Join disabled as `gray-800` with `gray-500` text, as the big screen's disabled Start game. Wins over the join-full board, which shows no message

Open question this brief answers:

> - Answered by triage 40: dark muted text (`gray-500`, 4.16:1 on `gray-950`, 3.67:1 on `gray-900`) and the dark field border at rest (`gray-700`, 1.72:1 on `gray-900`) stay as built in ticket 40, which keeps dark as it is; raising them is ticket 46, whose SPEC §10 Visual system rule (triage 46) now holds every text, muted and placeholders included, to 4.5:1 and field borders at rest to 3:1, and waits for its design pass

## Boundaries

- Change no existing board. In particular, do not redraw the dark boards that show muted text or the form fields: ticket 46 changes three color roles and no layout, so the new shades live on `DarkSheet` and the design system, and the code is the truth for every built screen's layout. Do not edit `LightSheet`: record the light rows on `DarkSheet`
- The error pages change colors only. Their messages, layout, sizes, font and header graphic stay; no settings menu, no byline footer, no link, no wordmark
- Every value you pick is measured: write its ratio on the board. Prefer the Tailwind default palette; a value outside it is a new token and goes under "New tokens"

## Return

At the end of the work, give the return in exactly this format:

```
Design return for tickets 42, 46.

## New tokens
## New components
## New or changed rules
## Decisions the spec does not cover
## Open questions
## Artboards added or changed
```

Write `None` under a heading with nothing in it. Begin the return with the `Design return` line itself: no command such as `/request` or `/design-entry` before it, since a pasted command does not run.

## How every reply ends

```
End every reply with:

1. **Pending decisions:** what you need from me before going on, each
   a bullet with a bold title, explained so I can decide without opening
   anything else, its options numbered with your recommendation first.
   The numbers run on through all the decisions, never restarting, so I
   can answer with numbers alone ("1, 4"). `None` when there are none.
2. Only once the design is done: the line `Paste this into Claude
   Code:`, then the return alone, in the format above, in a fenced
   block of its own. Nothing after that block.
```
