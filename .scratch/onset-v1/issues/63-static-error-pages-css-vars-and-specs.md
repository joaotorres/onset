# 63: Static error pages: CSS variables and theme-color specs

Status: needs-triage
Kind: behavioural
Blocked by:
Priority:
Feature:
Model:
Effort:
Changelog:

## Request

Deferred from 42. Behind the scenes: tighten the five static error pages in `public/` (400, 404, 406-unsupported-browser, 422, 500) and their specs. In each page, put the theme's colors in CSS custom properties on `:root`, overridden once for `[data-theme="light"]` and once under `@media (prefers-color-scheme: light)` for `:root:not([data-theme])`, so each light rule is written once instead of twice; the pages stay self-contained, plain hex. In `spec/system/static_error_pages/`, assert the page grounds and the `theme-color` metas against `ThemesHelper::THEME_COLORS` instead of hard-coded `#F9FAFB`/`#030712` (`markup_spec.rb`), so a change to the app's theme colors fails the error page specs, and add a check that each page's `<title>` and message text are unchanged from the scaffold (ticket 42's last criterion, untested).

## Comments
