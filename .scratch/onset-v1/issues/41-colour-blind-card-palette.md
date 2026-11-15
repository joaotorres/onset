# 41: Colour-blind friendly card palette, toggled in settings

Status: done
Kind: visual
Blocked by: 43, 44, 45
Priority: normal
Model:
Effort:
Changelog: Cards now come in Set's classic red, green and purple, and a Color-blind option in Settings switches them to blue, orange and magenta with a small mark in two corners that tells the colors apart.

## Request

Add a colour-blind friendly option for the cards, toggled from the settings menu that ticket 40 adds.

Settled in conversation:
- The option swaps the card colours to a colour-blind-safe palette and adds a shape or pattern cue beyond colour, so cards can be told apart without relying on colour alone.
- It also applies to the card diagrams on the How to play page.
- The setting is stored per device in the browser, like ticket 40's, not on `Player`.
- Stack stays Hotwire (Stimulus) and Tailwind only.

## Spec references

- SPEC.md, Shared: 10. Cards and visual system > Palette, Component, Themes (Same in both themes)
- SPEC.md, 8. Settings menu (Card colors, Picking, The current choice, Telemetry)
- SPEC.md, Shared: 7. Realtime > Hooks that must survive any markup change
- SPEC.md, Shared: 17. Telemetry > Custom events (`card_colors_changed`) and Privacy
- SPEC.md, 8. Landing (the fanned cards), 8. Big screen, 8. Player screen (board, tray, found-set banner)
- docs/design-system.md v6: Shared: Tokens (Card palettes), Shared: Rules added in v6 (Card colors), Components > cards/_card (Color mark), Settings menu (Fieldset "Card colors"), Stimulus controllers; Screens > How to play
- Boards (canvas in docs/design-handoff.md): CardColorsSheet, SettingsMenu, s-play-p-picked-cb, cb-play-p-dark, -light, cb-play-p-claim2-dark, -light, cb-play-p-found-dark, -light, cb-play-c-dark, -light, cb-landing-p-dark, -light, cb-landing-d-dark, -light, cb-big-correct-dark, -light, cb-htp-d-dark, -light; every other v6 board shows Classic cards
- GLOSSARY.md: Card colors, Color mark

## Scope

- **The two palettes**, card color 0, 1, 2: Classic red `#C1121F`, green `#198A1E`, purple `#5E2CA5` (the default) and Color-blind blue `#648FFF`, orange `#FE6100`, magenta `#DC267F`, as CSS custom properties in `app/assets/tailwind/application.css` keyed on `<html>`, the same in both themes. The `_card` partial stops writing hex values: its fills, strokes and the striped pattern's lines take the card's color from those properties (through `style` or classes, since a `var()` in an SVG presentation attribute does not resolve), so the markup is the same under both palettes and every viewer
- **The color mark** in `_card`, always in the markup and shown only under Color-blind: one solid mark in the card's own color, no stroke, top-left and again turned 180° bottom-right, at the points DESIGN v6 cards/_card gives (color 0 a triangle, 1 a plus, 2 a five-point star). Face, border, shapes, shading, the viewBox and every wrapper size stay as they are. Copies the `card-selection` controller makes for the tray keep the mark and fresh pattern ids
- **The `card_colors` cookie** (`colorblind`, path `/`, a year, SameSite Lax, not HttpOnly; Classic deletes it), read by the layout and rendered on `<html>` beside 43's theme, so the first paint has the right cards
- **The Card colors fieldset** in 43's settings menu, under Theme, as DESIGN v6 Settings menu draws it: Classic and Color-blind as native radios, each a chip on the card face (three Classic dots, three color marks), Classic checked with no cookie. The `settings` controller writes or deletes the cookie, applies the choice to `<html>` at once with no reload and the menu still open, and sends `card_colors_changed` with `card_colors` (`classic`, `colorblind`) when the pick differs from the current one, once per arrow-key step as the Theme radios do. The fieldset shows wherever the menu does: the landing, join page, How to play, the player screen and the big screen
- **Words that name a card color** on How to play: the three Color captions (red, green, purple / blue, orange, magenta) and the Not a Set row ("two red, one green" / "two blue, one orange"), both versions in the markup, CSS showing the one that matches, the hidden one hidden from screen readers too. The colour comment in `LobbiesHelper` names both palettes
- Must not touch: the card face `#FAFAFA` and border, the card wrapper edge and the light theme (43, 44, 45), `Card`'s color indices, `PlayersController::PRESET_COLORS`, the meaning colors, layouts, sizes, animations, SPEC 7's hook ids and Stimulus attributes

## Acceptance criteria

