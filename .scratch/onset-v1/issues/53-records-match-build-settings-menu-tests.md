# 53: Bring the records in line with what is built and cover the settings menu's untested paths

Status: ready-for-agent
Kind: behavioural
Blocked by:
Priority: low
Feature: Themes
Model:
Effort:
Changelog:

## Request

Deferred from 43. Behind the scenes: bring the records in line with what is built, and cover the settings menu's untested paths. DESIGN `docs/design-system.md` Tokens (byline logo colours) says the dark byline values on `.byline-footer` are "the values every Onset screen uses", false since the light theme (SPEC §10 byline colours); DESIGN How to play says "the code still holds `max-w-5xl`", stale since ticket 39; DESIGN Settings menu placement says the menu opens "8px from it", while Settings button placement and ticket 45 give 12px on the big screen. SPEC §10 Palette "Selected card ... `ring-blue-400`" leaves out the light theme's `ring-blue-500` (ticket 44, `card_selection_controller.js`), and SPEC §8 Join page "select with a white ring" leaves out the light theme's `gray-900` ring. GLOSSARY Settings menu says "the menu on every page", while SPEC §8 and §10 leave the static error pages out. System specs for: the `theme-color` meta after a pick in the menu (only page load is checked), an open menu closed when the page is cached on navigation (`turbo:before-cache`), and a filled tray slot taking and losing `card-edge`.

## Spec references

Reworded by this triage, to match the build:

