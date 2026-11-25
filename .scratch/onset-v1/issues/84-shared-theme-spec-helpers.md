# 84: Behind the scenes: one shared "theme" context for the theme spec helpers

Status: deployed
Kind: behavioural
Blocked by:
Priority: low
Feature: Themes
Model:
Effort:
Changelog: Behind the scenes: the theme specs share one set of cookie, color, meta and no-reload helpers.

## Request

Split from 81 (one home for the repeated spec helpers): the theme part. `light!` is defined in `spec/support/system/{big_screen_theme,card_colors,player_screen_theme}.rb` and again in `spec/system/settings_menu/light_values_spec.rb`, beside `theme!`, `visit_with_cookie`, `set_cookie`, `theme_cookie!` and `colorblind!`, all writing the same two cookies; `rgb` twice; the theme-color meta readers under four names; the no-reload marker under three; and the generic `style`, `style_of`, `mix` and `color` helpers live in the "settings menu" context. Put one of each in a shared "theme" context. No example's assertions change. The rate limit and claim helpers are 85, the player helper 86.

## Spec references

No spec change: specs and spec support only, nothing a user would notice. The helpers check what these already decide:

- SPEC.md, Shared: 10. Cards and visual system > Themes and Palette (the `theme` and `card_colors` cookies, the `theme-color` metas)
- SPEC.md, 8. Settings menu
- CLAUDE.md, Testing (specs in `spec/`, `bin/test-all`, each file under 8 s)

## Scope

Spec support and system specs only.

1. **A shared "theme" context** in `spec/support/system/` holds the generic helpers, each defined once:
   - the headless Chrome driver, `emulate_color_scheme` and the `after` hook that puts the device back on light, moved from "settings menu"
   - `color`, `style`, `style_of`, `mix` and `page_background`
   - `rgb`, "#RRGGBB" to the computed "rgb(r, g, b)", usable where the static error pages build their constants at load time
   - one cookie writer (name, value, path "/"), with `theme_cookie!(value)`, `light!` and `colorblind!` as one-liners on it, and one cookie reader by name, with `theme_cookie` and `card_colors_cookie` on it; `delete_cookie` beside them
   - the theme-color metas: one reader for the list, each meta as [content, media] with media `nil` when the attribute is absent, and one for the content of the meta in effect (no media, or a media that matches)
   - the no-reload marker: one helper that marks the window and one that asserts the mark is still there
2. **"settings menu" includes "theme"** and keeps only the menu's own helpers (`open_settings`, `tap_on`, `record_tracks`, `tracks`). The "card colors", "big screen theme", "player screen theme" and "static error pages" contexts drop their copies and use the shared ones
3. **Every copy goes**: the `light!` definitions, `theme!` in the dark contrast landing and join spec, `visit_with_cookie`, the other tab spec's `set_cookie`, `delete_cookie`, `meta_theme_color` and marker helpers, `meta_theme_color` in the device theme spec, `metas` and `meta_in_effect` in the theme-color spec, `theme_colors` in the static error pages context, the `__noReload`, `notReloaded` and `sameDocument` markers in the settings menu, card colors, big screen theme and player screen theme specs. A spec that visits a page before writing the cookie calls `visit`, then the shared writer
4. **The static error pages' markup spec** reads the metas through the shared list reader: its `""` for a meta with no media becomes `nil`, the same claim (no media attribute) in the reader's form

Must not touch: anything under `app/`, `config/` or `public/`; what any example asserts beyond item 4's `""` to `nil`; selectors (ticket 80); the request spec's `theme_colors` in `spec/requests/themes_spec.rb`, which reads a response body, not the browser; the dark contrast context's `pseudo_style` and `token`, and file-local helpers built on `style` (`shadow`, `ring`, `card_edge`, `paint`, `color_scheme`).

## Acceptance criteria

- `add_cookie` appears once under `spec/`, in the shared "theme" context
- Under `spec/`, `def light!`, `def rgb`, `def style(`, `def style_of`, `def mix`, `def color(`, `def emulate_color_scheme`, a cookie reader by name and each theme-color meta reader are each defined once, in the shared "theme" context (the request spec's Nokogiri `theme_colors` aside)
- `theme!`, `visit_with_cookie`, `set_cookie`, `meta_theme_color`, `metas`, `meta_in_effect` and the system `theme_colors` are defined nowhere
- `__noReload`, `notReloaded` and `sameDocument` appear nowhere under `spec/`; one marker name appears only in the shared context
- The "settings menu" context defines no helper other than the menu's own (open the menu, tap, record and read tracks)
- The suite runs as many examples as before the change, and they pass
- No file outside `spec/` changes, and no spec file runs over 8 s

## Verification

`bin/test-all && bundle exec standardrb`

Tests first: this is a refactor with no new example. Run `bin/test-all` before any change and note the example count, then move the helpers one group at a time (driver and styles, cookies, metas, the marker), running the affected spec folders (`bundle exec rspec spec/system/settings_menu spec/system/card_colors spec/system/big_screen_theme spec/system/player_screen_theme spec/system/dark_contrast spec/system/static_error_pages`) after each, and finish with the Verification command and the same example count.

## Out of scope

- Moving the rate limit and claim helpers (85) or adding the player helper (86)
- Renaming or reshaping the "settings menu", "card colors", "big screen theme" or "player screen theme" contexts beyond dropping their copies
- A guard on `style` for selectors with several matches (ticket 80's Out of scope)
- Any new example or assertion

## Comments

Decided: the shared "theme" context holds the driver and the color scheme reset, and "settings menu" includes it, because every theme spec already gets both through "settings menu" and the generic helpers need the browser. Instead of: a plain module mixed into each context.

Decided: one cookie writer with `theme_cookie!`, `light!` and `colorblind!` on it, and the visiting variants (`theme!`, `visit_with_cookie`, the light values spec's `light!`) replaced by a visit plus the writer, because the visit is each example's own step and two `light!` that differ in a visit is how the copies drifted. Instead of: a second shared helper that visits first.

Decided: the theme-color list reader gives `nil` for a meta with no media, and the static error markup spec's `""` becomes `nil`, because `getAttribute` tells an absent attribute from an empty one and matches the request spec's reader. Instead of: `m.media`'s `""`, which would change the theme-color spec's `nil`.

Decided: the request spec's `theme_colors` stays, because it reads a response body with Nokogiri and a system context cannot serve it. Instead of: a shared reader for both.

Decided: the cookie reader, `delete_cookie` and `page_background` move too, because they are the same generic cookie and style helpers and the triage of a fix covers the whole flaw. Instead of: only the helpers the request names.

Decided: `rgb` lives in a `ThemeHelpers` module the "theme" context includes, with `ThemeHelpers.rgb` for the static error pages' load-time constants (that file requires `theme.rb` first, since support files load by name), because a shared context's methods do not exist at load time. Instead of: a second `rgb` on `StaticErrorPages`.

Decided: the "static error pages" context includes "theme" rather than "settings menu", and the back-from-another-site spec's `__restored` marker uses the shared `mark_window`/`expect_same_window` too, because neither needs the menu helpers and `__restored` is the same no-reload marker under a fourth name. Instead of: leaving both as they were.

Decided: `spec/system/realtime_sync/claim_spec.rb` and `game_over_spec.rb`, which `bin/test-all` names at 8.0 to 9.4 s, are left alone, because this ticket does not touch them and they ran near the limit before it. Instead of: splitting them here.