- With no `card_colors` cookie, a solid card of color 0, 1 and 2 paints its shapes `#C1121F`, `#198A1E` and `#5E2CA5` (computed style), on the landing's fanned cards, How to play, the big screen board and band, and the player screen board, tray and found-set banner; no color mark is displayed
- With `card_colors=colorblind`, the server-rendered `<html>` already carries the choice (the response body, before any script), the same cards paint `#648FFF`, `#FE6100` and `#DC267F`, and every card shows two color marks, a triangle on color 0, a plus on color 1 and a star on color 2, in the card's color
- Striped and outline cards follow the palette too: the hatch lines and the outlines take the card's color under both palettes
- The `_card` partial renders the same markup with and without the cookie, pattern ids aside (a request or partial spec), and a broadcast partial that holds cards (`#board`, `#controller_status`) renders the same HTML whatever the viewer's `card_colors` and `theme` cookies, pattern ids aside
- A card's computed colors and marks are the same under `theme=light` and `theme=dark`
- Every page's settings menu holds a Card colors group with the radios Classic and Color-blind under Theme; with no cookie Classic is checked
- Picking Color-blind sets `card_colors=colorblind` (a year, SameSite Lax, path `/`), every card on the page turns to the Color-blind palette with its marks, How to play's words switch, with no reload and the menu still open; picking Classic deletes the cookie and the cards turn back; a reload keeps the choice
- `card_colors_changed` carries `card_colors` `classic` or `colorblind`, through `window.jtTrack?.`, once per change; picking the option already chosen sends nothing
- How to play under Classic reads "red", "green", "purple" and "two red, one green"; under Color-blind "blue", "orange", "magenta" and "two blue, one orange"; the other version is neither visible nor in the accessibility tree
- A card copied into the portrait tray shows the palette in force and, under Color-blind, its marks
- Card sizes and every layout are unchanged: the existing layout and no-page-scroll specs pass unchanged

## Verification

`bin/test-all && bundle exec standardrb`

Tests first:

- A request spec: the layout renders `card_colors` on `<html>` for `card_colors=colorblind` and none, and `_card` markup does not depend on the cookie (pattern ids normalised)
- A view or partial spec: `_card` always holds the two color marks of its color, and no hex card color
- System specs (headless Chrome): computed fills under each palette on a board, How to play captions and the Not a Set row, the menu pick that switches cards live and writes and deletes the cookie, a reload keeping it, arrow-key picking, and `card_colors_changed` (stub `window.jtTrack` and read its calls, as the existing telemetry specs do)

## Out of scope

- Darkening the Color-blind blue and orange to 3:1 (Decided below)
- A color mark under Classic, or any other cue on Classic cards
- Card colors stored on `Player` or `Game`, or any request to the server when picking
- Naming card colors anywhere other than How to play's captions and Not a Set row
- The light theme, the card wrapper edge and the settings button and Theme option (43, 44, 45)

## Comments

Decided: the user chose on 2026-11-15 that the current IBM palette (blue, orange, magenta), already colour-blind safe, becomes the opt-in Color-blind option, and the default becomes a new, more distinct palette; SPEC 10 Palette now has two card palettes. Instead of: keeping the IBM palette as the default and only adding a colour cue, or a third palette for the option.

Decided: the default palette is Set's own red, green and purple, called Classic, because they are the most widely separated hues for normal vision and the colours every Set player already knows; their exact shades come from the design pass, kept apart from each other, the card face and the player presets' own red, green and purple. Instead of: another palette of three hues, which would still land near red, green and blue-purple and be one players do not recognise.

Decided: the default is named Classic, not Standard, because Standard already names a game mode (GLOSSARY). Instead of: Standard.

Decided: the player colour presets stay as they are and the Classic shades are picked apart from them, because changing presets would recolour players already stored in rooms and SPEC 16 already asks presets and card palette not to collide. Instead of: changing PRESET_COLORS.

Decided: the colour meanings table stays as it is and governs the UI, not card faces, because cards were always their own palette (SPEC 10 Palette) and a red card next to a red Wrong panel names a card feature, not a result. Instead of: moving meaning colours away from red, green and purple.

Decided: the Color-blind option also adds a color mark on every card, one per colour, drawn inside the SVG so sizes and layouts do not change, never altering shape, number or shading, its form left to the design pass, because the request settled a cue beyond colour and the answer on the palette did not take it back. Instead of: the IBM palette alone.

Decided: Card colors is a second option in the settings menu, Classic and Color-blind, Classic the default with no device preference to follow, because no browser setting states colour blindness. Instead of: an on/off switch, or following a device setting.

Decided: the choice is a `card_colors` cookie (`colorblind`, a year, SameSite Lax, deleted for Classic) the layout renders on `<html>`, card colours and the mark coming from CSS keyed on it and the mark always in the markup, because cards render in Turbo Stream partials shared by every screen (SPEC 7) and the theme cookie works the same way. Instead of: localStorage, or rendering cards per viewer.

Decided: the setting applies wherever a card renders, the landing's fanned cards included, and How to play's colour captions and its Not a Set example ("two red, one green") follow it through the same CSS, because a caption naming the wrong colour would teach the wrong card. Instead of: only boards and How to play diagrams.

