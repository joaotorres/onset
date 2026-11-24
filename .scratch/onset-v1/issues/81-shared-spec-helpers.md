# 81: Behind the scenes: one home for the repeated spec helpers

Status: needs-triage
Kind: behavioural
Blocked by:
Priority:
Feature:
Model:
Effort:
Changelog:

## Request

Deferred from 64. Behind the scenes: one home for the spec helpers that the theme, rate limit, claim and player specs each wrote again. Theme: `light!` is defined identically in `spec/support/system/{big_screen_theme,card_colors,player_screen_theme}.rb` and again in `spec/system/settings_menu/light_values_spec.rb`, beside `theme!` (`dark_contrast/landing_and_join_spec.rb`), `visit_with_cookie` (`static_error_pages.rb`), `set_cookie` (`settings_menu/other_tab_spec.rb`), `theme_cookie!` and `colorblind!`, all writing the same two cookies; `rgb` twice (`card_colors.rb`, `static_error_pages.rb`); the theme-color meta readers under four names (`meta_theme_color` in two files, `meta_in_effect`, `metas`, `theme_colors`); the no-reload marker under three (`__noReload`, `notReloaded`, `sameDocument`); and the generic `style`, `style_of`, `mix` and `color` helpers live in the "settings menu" context. Put one of each in a shared "theme" context. Rate limits: the `cache_store` stub is copied in `spec/requests/{in_game_rate_limits,players/create,games/create}_spec.rb`. Claims: `state`, `restart_with_known_board` and their contexts are the same in `spec/models/claim_spec.rb`, `spec/jobs/expire_claim_job_spec.rb` and `spec/requests/claims_spec.rb`. Players: specs build players with literal preset colors in about 30 files, which ticket 54 had to edit one by one and the bot tickets will again; add one helper that creates a player with the room's next free preset and use it wherever the color is not the point. No example's assertions change.

## Comments