- SPEC.md, Shared: 10. Cards and visual system > Palette (Selected card: the ring `blue-500` in the light theme)
- SPEC.md, 8. Join page (the selected swatch's ring white in dark, `gray-900` in light, the ✓ white)
- SPEC.md, 8. Settings menu (Closing it: leaving the page closes it, so Back or Forward shows it closed)
- GLOSSARY.md: Settings menu (every page Onset renders, all but the static error pages)

Already right, unchanged: SPEC.md, Shared: 8. Views & UX (the settings menu on every page but the static error pages), Shared: 10. Cards and visual system > Themes (the static error pages, `theme-color`), 8. Byline footer (Logo colours).

To correct in the build: docs/design-system.md v6, Shared: Tokens (byline logo colours), Shared: Visual rules > SPEC §10 > Palette (the quote), Components > Settings menu (Placement), Screens > How to play (tickets 39, 40, 41), Changelog.

## Scope

Records and specs only: the code is the truth here, and no file under `app/` changes.

- **DESIGN, Shared: Tokens, byline logo colours:** replace "dark on `.byline-footer`, the values every Onset screen uses" with wording that says `.byline-footer` holds the dark values in the dark theme and the light ones again under the light theme (`@variant light`), as `app/assets/tailwind/application.css` does, citing SPEC §8 Byline footer, Logo colours
- **DESIGN, Screens > How to play:** drop "the code still holds `max-w-5xl`"; the line says the 944px content box with prose at 65ch is the one ticket 39 built (SPEC §8 Views & UX, Width)
- **DESIGN, Components > Settings menu, Placement:** the menu opens 8px from its button, 12px on the big screen (`mb-3` in `layouts/_settings`, 108px from the bottom over the 96px-high corner button), matching Screens > Settings button placement
- **DESIGN, Shared: Visual rules > SPEC §10 > Palette:** the quote reads as SPEC §10 Palette now reads, word for word: the Selected card sentence this triage changed, and the "Picking applies at once" bullet triage 52 changed
- **DESIGN, Changelog:** one entry, `v6, <date>: ticket 53, ...`, saying the records were corrected to the build, with no version bump, as ticket 49's
- **System spec, the `theme-color` meta after a pick** (new file under `spec/system/settings_menu/`): on the landing, picking Light, Dark and Match device in the menu leaves in `<head>` exactly the `theme-color` metas (content and media) that `ThemesHelper#theme_color_tags` renders on a page load with that cookie: Light one `#F9FAFB`, Dark one `#030712`, Match device the `(prefers-color-scheme: light)` `#F9FAFB` and the plain `#030712`, so the one in effect follows the emulated device
- **System spec, the menu closed on the page cache** (new file under `spec/system/settings_menu/`): open the menu on the landing, follow the How to play link with the menu open (a Turbo visit, marked with a window flag as `picking_spec.rb` does), go back (`page.go_back`, a restoration from the cache): the landing shows the menu hidden, the shield hidden and the settings button `aria-expanded` false
- **System spec, the tray slot's card edge** (new file under `spec/system/player_screen_theme/`): on the portrait player screen in the light theme, during the player's own claim, picking a card gives its tray slot the `card-edge` class with the light edge (`0 0 0 1px #D1D5DB`, as `light_play_spec.rb` checks on the board) and no dashed border; unpicking it gives the slot back its dashed `gray-400` border and drops `card-edge`
- Must not touch: any file under `app/`, the canvas boards, SPEC sections beyond the three edits above

## Acceptance criteria

- DESIGN Shared: Tokens no longer says the dark byline values are the ones every Onset screen uses; it names both sets on `.byline-footer`, each in its theme
- DESIGN Screens > How to play no longer mentions `max-w-5xl`
- DESIGN Components > Settings menu gives 8px from the button and 12px on the big screen
- DESIGN's quoted SPEC §10 Palette reads word for word as SPEC §10 Palette does
- DESIGN's Changelog has the ticket 53 entry, and its title still reads version 6
- A system spec shows that after each pick in the menu the page's `theme-color` metas equal those a page load with that choice renders, and the meta in effect is `#F9FAFB` for Light, `#030712` for Dark, and the device's for Match device under both an emulated light and an emulated dark device
- A system spec shows that a menu left open when following a link is closed after Back, `aria-expanded` false, on a Turbo restoration rather than a full load
- A system spec shows that in the light theme a filled tray slot takes `card-edge` and the light edge, and loses both, with its dashed border back, when the card is unpicked
- Each new spec fails when the code path it covers is removed, and each new file runs under 8 s
- `git diff` of the build touches no file under `app/`

## Verification

`bin/test-all && bundle exec standardrb`

Tests first, the three system specs above. They cover code that already exists, so they are green against it: show each one red by removing, on disk only, the line it covers (the `applyThemeColor(theme)` call in `settings_controller.js`, the `turbo:before-cache@document->settings#dismiss` action in `layouts/_settings`, `FILLED_SLOT`'s `card-edge` in `card_selection_controller.js`), run it, then restore the file from `HEAD` with `git checkout -- <file>` before going on. Then the DESIGN edits.

## Out of scope

- Any change under `app/`: Escape on the document (51), the theme on a Turbo render (52), one source for the palette, marks and theme colors (50)
- Re-copying DESIGN's quoted SPEC §10 Component, Visual system and Themes, which are abridged on purpose with a pointer to SPEC
- Redrawing the canvas boards, or a DESIGN version bump
- Any other DESIGN, SPEC or glossary rewording beyond the items above

## Comments

Decided: triage rewords SPEC §10 Palette, §8 Join page and §8 Settings menu and the glossary's Settings menu now, and the build corrects DESIGN and writes the specs, because gate 1 wants the spec change committed before the brief, and DESIGN is the build's to correct as in ticket 49. Instead of: triage editing DESIGN too.

Decided: SPEC §8 Settings menu, Closing it, now says leaving the page closes the menu, so Back or Forward shows it closed, because the build does so (`turbo:before-cache`) and this ticket adds a spec for it, which needs a spec line to test against. Instead of: a test of behaviour the spec does not state.

Decided: SPEC §8 Views & UX and §10 Themes stay as they are, because they already leave the static error pages out of the settings menu; only the glossary drifted. Instead of: adding "not the static error pages" to §8 Settings menu too.

Decided: the build also re-copies DESIGN's quoted SPEC §10 Palette word for word, because the quote holds the Selected card sentence this triage changes and triage 52's "Picking applies at once" bullet, and a fix covers the whole flaw (loop-rules 11). Instead of: leaving the quote stale.

Decided: each new spec is shown red by removing the line it covers on disk and restoring it from `HEAD`, because the code already exists and a spec never seen red proves nothing (loop-rules 6, step 4). Instead of: a first green run recorded as a Decided line, as ticket 49 did.

Decided: Priority low, Feature Themes (ticket 43's), Model left empty, because no user notices a records fix or new specs. Instead of: normal.

Decided: no blocker on 50, 51 or 52, because this ticket changes no file under `app/`; 50 is blocked by this one for the `theme-color` spec. Instead of: waiting for 51 and 52, which change the partial's wrapper actions.
