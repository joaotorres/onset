Design return for tickets 40, 41.

## New tokens

Light theme. Each value is one CSS value per theme, keyed on `<html>`, on the same markup. Ratios are WCAG contrast on the value's own ground, the page (`gray-50` #F9FAFB) unless stated. Dark values are the existing ones.

Surfaces and borders

| Role | Dark | Light | Light ratio |
|---|---|---|---|
| Page | gray-950 #030712 | gray-50 #F9FAFB | ground |
| Panel | gray-900 #111827 | white #FFFFFF; a dark panel with no border gets `inset 0 0 0 1px` gray-200 #E5E7EB | ground |
| Raised, bordered (Join, Copy link, Show QR, own scoreboard chip) | gray-800 #1F2937, border gray-700 | gray-100 #F3F4F6, border gray-300 #D1D5DB | gray-900 text 16.12:1 |
| Raised, borderless (SET! while unavailable, Join with a room code) | gray-800 #1F2937 | gray-200 #E5E7EB | gray-800 text 11.85:1 |
| Border, strong (toggle tracks, settings menu, QR sheet) | gray-700 #374151 | gray-300 #D1D5DB | decorative |
| Border, subtle (panel borders, header rule, dividers, settings button) | gray-800 #1F2937 | gray-200 #E5E7EB | decorative |
| Field border at rest | gray-700 #374151 (1.72:1 on gray-900) | gray-400 #9CA3AF | 2.54:1 on white |
| Field border with an error | red-500 #EF4444 | red-600 #DC2626 | 4.62:1 |
| Input fill | gray-950 (desktop) / gray-900 (phone) | white #FFFFFF | ground |

Text

| Role | Dark | Light | Light ratio |
|---|---|---|---|
| Primary | gray-50 #F9FAFB (white on the big screen), 19.27:1 | gray-900 #111827 | 16.98:1 page, 17.74:1 white |
| gray-200 values (host name, How to play values, tip text) | #E5E7EB, 16.25:1 | gray-800 #1F2937 | 14.05:1 |
| gray-300 body (tagline, sub-lines, captions, "is calling SET!") | #D1D5DB, 13.66:1 | gray-700 #374151 | 9.86:1 page, 10.31:1 white |
| Secondary gray-400 (labels, deck line, "you", byline) | #9CA3AF, 7.93:1 | gray-600 #4B5563 | 7.23:1 page, 7.56:1 white |
| Muted gray-500 (Room CODE footer, empty band, tray slot numbers, settings icon on the player screen) | #6B7280, 4.16:1 | gray-500 #6B7280 | 4.63:1 page, 4.84:1 white; never on gray-100 (4.40:1) |

Meaning colors as fills with white text: the same in both themes. blue-600 #2563EB 5.17:1, violet-600 #7C3AED 5.70:1, purple-700 #7E22CE 6.98:1, red-600 #DC2626 4.83:1, green-700 #15803D 5.02:1, orange-700 #C2410C 5.18:1. The claim fill yellow-400 #FACC15 with gray-950 text, 13.15:1, also unchanged.

Meaning colors as tinted panels (light: a 50 tint, a 600 border or ring, text in 700 or 800)

| Panel | Dark | Light |
|---|---|---|
| Someone else claiming | gray-900, 2px yellow-400 | white, 2px yellow-500 #EAB308 |
| No Set status panel | purple-950 #3B0764, purple-500 #A855F7, sub purple-200 | purple-50 #FAF5FF, purple-600 #9333EA, sub purple-800 #6B21A8 8.13:1, title gray-900 16.53:1 |
| Refused status panel | gray-900, purple-500, gray-300 text | white, purple-600, gray-700 text 10.31:1 |
| Locked out | red-950 #450A0A, red-600, red-200 text | red-50 #FEF2F2, red-600, red-700 #B91C1C 5.92:1 |
| Found-set banner | green-950 #052E16, green-500, +1 green-400 | green-50 #F0FDF4, green-600 #16A34A, +1 green-700 4.79:1 |
| Ready ✓ waiting | green-700 at 12%, green-700 border, green-300 text | green-50 #F0FDF4, green-700 border, green-800 #166534 6.81:1 |
| Base error box | red-950, red-700 border, red-200 | red-50, red-600 border, red-800 #991B1B 7.60:1 |
| Band, Claiming | yellow-400 10%, 2px yellow-400 ring, name and seconds yellow-400 | yellow-50 #FEFCE8, yellow-500 ring, name and seconds yellow-800 #854D0E 6.62:1 |
| Band, No Set and Refused | purple-500 10%, purple-500 ring, name purple-400, seconds purple-300 | purple-50, purple-600 ring, name purple-700 6.51:1, seconds purple-800 8.13:1 |
| Band, Correct | green-500 10%, green-500 ring, green-400 | green-50, green-600 ring, green-700 4.79:1 |
| Band, Wrong / Time's up | red-500 10%, red-500 ring, red-400 | red-50, red-600 ring, red-700 5.92:1 |
| Big screen Locked pill | red-500 15%, red-400 | red-100 #FEE2E2, red-700 5.30:1 |
| Big screen Deck is empty pill | orange-500 15%, ring orange-500/40, orange-400 | orange-50 #FFF7ED, ring orange-600/45, orange-800 #9A3412 6.88:1 |
| How to play rings and rows | green-500/40, red-500/40 with a red-500 10% row, blue-500 10% panels with blue-500/40, purple-800 ring | green-600/45, red-600/45 with a red-50 row, blue-50 #EFF6FF panels with blue-600/35, purple-300 #D8B4FE ring |

