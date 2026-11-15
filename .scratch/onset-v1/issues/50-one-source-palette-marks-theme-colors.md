# 50: One source each for the card palette, the color marks and the theme colors

Status: needs-triage
Kind: behavioural
Blocked by:
Priority:
Feature:
Model:
Effort:
Changelog:

## Request

Deferred from 41. Behind the scenes: one source each for the card palette, the color-mark shapes and the theme colors, so a change to one cannot leave a copy behind. The palette hex values live in `app/assets/tailwind/application.css` and again in the menu's chips in `layouts/_settings`; the color-mark polygon points in `cards/_card` and again in `layouts/_settings`; `THEME_COLORS` and the `theme-color` meta logic in `ThemesHelper` and again in `settings_controller.js`. Have the chips read the CSS custom properties and the marks come from one helper constant, pass the theme colors to the controller as a Stimulus value rendered from the helper, and in the same pass give `layouts/_settings` one `variant:` local with one map for its button, icon and menu classes in place of its three `player_screen`/`big_screen` cascades, and `settings_controller.js` one cookie-and-dataset writer for both picks.

## Comments
