# 64: Cover ticket 46's remaining criteria and share theme spec helpers

Status: done
Kind: behavioural
Blocked by:
Priority: low
Feature: Themes
Model:
Effort:
Changelog: Behind the scenes: specs now cover the dark theme's disabled labels and borders and the light theme's muted text, and the theme spec helpers are shared.

## Request

Deferred from 46. Behind the scenes: cover the rest of ticket 46's criteria in the system specs and share the theme spec helpers. Test that the disabled Join and Start game labels compute to `gray-500` on `gray-800` in dark; that the mode toggle's track and the settings menu keep their `gray-700` borders in dark (only the landing Join button and the tray slot are checked today); and that in light the tray slot numbers, the "/N" of the No Set count and "No one yet" compute to `gray-500`. Move the shared helpers into `spec/support/system/`: `style_of(element, property)`, now copied in `spec/system/dark_contrast/big_screen_spec.rb` and `spec/system/big_screen_theme/light_values_spec.rb`, and one `theme_cookie!(value)` for the `theme` cookie `add_cookie` line repeated in `spec/support/system/{big_screen_theme,player_screen_theme,card_colors,static_error_pages}.rb`, `dark_contrast/landing_and_join_spec.rb`, `settings_menu/device_theme_spec.rb` (twice), `settings_menu/light_values_spec.rb` and `big_screen_theme/light_values_spec.rb`; rename `dark!` in `spec/support/system/dark_contrast.rb` to `dark_device!`, since the other `light!` helpers set the cookie, not the device.

## Spec references

No spec change. Specs only, for criteria already decided in:

- SPEC.md, Shared: 10. Cards and visual system > Visual system (the 4.5:1 text rule, disabled labels exempt; the 3:1 form field border rule; the `muted` token)
- SPEC.md, Shared: 10. Cards and visual system > Themes
- Ticket 46's Acceptance criteria and docs/design-system.md v7 Shared: Themes (v6)

## Scope

Specs and spec support only. No file under `app/`, `config/` or `public/` changes.

New examples, in the existing `spec/system/dark_contrast/` files (or a new file there when one would pass 8 s):

- Dark, the join page when the room is full (8 players): the disabled Join's `color` is `gray-500` and its `background-color` `gray-800` (`app/views/players/new.html.erb`)
- Dark, the big screen waiting with one player: the disabled Start game's `color` is `gray-500` and its `background-color` `gray-800` (`app/views/games/_start_button.html.erb`)
- Dark, the landing: the Game mode toggle's track (the `fieldset > div` around Standard and First to N) has a `gray-700` border-top-color
- Dark, any page with the settings menu open: the menu panel (`#settings_menu`) has a `gray-700` border-top-color
- Light, the player screen: an empty tray slot's number computes to `gray-500`
- Light, the big screen: the "/N" of the No Set count and "No one yet" compute to `gray-500`

Shared helpers, all in the `settings menu` shared context (`spec/support/system/settings_menu.rb`), which every theme context and spec already includes, beside `style` and `theme_cookie`:

- `style_of(element, property)`: the one definition; delete the copies in `spec/system/dark_contrast/big_screen_spec.rb` and `spec/system/big_screen_theme/light_values_spec.rb`
- `theme_cookie!(value)`: sets the `theme` cookie on path `/`. Every `add_cookie(name: "theme", ...)` line in `spec/` calls it instead: in `spec/support/system/big_screen_theme.rb`, `player_screen_theme.rb`, `card_colors.rb`, `static_error_pages.rb`, and in `spec/system/dark_contrast/landing_and_join_spec.rb`, `settings_menu/device_theme_spec.rb` (both), `settings_menu/light_values_spec.rb`, `big_screen_theme/light_values_spec.rb`. Also the three `set_cookie("theme", ...)` calls in `spec/system/settings_menu/other_tab_spec.rb`; its `set_cookie` stays for the `card_colors` cookie
- `mix(name, percent)`: the one definition; delete the identical copies in `spec/support/system/big_screen_theme.rb` and `player_screen_theme.rb`

Rename `dark!` in `spec/support/system/dark_contrast.rb` to `dark_device!`, and its four calls in `spec/system/dark_contrast/big_screen_spec.rb` and `player_screen_spec.rb`. The `light!` helpers keep their names and set the cookie through `theme_cookie!`.

Must not touch: any view, stylesheet or controller; the values the existing examples assert; ticket 63's changes to the static error pages' parts and checks (only the `add_cookie` line in `visit_with_cookie` changes here).

## Acceptance criteria

