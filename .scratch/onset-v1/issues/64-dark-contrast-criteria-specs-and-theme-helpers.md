# 64: Cover ticket 46's remaining criteria and share theme spec helpers

Status: needs-triage
Kind: behavioural
Blocked by:
Priority:
Feature:
Model:
Effort:
Changelog:

## Request

Deferred from 46. Behind the scenes: cover the rest of ticket 46's criteria in the system specs and share the theme spec helpers. Test that the disabled Join and Start game labels compute to `gray-500` on `gray-800` in dark; that the mode toggle's track and the settings menu keep their `gray-700` borders in dark (only the landing Join button and the tray slot are checked today); and that in light the tray slot numbers, the "/N" of the No Set count and "No one yet" compute to `gray-500`. Move the shared helpers into `spec/support/system/`: `style_of(element, property)`, now copied in `spec/system/dark_contrast/big_screen_spec.rb` and `spec/system/big_screen_theme/light_values_spec.rb`, and one `theme_cookie!(value)` for the `theme` cookie `add_cookie` line repeated in `spec/support/system/{big_screen_theme,player_screen_theme,card_colors,static_error_pages}.rb`, `dark_contrast/landing_and_join_spec.rb`, `settings_menu/device_theme_spec.rb` (twice), `settings_menu/light_values_spec.rb` and `big_screen_theme/light_values_spec.rb`; rename `dark!` in `spec/support/system/dark_contrast.rb` to `dark_device!`, since the other `light!` helpers set the cookie, not the device.

## Comments
