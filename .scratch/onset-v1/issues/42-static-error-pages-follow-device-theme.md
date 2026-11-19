# 42: Static error pages follow the device's light or dark setting

Status: done
Kind: visual
Blocked by: 43
Priority: low
Feature: Themes
Model:
Effort:
Changelog: The error pages (such as page not found) now follow your device's light or dark setting, or the theme you picked in Onset.

## Request

Deferred from 40. Static error pages (404, 422, 500 and the others in public/) follow the device's light or dark setting, as the app's own pages do since the light theme.

Ticket 40 left them dark because they are static files that cannot read the `theme` cookie.

## Spec references

- SPEC.md, Shared: 10. Cards and visual system > Themes (the static error pages bullet, and the theme cookie, no-flash and `color-scheme` bullets it follows)
- SPEC.md, Shared: 10. Cards and visual system > Visual system (the 4.5:1 text rule, which the error pages' status code numerals are exempt from)
- SPEC.md, Shared: 8. Views & UX (no settings menu on the static error pages)
- docs/design-system.md v7, Screens > Static error pages (the colors of each part in each theme, boards `err-404-p-dark`, `err-404-p-light`, `err-500-d-dark`, `err-500-d-light`)

## Scope

The five static files in `public/`: `400.html`, `404.html`, `406-unsupported-browser.html`, `422.html`, `500.html`, each self-contained (inline CSS and inline script, no asset pipeline, no Tailwind, no external file). Today each is the untouched Rails scaffold, which follows the device in generic colors of its own (`#FFF`, `#101010`, `#d30001`, `#f0eff0` and so on).

For each page:

- Replace the scaffold's colors with Onset's, as plain hex, the Tailwind default palette's hex for each shade (the two pages' grounds match `ThemesHelper::THEME_COLORS`: `#030712` dark, `#F9FAFB` light), per DESIGN Screens > Static error pages: page, bold first sentence (the `<strong>`), rest of the paragraph, numerals (`#error-id`), status name (`#error-description`), in dark and light
- Dark is the default. Light applies when `<html data-theme="light">`, or with no `data-theme` under `@media (prefers-color-scheme: light)`; `data-theme="dark"` stays dark on a light device. The same selector logic as the app's `light` custom variant, so a device with no preference gets dark
- An inline script in `<head>`, before the `<style>` or any body paint, reads the `theme` cookie and sets `data-theme` on `<html>` only when it is exactly `light` or `dark`; any other value, or no cookie, leaves `<html>` without it. The script never writes the cookie
- `color-scheme` on `:root` follows the shown theme (dark by default, light in light)
- `theme-color` metas as the app's layout gives them for Match device (light `#F9FAFB` under `(prefers-color-scheme: light)`, then dark `#030712` with no media), and the script, when it sets a theme from the cookie, leaves exactly one `theme-color` of that theme's value
- The header SVG gets an accessible name: `role="img"` and an `aria-label` of the code and name in the page title's brackets (such as `404 Not found`, `406 Not Acceptable`)
- Layout, sizes, font, header graphic paths and messages unchanged

Must not touch: the app layout, `ThemesHelper`, the settings menu, any view, any Stimulus controller, `public/icon.*`, `favicon.ico`, `robots.txt`, `sitemap.xml`.

## Acceptance criteria

For each of the five pages, visited by its path (such as `/404.html`) in the headless browser:

- With no `theme` cookie and the device set to dark, the body's background is `gray-950` (`rgb(3, 7, 18)`), the `<strong>` first sentence `gray-50`, the rest of the paragraph `gray-300`, `#error-id` fill `gray-800`, `#error-description` fill `red-400`, and `:root`'s computed `color-scheme` is `dark`
- With no `theme` cookie and the device set to light, the same parts are `gray-50`, `gray-900`, `gray-700`, `gray-200`, `red-700`, and `color-scheme` is `light`
- With no cookie and the device stating no preference, the page is dark
- With `theme=dark` on a light device the page is dark, and with `theme=light` on a dark device it is light, from the first paint (the script runs in `<head>`)
- With `theme=bogus` the page follows the device, and `<html>` has no `data-theme`
- With `theme=light` the page has exactly one `theme-color` meta, `#F9FAFB`; with `theme=dark` exactly one, `#030712`; with no cookie, the two the app's layout gives for Match device
- The header SVG has `role="img"` and an `aria-label` equal to the bracketed code and name of the page's `<title>`
- Each page's `<title>` and message text are byte-for-byte what they are today

## Verification

`bin/test-all && bundle exec standardrb`

Write first: a system spec (in its own file under `spec/system/`, split by `describe` groups to stay under 8 s) that visits each of the five pages under each case above, using the existing `emulate_color_scheme` helper for the device setting and a cookie set on the app's host for the theme, and checks computed colors with `getComputedStyle`. Show it red against the scaffold pages.

## Out of scope

- A settings menu, the byline footer, a link back to Onset, the wordmark, or any new text on the error pages (SPEC §10 Themes)
- Raising the faint numerals to 4.5:1 (SPEC §10 Themes exempts them)
- Rewording any page's message or title
- Moving the error pages into the app's layout or rendering them through a controller
- Generating the pages' hex from the Tailwind build or from `ThemesHelper`: they keep plain hex in their own CSS
- Any change to other pages' theme handling

## Comments

