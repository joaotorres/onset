# 50: One source each for the card palette, the color marks and the theme colors

Status: ready-for-agent
Kind: behavioural
Blocked by: 53
Priority: low
Feature: Card colors
Model:
Effort:
Changelog:

## Request

Deferred from 41. Behind the scenes: one source each for the card palette, the color-mark shapes and the theme colors, so a change to one cannot leave a copy behind. The palette hex values live in `app/assets/tailwind/application.css` and again in the menu's chips in `layouts/_settings`; the color-mark polygon points in `cards/_card` and again in `layouts/_settings`; `THEME_COLORS` and the `theme-color` meta logic in `ThemesHelper` and again in `settings_controller.js`. Have the chips read the CSS custom properties and the marks come from one helper constant, pass the theme colors to the controller as a Stimulus value rendered from the helper, and in the same pass give `layouts/_settings` one `variant:` local with one map for its button, icon and menu classes in place of its three `player_screen`/`big_screen` cascades, and `settings_controller.js` one cookie-and-dataset writer for both picks.

## Spec references

No spec change: nothing a user sees or does changes. The headings that already cover it:

- SPEC.md, Shared: 10. Cards and visual system > Palette (both palettes, the color mark, "Never in a broadcast"), Component, Themes (the `theme` cookie, picking applies at once)
- SPEC.md, 8. Settings menu (Card colors, Picking, Opening it)
- SPEC.md, Shared: 7. Realtime > Hooks that must survive any markup change (Settings menu, `data-controller="settings"`)
- docs/design-system.md v6: Components > cards/_card, Settings button, Settings menu (Fieldset "Card colors" chips); Shared: Themes (v6) (`theme-color` values); Screens > Settings button placement

## Scope

- **Card palette, one source.** Each palette's three colors are written once, as CSS custom properties in `app/assets/tailwind/application.css`, one set per palette that does not switch with the pick (Classic 0, 1, 2 and Color-blind 0, 1, 2). The switching `--card-color-0..2` take their values from those, so the cards behave as now. The Card colors chips in `layouts/_settings` read the per-palette properties through `style` or classes (a `var()` in an SVG presentation attribute does not resolve), so each chip still shows its own option's colors whatever is picked. No card palette hex is left in any view, helper or script
- **Card face, the same flaw.** The near-white face `#FAFAFA` is in `_card` and again in the chips' background: one custom property, read by both, the face looking as now
- **Color marks, one source.** The three polygon point lists live in one Ruby constant on a helper, indexed by card color 0, 1, 2; `cards/_card` and the chips both read it. The chip markup otherwise stays as drawn (same sizes, viewBox, order)
- **Theme colors, one source.** `ThemesHelper::THEME_COLORS` stays the only place `#F9FAFB` and `#030712` are written for `theme-color`, and the helper owns the meta logic too: one method gives, for each choice (`device`, `light`, `dark`), the list of `theme-color` metas (content and media), which `theme_color_tags` renders and the layout's settings partial passes to the `settings` controller as a Stimulus value (JSON). The controller replaces the metas from that value on a theme pick and holds no color or media query of its own
- **One `variant:` local** on `layouts/_settings` (default for the landing, join page and How to play; `player_screen`; `big_screen`), with one map from variant to its button, icon and menu placement classes, in place of the three `if player_screen / elsif big_screen` cascades. The two callers that pass `player_screen: true` and `big_screen: true` pass the variant instead. Every class each variant renders today stays the same
- **One cookie-and-dataset writer** in `settings_controller.js`, used by both the theme and the card colors picks: given the cookie and dataset name, the value and the default, it deletes both for the default (Match device, Classic) and otherwise sets both, with the same cookie attributes as now (path `/`, a year, SameSite Lax)
- Must not touch: what any page looks like or does, the `_card` markup beyond its face and mark source (shapes, pattern ids, viewBox, the `card-c*`, `card-shape`, `card-ink` and `color-mark` classes), SPEC 7's hooks and Stimulus attributes on the settings partial, the events and their payloads, the cookies, `Card`'s color indices, `PlayersController::PRESET_COLORS`

## Acceptance criteria