- In dark, the disabled Join label on a full room's join page and the disabled Start game label on a one-player big screen each compute `color` `gray-500` on a `gray-800` background, and a spec asserts it
- In dark, a spec asserts the landing's Game mode toggle track and the open settings menu panel have a `gray-700` border
- In light, a spec asserts an empty tray slot's number, the No Set count's "/N" and "No one yet" compute to `gray-500`
- `def style_of`, `def mix` and `add_cookie(name: "theme"` each appear once in `spec/`, in `spec/support/system/settings_menu.rb`, and no spec calls `set_cookie("theme"`
- `dark!` no longer exists in `spec/`; `dark_device!` emulates the device's dark setting where it was used
- The whole suite passes and no spec file runs over 8 s

## Verification

`bin/test-all && bundle exec standardrb`

Tests first: the new examples above, run against the current views (they pass at once, since the views are already right: this ticket covers built behaviour, so show each new example fails by asserting a wrong shade first, such as `gray-600`, then the right one). Then move the helpers and rerun the suite unchanged in outcome.

## Out of scope

- Any change to a color, a view or the stylesheet
- Collapsing the identical `light!` and `settings_button` one-liners across the theme contexts
- Moving the other `card_colors` cookie lines (`colorblind!`, `other_tab_spec.rb`'s `set_cookie("card_colors", ...)`) into a helper
- The `getComputedStyle` calls written inline in other specs (layout, standings, card colors)

## Comments

Decided: Priority low, because it adds specs and moves spec helpers for colors already built right, which no user notices. Instead of: normal.

Decided: Feature Themes, ticket 46's, because the specs cover its criteria. Instead of: a new feature name.

Decided: the shared helpers go in the `settings menu` shared context, beside its `style` and `theme_cookie`, because every theme context and spec that uses them already includes it. Instead of: a new support file or module.

Decided: the scope also covers `mix(name, percent)`, copied word for word in the big screen and player screen theme contexts, and the three `set_cookie("theme", ...)` calls in `other_tab_spec.rb`, because they are the same flaw, a theme spec helper copied instead of shared. Instead of: only the copies the request names.

Decided: the one-line `light!` and `settings_button` wrappers stay in each context, because the request keeps the `light!` helpers by name and each is one call once `theme_cookie!` exists. Instead of: collapsing them into the settings menu context too.

Decided: each new example is shown red by asserting a wrong shade first, because the views already compute the right values and a spec never seen failing proves nothing (loop-rules section 6). Instead of: no red step for specs of built behaviour.

No conflict: no spec change. Open ticket 63 also edits `spec/support/system/static_error_pages.rb` (its parts and checks); this ticket changes only the cookie line in `visit_with_cookie` there.

Decided: deep review 20261120-094918 leaves one spec that measures the wrong element, two untested criteria and the spec helpers written more than once for two follow-ups, because the built screens are right and neither changes what a user sees. Instead of: a pending decision.

Deferred: Behind the scenes: make the theme and fit specs measure what their criteria name. In `spec/system/dark_contrast/landing_and_join_spec.rb` the "Game mode toggle track" example reads `fieldset > div`, whose first match on the landing is the settings menu's Theme track (the menu renders before the form), so it passes whatever border the toggle has: scope it to the Game mode form, and check every other bare selector in the dark contrast, theme and fit specs for the same first-match slip, now that every page renders the settings menu first. In `spec/system/big_screen_fit/waiting_spec.rb`, assert the "Join from this computer" link on one line and no wider than its QR tile at every `FIT_SIZES` window, not only at 1280×800: at 1280×1024 the link is still 24px under a 288px tile, so shrink it there if the example is red. Check the join page's name field error border in light (`red-600`), which ticket 46's criterion names and only dark tests.

Deferred: Behind the scenes: one home for the spec helpers that the theme, rate limit, claim and player specs each wrote again. Theme: `light!` is defined identically in `spec/support/system/{big_screen_theme,card_colors,player_screen_theme}.rb` and again in `spec/system/settings_menu/light_values_spec.rb`, beside `theme!` (`dark_contrast/landing_and_join_spec.rb`), `visit_with_cookie` (`static_error_pages.rb`), `set_cookie` (`settings_menu/other_tab_spec.rb`), `theme_cookie!` and `colorblind!`, all writing the same two cookies; `rgb` twice (`card_colors.rb`, `static_error_pages.rb`); the theme-color meta readers under four names (`meta_theme_color` in two files, `meta_in_effect`, `metas`, `theme_colors`); the no-reload marker under three (`__noReload`, `notReloaded`, `sameDocument`); and the generic `style`, `style_of`, `mix` and `color` helpers live in the "settings menu" context. Put one of each in a shared "theme" context. Rate limits: the `cache_store` stub is copied in `spec/requests/{in_game_rate_limits,players/create,games/create}_spec.rb`. Claims: `state`, `restart_with_known_board` and their contexts are the same in `spec/models/claim_spec.rb`, `spec/jobs/expire_claim_job_spec.rb` and `spec/requests/claims_spec.rb`. Players: specs build players with literal preset colors in about 30 files, which ticket 54 had to edit one by one and the bot tickets will again; add one helper that creates a player with the room's next free preset and use it wherever the color is not the point. No example's assertions change.
