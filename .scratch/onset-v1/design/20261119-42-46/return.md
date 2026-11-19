Design return for tickets 42, 46.

## New tokens

- `muted` `#7C8390`, dark only: dark muted text and dark form placeholders. On the gray hue, a third of the way from `gray-500` to `gray-400`, outside the Tailwind palette. 5.28:1 on `gray-950`, 4.88:1 on the No Set band (`purple-500` at 10% over `gray-950`, `#130F29`), 4.65:1 on `gray-900`; 3.85:1 on `gray-800`, so never there. Light muted stays `gray-500`. Ratios are measured on the hexes `docs/design-system.md` quotes (`gray-950` `#030712`, `gray-900` `#111827`).
  Kept apart from secondary instead of merged into `gray-400` (7.93:1): merged, the Room CODE footer, the empty band, "No one yet" and a locked player's row would be as loud as labels and the deck line. That would flatten the dark text ladder (primary 19.27, values 16.25, body 13.66, secondary 7.93, muted 5.28), and light keeps all five steps.

## New components

None

## New or changed rules

- Shared: Themes (v6), Text, Muted row: dark becomes `muted` `#7C8390` (was `gray-500`): 5.28:1 on `gray-950`, 4.65:1 on `gray-900`, 4.88:1 on the No Set band. Light unchanged: `gray-500`, 4.63:1 on `gray-50`, 4.84:1 on white, 4.51:1 on the light No Set band (`purple-50`), which is the light pair with the least room
- New text row, Placeholder: dark `muted` `#7C8390` (4.65:1 on the `gray-900` fill, 5.28:1 on the `gray-950` desktop fill), light `gray-500` (4.84:1 on white). Today's `placeholder:text-gray-500` / `placeholder-gray-500` in dark
- Surfaces and borders, Field border at rest: dark becomes `gray-500` (was `gray-700`): 3.67:1 against `gray-900`, 4.16:1 against `gray-950`, so it clears 3:1 against fill and surround in all three contexts (landing phone, landing desktop in the actions card, join page). Light stays `gray-500`. The row's note "the boards draw `gray-400`, 2.54:1" can go: DarkSheet records light as `gray-500` (4.84:1 on white, 4.63:1 on `gray-50`). `gray-600` is 2.34:1 on `gray-900`, so `gray-500` is the first Tailwind gray that clears it. Error borders unchanged
- The player screen settings button icon follows muted: dark `#7C8390`, 5.28:1 (its bar is 3:1 as a graphic). It sits beside "Room CODE" in the same footer row, so the row stays one shade
- A rule beside "Muted text (`gray-500`) sits only on the page or on white in light": dark muted sits on `gray-950`, `gray-900` (placeholders) or the No Set band, never on `gray-800` (3.85:1)
- Stays as built: disabled controls keep `gray-800` + `gray-500` (not `muted`), and every `gray-700` border that is not a form field stays `gray-700`
- Static error pages (ticket 42), both themes, colors only. Layout, sizes, font, header graphic and messages as the Rails scaffold has them:

  | Part | Dark | Light |
  |---|---|---|
  | Page | `gray-950` | `gray-50` |
  | Bold first sentence | `gray-50`, 19.27:1 | `gray-900`, 16.98:1 |
  | Rest of the paragraph | `gray-300`, 13.66:1 | `gray-700`, 9.86:1 |
  | Numerals (status code, SVG) | `gray-800`, 1.37:1 | `gray-200`, 1.18:1 |
  | Status name (SVG) | `red-400`, 7.28:1 on the page, 5.31:1 over the numerals | `red-700`, 6.19:1 on the page, 5.23:1 over the numerals |

  The numerals take the subtle border role in each theme (`gray-800` / `gray-200`), as faint as the scaffold's (1.36:1, 1.14:1). The status name takes the red text role. 400, 406 and 422 take the same values

## Decisions the spec does not cover

- The error pages' faint status code numerals are drawn as a backdrop, not as text, at 1.37:1 dark and 1.18:1 light, below SPEC §10's 4.5:1 for text. The brief keeps the scaffold's faint numerals. The red status name and the paragraph carry the message at 5.2:1 or more, and the page title and the SVG's label name the code. Triage: confirm SPEC §10 Themes treats them as decoration, or say they must reach 4.5:1, which would turn them into a visible second headline
- The error pages split the scaffold's single text color in two: the bold first sentence in primary, the rest in body. The scaffold showed the difference by weight only

## Open questions

None

## Artboards added or changed

- `project/DarkSheet.dc.html` (added, section 6 Foundations, right of `CardColorsSheet`, 1440×2900): the three settled dark values, the dark text ladder after the change, each muted place on its real ground (Room CODE footer, tray slot numbers, settings button icon, big screen empty band, "No one yet", a locked player's row, the No Set band's "/N", join hint, room code placeholder on phone and desktop, name placeholder), dark new beside light as built, and the three form fields at rest beside their error border, with ratios
- `project/err-404-p-dark.dc.html` (added, section 10): 404 Not Found, phone 375×667, dark
- `project/err-404-p-light.dc.html` (added, section 10): 404 Not Found, phone 375×667, light
- `project/err-500-d-dark.dc.html` (added, section 10): 500 Internal Server Error, computer 1280×800, dark, the line break after the first sentence shown
- `project/err-500-d-light.dc.html` (added, section 10): 500 Internal Server Error, computer 1280×800, light
- `project/canvas.json`: the five boards added, the section 6 title widened to 4480 and renamed to name the dark contrast sheet, a new section 10 title, and a sticky beside the error boards with their values and ratios. No existing board moved or changed