- Under `app/`, each card palette hex (`#C1121F`, `#198A1E`, `#5E2CA5`, `#648FFF`, `#FE6100`, `#DC267F`) appears exactly once, in `application.css`; the color-mark point lists appear exactly once, in the helper constant; `#F9FAFB` and `#030712` as `theme-color` values appear only in `ThemesHelper` (the QR code color, the unrouted PWA manifest and `public/icon.svg` aside); `settings_controller.js` holds no hex value and no `prefers-color-scheme` string
- The Card colors chips show the Classic red, green and purple dots and the Color-blind blue, orange and magenta marks (computed colors) both when Classic and when Color-blind is picked, on a `#FAFAFA` face
- Each chip's three marks have the same points as a card of that color's marks
- Every card's computed colors, face and marks are as before under both palettes and both themes: the existing card colors specs pass unchanged
- After picking Light, Dark and Match device in the menu, the `theme-color` metas are the same as a page load with that cookie renders (the spec 53 adds for a pick in the menu passes)
- Picking each theme and each card colors option writes and deletes the `theme` and `card_colors` cookies and the `<html>` dataset exactly as before, and sends the same events once per change: the existing settings menu, theme and card colors specs pass unchanged
- The settings button and menu render the same classes on every screen: the existing menu offset, big screen menu and player screen menu specs pass unchanged

## Verification

`bin/test-all && bundle exec standardrb`

Tests first:

- A view or request spec: the settings menu's chips carry no hex color and read the per-palette custom properties; each chip mark's points equal the helper constant's for that color, as `_card`'s do; the `settings` controller element carries the theme-color value whose entries match `theme_color_tags` for each choice
- A system spec (headless Chrome): the chips' computed colors under Classic and under Color-blind both show each option's own palette
- Run the whole existing suite red-free before and after: it is the guard that nothing a user sees changed

## Out of scope

- The QR code's `030712` module color in `GamesHelper`, `public/icon.svg` and the unrouted PWA manifest (Decided below)
- Reading Tailwind's gray values into `THEME_COLORS`, or any change to the page backgrounds
- Escape anywhere (51), the theme on a link visit (52), the records and the other untested menu paths (53)
- Any change to the palettes, the marks, the menu's look or what a pick does

## Comments

Decided: no spec change, because the ticket moves copies of values into one place each and nothing a user sees or does changes; SPEC 10 Palette, Themes and 8 Settings menu already cover the behaviour. Instead of: a SPEC note on where the values live.

Decided: the palette gets one set of custom properties per palette that does not switch, and `--card-color-0..2` read from them, because the chips must show each option's own colors whatever is picked, so they cannot read the switching properties. Instead of: the chips keeping hex values, or reading `--card-color-*`.

Decided: the card face `#FAFAFA`, copied in `_card` and the chips, joins the scope as one custom property, because a fix covers the whole flaw (loop-rules 11) and the chip copies the card's face as it copies the palette. Instead of: leaving the face's two copies.

Decided: `ThemesHelper` also owns the meta logic (which metas, with which media query, for each choice), passed to the controller in its Stimulus value, because the request names the logic as copied too and passing only the colors would leave the media query and the device rule in both places. Instead of: a value holding only the two colors.

Decided: the QR code's `030712` in `GamesHelper`, `public/icon.svg` and `app/views/pwa/manifest.json.erb` stay as they are, because the QR color means dark modules on white (SPEC 10), the icon is a static file that cannot read a constant, and the manifest is neither routed nor linked. Instead of: pointing them at `THEME_COLORS`.

Decided: blocked by 53, because 53 adds the system spec for the `theme-color` meta after a pick in the menu, the path this ticket refactors and no spec covers today, so it is in place before the refactor. Instead of: writing that spec here too.

Decided: Priority low, Feature Card colors (the ticket it came from), Model left empty, because nothing a user notices changes and the work is view, CSS and a small controller refactor the existing suite guards. Instead of: normal, or Model: fable.

Decided: no split, because it is six mechanical moves across the CSS, two partials, two callers, one helper and one controller, guarded by existing specs, which fit one session. Instead of: splitting the palette, the theme colors and the partial's variant map.