Decided: the error pages take Onset's own dark and light surfaces and text shades, because the five pages in `public/` are the untouched Rails scaffold, which already follows the device but in generic colors of its own (white, `#101010`), so "as the app's own pages do" means the app's two themes. Instead of: closing it `wontfix` as already built.

Decided: the `theme` cookie, when set, wins on the error pages through a few lines of inline script in `<head>` that accept only `light` or `dark`, because the cookie is not HttpOnly and a player who picked Dark on a light device would otherwise get the one light page in the app. Instead of: following the device only, as the request reads.

Decided: no settings menu, no byline footer and unchanged messages on the error pages, because they are static files with no Stimulus controllers and the request asks for the theme only. Instead of: bringing them in line with the app's pages in full.

Decided: blocked by 43 still, because the error pages copy the light values 43 builds as plain hex in their own CSS. Instead of: building them on the design entry alone.

Spec settled in SPEC.md, Shared: 10. Cards and visual system > Themes (The static error pages) and Shared: 8. Views & UX. Gate 2 not met: docs/design-system.md v6 does not cover the static error pages (the brief for 40 and 41 left them out and its entry quotes them as staying dark), so the design pass has not happened. Missing: the error pages' dark and light look in Onset's tokens, a board for each theme. Waiting for /design-brief 42.

Rechecked 2026-11-17: still waiting for the design pass. docs/design-system.md has no changelog entry for this ticket (the latest, v6, is tickets 40 and 41, plus ticket 49's records correction, which designs nothing for the error pages). Blocker 43 is deployed, so the brief can be written now. The five files in `public/` are still the scaffold. No conflict with open tickets 46 to 55: 46 already covers the error pages' dark muted text and field borders if this ticket is built first, 50's one-source rule covers only `app/` and leaves static files such as `public/icon.svg` as they are, and 52's spec change (every page load takes the cookie as it is then) is the rule the inline script already follows. The brief draws each error page in dark and light from Onset's surfaces and text shades, its message unchanged, with no settings menu and no byline footer.

Rechecked again 2026-11-17, after builds 50 to 56: still waiting for the design pass, no `DESIGN` changelog entry covers it and `public/` is unchanged. The spec and design edits since (claims, Start and Play again, the light selection ring, the byline footer and menu records) touch nothing on the error pages, and the new open tickets, 47, 48 and 57, do not conflict.

Decided: brief 20261119-42-46 draws the error pages as four new boards, 404 on a phone and 500 on a computer, each dark and light, the other three pages taking the same layout with their own words, and redraws no board, because no board of the error pages exists yet and the five differ only in their text. Instead of: a board per page and theme, ten boards, over the 6-board round.

Design entry: docs/design-system.md v7, Screens > Static error pages, boards `err-404-p-dark`, `err-404-p-light`, `err-500-d-dark`, `err-500-d-light`. Colors only: dark page `gray-950`, bold first sentence `gray-50`, rest `gray-300`, numerals `gray-800`, status name `red-400`; light `gray-50`, `gray-900`, `gray-700`, `gray-200`, `red-700`.

Design question: the error pages' faint status code numerals (dark `gray-800` 1.37:1, light `gray-200` 1.18:1, as faint as the scaffold's) are below SPEC §10 Visual system's 4.5:1 for text. The design treats them as a backdrop graphic under the red status name, with the page title and the SVG's label naming the code. Confirm SPEC §10 Themes treats them as decoration, or say they must reach 4.5:1, which would turn them into a visible second headline.

Decided: the design entry records the numerals as decoration in DESIGN v7 and leaves the 4.5:1 question to triage, because the scaffold draws them as SVG paths behind the status name, ticket 42 keeps the header graphic, and the SPEC rule lists text, not graphics. Instead of: flagging them as a conflict with SPEC §10 and holding the entry.

Decided: the entry adds Screens > Static error pages and retires the Visual rules line that called the error pages "not drawn yet (ticket 42)"; no existing rule or token changes for this ticket. Instead of: leaving the stale line.

Gate 2 met: docs/design-system.md v7 (commit cf36849, after the ticket was filed) covers the error pages in both themes, Screens > Static error pages. No conflict with the undeployed spec changes (none since deploy-20261119-1509) or with open tickets 46, 47, 48, 54, 58, 59 and 60: the v7 error pages hold no muted text and no form field, so 46's note on them has nothing to raise.

Decided: the status code numerals stay as faint as DESIGN v7 draws them (dark `gray-800`, light `gray-200`), a backdrop graphic exempt from SPEC §10's 4.5:1 text rule, written into SPEC §10 Themes, because they are SVG paths behind the red status name, which reads at over 5:1 and says what went wrong, and the page title and the graphic's accessible name give the code. Instead of: raising them to 4.5:1, which turns them into a second headline above the status name.

Decided: each page's header SVG gets `role="img"` and an `aria-label` of the code and name its title gives in brackets, because the decoration call above rests on the graphic naming the code to a screen reader, and the scaffold's SVG has no accessible name. Instead of: leaving the graphic unnamed, the code then only in the tab title.

Decided: the error pages get the app's Match device `theme-color` pair and a `color-scheme` that follows the shown theme, the inline script narrowing `theme-color` to one when the cookie sets a theme, because SPEC §10 Themes holds both on every page and DESIGN v7 gives the pages' `theme-color`. Instead of: no `theme-color`, the browser bar keeping its default.

Decided: Priority low, because the error pages are rarely seen and already follow the device in the scaffold's own colors. Instead of: normal, as the other theme tickets.