Meaning colors as text

| Role | Dark | Light | Light ratio |
|---|---|---|---|
| Green (✓, all the same, Right: +1) | green-400 #4ADE80 | green-700 #15803D | 4.80:1 |
| Red (field errors, ✗, Wrong) | red-400 #F87171 (red-300, red-200 in the Not a Set row) | red-700 #B91C1C (label), red-800 #991B1B (value) | 6.19:1, 7.60:1 on red-50 |
| Links and step numbers | blue-300 #93C5FD, blue-400 #60A5FA | blue-700 #1D4ED8 | 6.41:1 |
| Purple titles and band names | purple-300 #D8B4FE, purple-400 #C084FC | purple-700 #7E22CE | 6.68:1 |
| Locked label under SET! | red-300 #FCA5A5 on gray-800 | red-700 on gray-200 | 5.22:1 |
| Podium ★ | yellow-400 #FACC15 | yellow-700 #A16207 | 4.70:1 |

Disabled, rings and outlines, other

| Role | Dark | Light | Light ratio |
|---|---|---|---|
| Disabled filled pill (v5 rule) | purple-700 35% + purple-200; blue-600 35% + blue-200 | purple-100 #F3E8FF + purple-700 #7E22CE; blue-100 #DBEAFE + blue-700 #1D4ED8 | 5.92:1; 5.49:1 |
| Disabled gray button (Start game with 1 player, Join when full) | gray-800 + gray-500 | gray-200 #E5E7EB + gray-600 #4B5563 | 6.10:1 |
| Countdown progress | yellow-400, red-500, purple-400 | yellow-600 #CA8A04 (2.81:1, the seconds inside carry the count), red-600 #DC2626 4.62:1, purple-600 #9333EA 5.15:1 | |
| Countdown track | gray-800 (phone), gray-700 (big screen) | gray-300 #D1D5DB | decorative |
| Focus outline, 2px, offset 2px | blue-500 #3B82F6, 5.47:1 | blue-500 #3B82F6 | 3.52:1 page, 3.68:1 white |
| Selected card ring, 4px | blue-400 #60A5FA | blue-500 #3B82F6 | 3.52:1 |
| Arrive outline, 3px | green-400 #4ADE80 | green-600 #16A34A | 3.15:1 |
| Card wrapper edge | none | `0 0 0 1px #D1D5DB, 0 1px 3px rgba(3, 7, 18, 0.12)` | 1.41:1 against the face; the card's contents carry it |
| Overlay behind the QR sheet | gray-950 at 85% | gray-950 at 45%; the sheet is white with a gray-300 top border | |
| Segmented control, selected (landing mode toggle, settings menu) | gray-700 #374151 + white | gray-800 #1F2937 + white | 14.68:1 |
| Segmented control, unselected text | gray-400 | gray-600 #4B5563 | 7.56:1 on white |
| Segmented track | gray-950 on a panel, gray-900 on the page | gray-100 #F3F4F6 on a panel, white on the page | |
| Join swatch, selected | 3px gray-950 gap, 3px white ring | 3px gray-50 gap, 3px gray-900 ring | |
| Join swatch, taken | preset 30% over gray-950, initial gray-300 | preset 30% over gray-50 (e.g. #E74C3C → #F4C6C2), initial gray-700 | 6.7:1 or more on every preset |
| QR tile | white, dark modules | the same, plus the 1px gray-200 inset edge | |
| Byline at rest | gray-400 7.93:1, 1px underline #FF4F5E 6.26:1 | gray-600 #4B5563 7.23:1, underline #C60B1E 5.79:1 | |
| Shadows | cards rgba(0, 0, 0, 0.55); banner and menu rgba(0, 0, 0, 0.6) | cards rgba(3, 7, 18, 0.16); banner 0.12; menu 0.18 | |
| `theme-color` | #030712 | #F9FAFB | |

Card colors. Card color 0, 1, 2. Ratios against the #FAFAFA face; shapes are graphics, so 3:1 is the bar.

| Palette | Color 0 | Color 1 | Color 2 |
|---|---|---|---|
| Classic (default) | red #C1121F, 5.96:1 | green #198A1E, 4.28:1 | purple #5E2CA5, 8.45:1 |
| Color-blind (unchanged) | blue #648FFF, 2.91:1 | orange #FE6100, 2.91:1 | magenta #DC267F, 4.35:1 |

The Classic shades are darker than the player presets and apart in hue: red #C1121F (hue 356°, 41% lightness) against #E74C3C (6°, 57%) and #E91E63 (340°, 52%); green #198A1E (123°, 32%) against #2ECC71 (145°, 49%) and #8BC34A (88°, 53%); purple #5E2CA5 (265°, 41%) against #9B59B6 (283°, 53%). Luminance ratios between each Classic shade and its nearest preset: 1.63, 2.13, 1.89. The three Classic shades are the same in both themes.

## New components

- **Settings button.** An icon button, `aria-label="Settings"`, `aria-expanded` true while the menu is open, the Lucide gear icon (stroke 2). Closed: transparent, icon in secondary text. Open: the raised fill, icon in primary text. Two sizes:
  - Pages (landing, join page, How to play) and the big screen: 44×44, radius 12, 1px subtle border, 20px icon. Landing top-right (phone 20px from the top and 16px from the right; desktop 28 and 32). Join page top-right, 16 and 16. How to play: in the nav row, after the "Onset" wordmark, 12px gap. Big screen: 56×56, radius 16, 26px icon, bottom-right corner 40px in from both edges, under the rail
  - Player screen: 40×28 (40×32 in the computer Waiting and Game over footers), radius 8, no border, 16px icon (18px on computer), muted gray-500. It sits in the "Room CODE" footer row, outside `#controller_status`, at the row's right end: portrait 8px from the screen edge in every state; landscape play on the Room line at the foot of the scores column (that line becomes a 28px row); landscape Waiting on the Room line under the invite; landscape Game over on the Room line under Play again; computer play on the Room footer under the deck line, at the right edge of the board column; computer Waiting and Game over 40px from the right of the 32px footer. It never moves SET!, the pill slot or the board, and adds no height
- **Settings menu.** A popover, 304×290, radius 16, panel fill, strong border, menu shadow, 16px padding, 14px gaps, `role="dialog"`, `aria-label="Settings"`. No overlay and no dimming. Top to bottom:
  - "Settings" (17px/700) with a close button on the right (36×36, × icon, `aria-label="Close settings"`)
  - Fieldset "Theme": legend 12px/600 uppercase, 0.08em tracking, secondary text. The landing mode toggle's segmented control (track, strong border, radius 14, 4px padding and gap), three 56px segments: Match device (a half-filled circle), Light (a sun), Dark (a moon), each an 18px icon over a 12px/600 label
  - Fieldset "Card colors": the same control with two segments, Classic and Color-blind, each a 54×16 chip on the card face (#FAFAFA) over a 13px/600 label. Classic shows three 9px dots in red, green and purple. Color-blind shows the three color marks in blue, orange and magenta
  - The current choice is the selected segment (gray-700 dark, gray-800 light, white text), with the radio checked. Keyboard focus is a 2px blue-500 outline offset 2px on the focused segment (board `s-play-p-picked-light`)
  - Placement: it opens away from its button, right-aligned to it, with an 8px gap: below a top-right button (landing, join page, How to play); above a footer or corner button (portrait 8px from the right, 36px from the bottom; computer with its right edge on the board column's right edge, 60px from the bottom; big screen 40px from the right, 108px from the bottom). It covers SET! and part of the board while open on the player screen. It is in the layout, outside every broadcast target
- **Color mark** (Color-blind only). One solid mark per card color, filled in the card's own color, no stroke, never shaded. It sits in the top-left corner and again, turned 180°, in the bottom-right, like a playing card's index, so it reads as a corner label rather than a shape or a count. Each mark fits a 28-unit box in the 200×280 viewBox, centred at (22, 20) and at (178, 260): in the free bands above y 40 and below y 240, and clear of the shape stack (x 45 to 155). Points are given in units from the box centre, and the bottom-right copy negates them:
  - Color 0 (blue): a triangle, (0, −14) (14, 12) (−14, 12)
  - Color 1 (orange): a plus, arms 14 long and 9 thick
  - Color 2 (magenta): a five-point star, outer radius 15, inner 6.2, nudged 1.5 down: (0, −13.5) (3.64, −3.52) (14.27, −3.14) (5.9, 3.42) (8.82, 13.64) (0, 7.7) (−8.82, 13.64) (−5.9, 3.42) (−14.27, −3.14) (−3.64, −3.52)
  - At the smallest card (54×76) a mark is about 7.6px; at the big screen card (171×240) about 24px. The `_card` partial always renders the mark, and CSS hides it under Classic. The face, border, shapes and shading do not change
- **Card wrapper edge** (light only). On the card's wrapper, not inside the partial: the edge in New tokens, wherever a card sits on a light surface (board, tray, found-set banner, band, landing fan, How to play)

## New or changed rules

- Two themes, Dark and Light. The light boards change colors only, plus the card wrapper's edge: every element, size and position is the dark board's
- A dark panel with no border (big screen room tile and player pills, How to play panels, the QR tile) gets a 1px gray-200 inset edge in light (`box-shadow`, so nothing resizes). Panels that already have a border keep it, recoloured
- Light tinted panels use the 50 tint of their color, a 600 border or ring (yellow uses 500) and text in 700 or 800. Meaning fills with white text are the same in both themes
- Muted text (gray-500) sits only on the page or on white in light, never on gray-100
- The v5 disabled-pill rule in light: the 100 tint of the color as fill, its 700 as text, at full opacity
- The disabled No Set pill while someone else claims follows the v5 rule in both themes (purple-700 35% with purple-200 in dark). The old dark boards still draw it at 35% opacity
- Countdown rings in light: progress in the 600 shade, track gray-300. Seconds digits carry the count
- The segmented control's selected segment is gray-800 in light, so it reads on both the white and the gray-100 track
- Card colors: Classic is the default. Color-blind is the IBM palette plus the color mark. Words that name a card color follow the setting: How to play's Color captions ("red, green, purple" / "blue, orange, magenta") and the Not a Set row ("two red, one green" / "two blue, one orange")
- The settings button never moves SET!, the pill slot or the board, and adds no page scroll. On the player screen it lives in the "Room CODE" footer row
- Page boards carry the byline footer under a viewport-tall `main`: landing and join page at 375×727 (667 + 60) and 1280×860 (800 + 60)
- Computer play, as built: the "Room CODE" footer sits directly under the deck line, both centred on the board, and the settings button is at that footer's right end. Card size at 8/18 is still 106×148
- The new boards draw the lockout ring at 15 s (12 s left) and the winner line "★ Alex wins with 7"

## Decisions the spec does not cover

- A tap outside the open menu closes the menu and does nothing else: it does not press what it lands on, such as SET! under the portrait menu. A stray SET! costs a point. Instead of: the tap also reaching the control underneath
- The game carries on under an open menu. Broadcasts keep updating the board, scores and status panel, and the menu stays open (it is outside every broadcast target). On portrait it covers SET! until it is closed. Instead of: pausing the player, or closing the menu when a claim or No Set starts
- Each option group is a native radio group, so arrow keys move and pick in one step. Arrowing from Match device to Dark picks Light on the way, applies it, and sends `theme_changed` once per step. Instead of: arrows that only move focus, with Space or Enter to pick
- Escape or the close button returns focus to the settings button. A tap outside does not move focus
- With no cookie, Match device is the selected Theme segment. The menu does not say which theme the device resolved to: the page shows it
- The settings button is on the big screen, though nobody plays from it, so whoever set it up can change its theme from the laptop. It sits bottom-right, under the rail, at 56px

## Open questions

- Dark muted text gray-500 (#6B7280) on gray-950 measures 4.16:1 (3.67:1 on gray-900), below the 4.5:1 SPEC §10 states. Dark is unchanged in this round. Move the dark muted role to gray-400, or keep it?
- The Color-blind blue and orange measure 2.91:1 against the card face, below 3:1 for graphics. They are unchanged, as SPEC §10 fixes them; the color marks keep them apart by form
- Field borders at rest are below 3:1 in both themes (dark gray-700 1.72:1, light gray-400 2.54:1). Raise the light field border to gray-500 (4.84:1) and the dark one to match in a later pass?
- The player-screen settings button is 40×28, below the 44px touch height used elsewhere, because the 28px footer cannot grow without shrinking the board. It meets the WCAG 2.2 AA 24px minimum. Accept this, or give the board 16px back in portrait?
- How to play's code holds the page in `max-w-5xl` (1024px). The boards draw the 944px box from SPEC §8, which ticket 39 settled

## Artboards added or changed

None changed: every existing board is as it was. `project/canvas.json` gains the boards below and nine section titles (notes `t40-*` and `t41-*`), placed under the existing boards from y 11800. Files ending `Th.dc.html` are the themed components, with props for theme, palette, state and menu. Each one is also a board at its defaults (light, Classic).

Foundations
- `LightSheet.dc.html`: light theme sheet, every dark color beside its light counterpart with ratios
- `CardColorsSheet.dc.html`: card colors sheet. Classic and Color-blind as solid, striped and outline on dark and light grounds, the player presets beside the Classic shades, and the three color marks at 54×76 and 171×240

Settings menu
- `SettingsMenu.dc.html`: the menu component on its own, dark, Match device and Classic selected
- `s-landing-p-dark.dc.html`: landing, phone, dark, button closed
- `s-landing-p-dark-open.dc.html`: landing, phone, dark, menu open, Match device and Classic marked
- `s-landing-p-light-open.dc.html`: landing, phone, light, menu open
- `s-landing-d-dark.dc.html`: landing, desktop, dark, button closed
- `s-landing-d-dark-open.dc.html`: landing, desktop, dark, menu open, Match device and Classic marked
- `s-landing-d-light-open.dc.html`: landing, desktop, light, menu open
- `s-join-dark-open.dc.html`: join page, joiner, dark, menu open
- `s-join-light-open.dc.html`: join page, joiner, light, menu open
- `s-htp-p-dark.dc.html`: How to play, phone, dark, full page, button closed in the nav row
- `s-waiting-p-dark-open.dc.html`: player screen, Waiting, portrait 8, dark, menu open
- `s-waiting-p-light-open.dc.html`: player screen, Waiting, portrait 8, light, menu open
- `s-play-p-dark.dc.html`: play, portrait 8/18, idle, dark, button closed
- `s-play-p-dark-open.dc.html`: play, portrait 8/18, idle, dark, menu open
- `s-play-p-light-open.dc.html`: play, portrait 8/18, idle, light, menu open
- `s-play-p-picked-light.dc.html`: play, portrait, Light just picked by keyboard: the page already light, Light selected with the focus outline
- `s-play-p-picked-cb.dc.html`: play, portrait, dark, Color-blind just picked: the cards behind the menu carry their marks
- `s-gameover-p-dark.dc.html`: Game over, portrait, before voting, dark, button closed
- `s-play-l-dark.dc.html`: play, landscape, idle, dark, button closed
- `s-play-c-dark.dc.html`: play, computer, idle, dark, button closed
- `s-play-c-dark-open.dc.html`: play, computer, idle, dark, menu open
- `s-play-c-light-open.dc.html`: play, computer, idle, light, menu open
- `s-big-dark.dc.html`: big screen, playing, empty band, dark, button closed
- `s-big-dark-open.dc.html`: big screen, playing, dark, menu open
- `s-big-light-open.dc.html`: big screen, playing, light, menu open

Light theme, Classic cards
- `l-landing-p.dc.html`: landing, phone, Standard, byline
- `l-landing-p-notfound.dc.html`: landing, phone, Room not found
- `LandingTh.dc.html`: landing, desktop, Standard, byline
- `l-landing-d-quick.dc.html`: landing, desktop, First to 5
- `JoinTh.dc.html`: join page, joiner, byline
- `l-join-creator.dc.html`: join page, creator
- `l-join-taken.dc.html`: join page, name and color taken (field errors)
- `l-join-started.dc.html`: join page, game already started (base error)
- `l-join-full.dc.html`: join page, every color taken, "This room is full", Join disabled
- `l-htp-p.dc.html`: How to play, phone, light, full page
- `HowToPlayTh.dc.html`: How to play, desktop, light, full page
- `d-htp-d.dc.html`: How to play, desktop, dark, full page, Classic cards
- `WaitingTh.dc.html`: Waiting, portrait 8
- `l-waiting-p-voted.dc.html`: Waiting, portrait, voted, Copied ✓
- `l-waiting-p-qr.dc.html`: Waiting, portrait, Show QR open
- `l-waiting-l-8.dc.html`: Waiting, landscape 8
- `l-waiting-c-8.dc.html`: Waiting, computer 8
- `PlayPortraitTh.dc.html`: play, portrait 8/18, idle
- `l-play-p-deck-empty.dc.html`: portrait, idle, deck empty
- `l-play-p-claim3.dc.html`: portrait, claiming 3/3, Submit enabled
- `l-play-p-submitted.dc.html`: portrait, submitted
- `l-play-p-other.dc.html`: portrait, someone else claiming
- `l-play-p-refusal.dc.html`: portrait, No Set, may refuse
- `l-play-p-agreed.dc.html`: portrait, No Set, agreed
- `l-play-p-blocked.dc.html`: portrait, No Set blocked after a refusal
- `l-play-p-wrong.dc.html`: portrait, locked out, Wrong! (15 s ring)
- `l-play-p-found.dc.html`: portrait, found-set banner
- `l-play-p-arrive.dc.html`: portrait, cards just dealt (arrive outline)
- `PlayLandscapeTh.dc.html`: play, landscape, idle
- `l-play-l-claim3.dc.html`: landscape, claiming 3/3
- `l-play-l-other.dc.html`: landscape, someone else claiming
- `l-play-l-refusal.dc.html`: landscape, No Set, may refuse
- `l-play-l-wrong.dc.html`: landscape, locked out, Wrong!
- `l-play-l-found.dc.html`: landscape, found-set banner
- `PlayComputerTh.dc.html`: play, computer, idle
- `l-play-c-claim3.dc.html`: computer, claiming 3/3
- `l-play-c-other.dc.html`: computer, someone else claiming
- `l-play-c-refusal.dc.html`: computer, No Set, may refuse
- `l-play-c-wrong.dc.html`: computer, locked out, Wrong!
- `l-play-c-found.dc.html`: computer, found-set banner
- `GameOverTh.dc.html`: Game over, portrait, before voting
- `l-gameover-p-voted.dc.html`: Game over, portrait, voted
- `l-gameover-l.dc.html`: Game over, landscape, 2nd
- `l-gameover-c.dc.html`: Game over, computer, 2nd
- `l-big-waiting4.dc.html`: big screen, waiting, 4 players, 2 ready
- `l-big-waiting1.dc.html`: big screen, waiting, 1 player, Start game disabled
- `d-big-waiting4.dc.html`: big screen, dark, waiting, 4 players, 2 ready
- `d-big-waiting1.dc.html`: big screen, dark, waiting, 1 player
- `BigScreenTh.dc.html`: big screen, playing, empty band
- `l-big-claiming.dc.html`: big screen, Claiming band
- `l-big-noset.dc.html`: big screen, No Set band
- `l-big-refused.dc.html`: big screen, Refused band
- `l-big-correct.dc.html`: big screen, Correct band with its three cards
- `l-big-wrong.dc.html`: big screen, Wrong band
- `l-big-deck-empty.dc.html`: big screen, deck empty pill
- `l-big-ended.dc.html`: big screen, ended, podium
- `d-big-ended.dc.html`: big screen, dark, ended, podium

Color-blind card colors, both themes
- `cb-play-p-dark.dc.html`, `cb-play-p-light.dc.html`: portrait 8/18, idle
- `cb-play-p-claim2-dark.dc.html`, `cb-play-p-claim2-light.dc.html`: portrait, claiming 2/3, the tray
- `cb-play-p-found-dark.dc.html`, `cb-play-p-found-light.dc.html`: portrait, found-set banner
- `cb-play-c-dark.dc.html`, `cb-play-c-light.dc.html`: computer, idle
- `cb-big-correct-dark.dc.html`, `cb-big-correct-light.dc.html`: big screen, Correct band
- `cb-landing-d-dark.dc.html`, `cb-landing-d-light.dc.html`: landing desktop, the fanned cards
- `cb-landing-p-dark.dc.html`, `cb-landing-p-light.dc.html`: landing phone, the fanned cards
- `cb-htp-d-dark.dc.html`, `cb-htp-d-light.dc.html`: How to play desktop, full page: Color captions "blue, orange, magenta" and the Not a Set row "two blue, one orange"
