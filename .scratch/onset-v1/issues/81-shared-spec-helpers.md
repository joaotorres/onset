# 81: Behind the scenes: one home for the repeated spec helpers

Status: split
Kind: behavioural
Blocked by:
Priority: low
Feature: Themes
Model:
Effort:
Changelog:
Split: yes

## Request

Deferred from 64. Behind the scenes: one home for the spec helpers that the theme, rate limit, claim and player specs each wrote again. Theme: `light!` is defined identically in `spec/support/system/{big_screen_theme,card_colors,player_screen_theme}.rb` and again in `spec/system/settings_menu/light_values_spec.rb`, beside `theme!` (`dark_contrast/landing_and_join_spec.rb`), `visit_with_cookie` (`static_error_pages.rb`), `set_cookie` (`settings_menu/other_tab_spec.rb`), `theme_cookie!` and `colorblind!`, all writing the same two cookies; `rgb` twice (`card_colors.rb`, `static_error_pages.rb`); the theme-color meta readers under four names (`meta_theme_color` in two files, `meta_in_effect`, `metas`, `theme_colors`); the no-reload marker under three (`__noReload`, `notReloaded`, `sameDocument`); and the generic `style`, `style_of`, `mix` and `color` helpers live in the "settings menu" context. Put one of each in a shared "theme" context. Rate limits: the `cache_store` stub is copied in `spec/requests/{in_game_rate_limits,players/create,games/create}_spec.rb`. Claims: `state`, `restart_with_known_board` and their contexts are the same in `spec/models/claim_spec.rb`, `spec/jobs/expire_claim_job_spec.rb` and `spec/requests/claims_spec.rb`. Players: specs build players with literal preset colors in about 30 files, which ticket 54 had to edit one by one and the bot tickets will again; add one helper that creates a player with the room's next free preset and use it wherever the color is not the point. No example's assertions change.

## Comments

Decided: no spec change, because only specs and spec support change and nothing a user would notice; CLAUDE.md, Testing covers where specs live. Instead of: a SPEC note on the shared helpers.

Decided: Priority low, because it moves test helpers and changes no behaviour. Instead of: normal.

Decided: Feature Themes, ticket 64's, because the request is its deferral and the theme helpers are the largest part. Instead of: a new feature name for test helpers.

Decided: split into 84 (the shared "theme" context: driver, styles, cookies, theme-color metas, no-reload marker), 85 (the rate limit stub and the stale claim helpers) and 86 (the player helper with the room's next free preset, about 40 spec files), no blocking edges, published without waiting for approval, because the theme helpers span about 17 files and the player builds about 40, more than one fresh session holds, and each part is independent and green on its own. Instead of: one ticket, or the rate limit and claim helpers folded into 86.

No conflict: no spec change. Tickets 77, 78, 79, 80, 62 and 68 to 70 edit or add specs in the same files; none contradicts this request, and whichever builds later keeps the others' helpers and checks green (77, 78 and 79 already say so).

Split into 84, 85, 86.