Decided: each palette and the color mark are the same in both themes, because SPEC 10 Themes keeps the cards the same in both and the setting is independent of the theme. Instead of: palettes tuned per theme.

Decided: picking card colors sends `card_colors_changed` with `card_colors` (`classic`, `colorblind`), added to SPEC 17 Custom events, and the cookie joins `theme` in SPEC 17 Privacy as needing no consent, because CLAUDE.md asks for an event per new user-facing action. Instead of: no event.

Decided: GLOSSARY gains Card colors and Color mark, "pattern" avoided because shading already means solid, striped and outline. Instead of: calling it colour-blind mode.

Decided: no split for now, judged again after the design entry, as ticket 40's is, because the theme cookie mechanism and the settings menu come from 40 and the rest (palette tokens, one menu option, the mark, captions, one event) fits one session. Instead of: splitting now.

Waiting for the design pass: docs/design-system.md has no changelog entry for this ticket. The brief draws the Classic palette's shades, the color mark on each colour, the Card colors option in the settings menu, and every screen's cards under both palettes in both themes. Brief it with ticket 40, in one round: `/design-brief 40 41`.

Decided: brief 20261115-40-41 leaves every existing board as drawn and adds the light theme, settings menu and card colors boards beside them, because the light theme only recolours (SPEC 10 Themes keeps the layouts) and the brief describes as the truth what the code changed since the boards: the byline footer on the landing and join boards (tickets 24, 26), the narrow-desktop fanned cards (18), the computer "Room CODE" footer under the deck line (22), the 15 s lockout ring (20), the -win winner line (triage 07) and How to play's 944px box (39); the boards of tickets 21 and 37, still marked exploring in the handoff doc, are of deployed tickets and stay too. Instead of: redrawing the landing, join, computer play, locked out and game over boards from the code first.

Decided: the brief draws every new board in Classic, plus a Color-blind set in both themes for each place a card renders (player screen board, tray and found-set banner, big screen board and band, landing fanned cards, How to play diagrams and captions), and names the existing dark boards as Color-blind without the mark, because that shows every card surface under both palettes without drawing each screen four times. Instead of: every screen under both palettes in both themes.

Design question: the Color-blind blue `#648FFF` and orange `#FE6100` measure 2.91:1 against the `#FAFAFA` card face, below 3:1 for graphics. They are unchanged, as SPEC 10 Palette fixes them, and the color marks keep the colors apart by form. Keep them, or let a later pass darken them?

Decided: design entry v6 sets the Classic shades red `#C1121F`, green `#198A1E`, purple `#5E2CA5`, the color mark (a triangle, a plus and a star in the top-left corner and again turned in the bottom-right) and the Card colors option in the settings menu, and replaces the single card palette token, as this ticket asked. Instead of: asking first.

Decided: the Color-blind blue `#648FFF` and orange `#FE6100` stay at 2.91:1 on the card face, written into SPEC 10 Palette and the design system's open question marked answered, because the user chose the IBM palette as it is for the option, players already know it from every card before v6, and the color mark tells the three colors apart by form, not contrast. Instead of: darkening them to 3:1, which would change the palette the user picked.

Decided: no split, because 43, 44 and 45 build the theme mechanism, the settings menu and every screen's light theme, leaving this ticket CSS palette properties, the mark in one partial, one fieldset in an existing menu, the cookie beside the theme's, How to play's words and one event, which fit one session. Instead of: splitting by palette and menu.

Decided: the card's color comes from CSS custom properties through `style` or classes, not SVG presentation attributes, because `var()` does not resolve in a presentation attribute and SPEC 10 keeps the partial's markup the same for every viewer. Instead of: rendering hex values per viewer.

Decided: Priority normal and Model left empty, because it is a new option, not broken behaviour, and its code is view and CSS work a review checks at a glance. Instead of: high, or Model: fable.

Decided: deep review 20261115-142819 leaves the palette's copied values to a follow-up, because the review changes only Changelog lines and Deferred paragraphs. Instead of: refactoring in the review commit.

Deferred: Behind the scenes: one source each for the card palette, the color-mark shapes and the theme colors, so a change to one cannot leave a copy behind. The palette hex values live in `app/assets/tailwind/application.css` and again in the menu's chips in `layouts/_settings`; the color-mark polygon points in `cards/_card` and again in `layouts/_settings`; `THEME_COLORS` and the `theme-color` meta logic in `ThemesHelper` and again in `settings_controller.js`. Have the chips read the CSS custom properties and the marks come from one helper constant, pass the theme colors to the controller as a Stimulus value rendered from the helper, and in the same pass give `layouts/_settings` one `variant:` local with one map for its button, icon and menu classes in place of its three `player_screen`/`big_screen` cascades, and `settings_controller.js` one cookie-and-dataset writer for both picks.
