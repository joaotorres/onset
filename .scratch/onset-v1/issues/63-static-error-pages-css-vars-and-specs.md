# 63: Static error pages: CSS variables and theme-color specs

Status: ready-for-agent
Kind: behavioural
Blocked by:
Priority: low
Feature: Themes
Model:
Effort:
Changelog:

## Request

Deferred from 42. Behind the scenes: tighten the five static error pages in `public/` (400, 404, 406-unsupported-browser, 422, 500) and their specs. In each page, put the theme's colors in CSS custom properties on `:root`, overridden once for `[data-theme="light"]` and once under `@media (prefers-color-scheme: light)` for `:root:not([data-theme])`, so each light rule is written once instead of twice; the pages stay self-contained, plain hex. In `spec/system/static_error_pages/`, assert the page grounds and the `theme-color` metas against `ThemesHelper::THEME_COLORS` instead of hard-coded `#F9FAFB`/`#030712` (`markup_spec.rb`), so a change to the app's theme colors fails the error page specs, and add a check that each page's `<title>` and message text are unchanged from the scaffold (ticket 42's last criterion, untested).

## Spec references

No spec change. Covered by SPEC.md, Shared: 10. Cards and visual system > Themes (the static error pages bullet: their own inline CSS and script, `theme-color` following the shown theme, messages staying as they are) and docs/design-system.md, Screens > Static error pages (the colors of each part in each theme). Nothing a user sees changes.

## Scope

The five static files in `public/` (400, 404, 406 unsupported browser, 422, 500) and the error page system specs with their shared support module (`StaticErrorPages`).

Pages, each one:

- Its `<style>` names each themed color once per theme as a CSS custom property: the dark values on `:root`, the light overrides in one `:root[data-theme="light"]` block and one `:root:not([data-theme])` block inside `@media (prefers-color-scheme: light)`. The themed colors are the page ground, the paragraph text, the `<strong>` first sentence, the `#error-id` fill and the `#error-description` fill; `color-scheme` switches in the same two light blocks
- The `body`, `strong`, `#error-id` and `#error-description` rules are each written once, reading the properties through `var(...)`; the per-element light rules (`:root[data-theme="light"] body` and the rest, twice over) go
- Still self-contained and plain hex: no external file, no Tailwind, no asset pipeline. The inline cookie script, the `theme-color` metas, the header SVG, layout, sizes, font, `<title>` and message are untouched, and every computed color is what it is today

Specs:

- The page ground values in the support module's dark and light parts, and every `theme-color` content the markup spec expects, are derived from `ThemesHelper::THEME_COLORS` (hex to the computed `rgb(r, g, b)` for the ground), not written as literals. The text and fill shades stay literals: they are the design system's, not the app's theme colors
- A check, per page, that its `<title>` and the message paragraph (`main article p`, inner HTML, the `<strong>` and any `<br>` included) equal the Rails scaffold's text, held as expected strings beside each page's label in `StaticErrorPages::PAGES`
- A check, per page, that its `<style>` writes a hex color only in custom property declarations (`--name: #hhhhhh;`)

Must not touch: the app layout, `ThemesHelper`, `application.css`, any view or Stimulus controller, the other files in `public/`, the request specs that hard-code the theme hex against the app's own output, and `visit_with_cookie`'s cookie line (ticket 64 shares it).

## Acceptance criteria

- The existing device and cookie specs for all five pages pass with the same expected text and fill shades: dark, light, no preference, `theme=dark` on a light device, `theme=light` on a dark device and `theme=bogus` each paint as today
- Changing `ThemesHelper::THEME_COLORS["dark"]` or `["light"]` (tried locally, not committed) makes the error page specs fail on both the page ground and the `theme-color` metas, with no edit to any spec file
- No error page spec file or its support module contains the literals `#F9FAFB`, `#030712` or `rgb(3, 7, 18)` / `rgb(249, 250, 251)` for the ground (the `<strong>` dark shade, also `gray-50`, may stay a literal as a text shade)
- For each of the five pages, a spec asserts the `<title>` and the message paragraph's inner HTML equal the scaffold's, and fails when either is edited
- For each of the five pages, a spec asserts every hex color in its `<style>` sits in a `--` custom property declaration, and fails against the pages as they are today
- In each page, the `body`, `strong`, `#error-id` and `#error-description` rules each appear once, and there is exactly one light override block for `[data-theme="light"]` and one inside the `prefers-color-scheme: light` media query

## Verification

`bin/test-all && bundle exec standardrb`

Write first: the custom-property check and the title and message check (in the error page markup spec, or a spec file of its own under `spec/system/static_error_pages/` if markup's goes over 8 s), and the switch of the ground and `theme-color` expectations to `ThemesHelper::THEME_COLORS`. Show the custom-property check red against today's pages, then refactor the pages until it and the device and cookie specs pass.

## Out of scope

- `light-dark()` or any CSS that old browsers lack: the 406 page is shown to unsupported browsers, so it keeps plain custom properties and media queries
- Generating the pages from a template or a script, or reading `THEME_COLORS` into them: they stay hand-written static files
- Any change to colors, messages, titles, the header graphic or its accessible name
- Tying the app's own request and system specs' theme hex to `THEME_COLORS`: they test the app's rendered output, which already fails on a change
- The shared `theme_cookie!` helper and the other spec helper moves (ticket 64)

## Comments

Triage notes, 2026-11-20. Confirmed from the code: each page writes its five light rules twice, once under `:root[data-theme="light"]` and once under `:root:not([data-theme])` in the media query; `StaticErrorPages::DARK_PARTS`/`LIGHT_PARTS` hard-code the grounds as `rgb(...)` and the markup spec hard-codes `#F9FAFB`/`#030712`; nothing checks titles or messages. `git diff` from the initial commit shows every page's `<title>` and `<p>` unchanged from the scaffold, so today's text is the expected text. Searched for the same flaw elsewhere: the app's own CSS writes each light rule once through the `light` custom variant, and the other specs that hard-code the theme hex check the app's rendered output, which `THEME_COLORS` drives, so only the error pages carry a separate copy a spec must tie back.

Decided: no spec change, under SPEC §10 Themes (static error pages bullet), because the refactor and the specs change nothing a user sees. Instead of: a spec note on how the pages' CSS is laid out.

Decided: the light values are written in two custom-property blocks (one per light condition) and each element rule once, because CSS cannot join an attribute selector and a media query in one rule, and that is the shape the request names. Instead of: `light-dark()`, which writes each value once but fails on the old browsers the 406 page exists for.

Decided: the expected titles and messages live as literal strings in `StaticErrorPages::PAGES`, because a spec reading git history to find the scaffold would break on a shallow clone. Instead of: comparing against the initial commit's files.

Decided: a check that every hex in each page's `<style>` sits in a custom property declaration, because the refactor otherwise has no test that goes red first and could drift back. Instead of: relying on the device and cookie specs alone, which pass before and after.

Decided: not blocked by 64, which also edits the error pages' support module, because 63 leaves `visit_with_cookie`'s cookie line alone and 64 only swaps that line. Instead of: Blocked by 64.

Decided: Priority low, because it is a behind-the-scenes test and CSS tidy-up of rarely seen pages. Instead of: normal.
