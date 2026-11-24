# 87: A static error page shown again by Back or Forward takes the current theme

Status: ready-for-agent
Kind: behavioural
Blocked by: 84
Priority: low
Feature: Themes
Model:
Effort:
Changelog:

## Request

Deferred from 77. A static error page (400, 404, 406, 422, 500) shown again by Back or Forward from another site shows the theme picked meanwhile in another tab. Each page's inline script in `<head>` reads the `theme` cookie once before the first paint, so a page the browser restores from its back-forward cache keeps the old theme on `<html>` and in the `theme-color` meta, and the script removes the device-matching `theme-color` metas it would need when the cookie has since been deleted. Run the same read on `pageshow` when `persisted`, restoring both metas for Match device, in all five pages, with a system spec that leaves for another site and comes back.

## Spec references

No spec change. Already covered by:

- Shared: 10. Cards and visual system > Themes, "Picking a theme applies at once": a page load is every page Onset shows, Back or Forward to a page shown before included, and each takes the theme from the cookie as it is then, the `theme-color` included
- Shared: 10. Cards and visual system > Themes, "The static error pages": with no `theme` cookie they follow the device through the media query, the cookie when set (`light` or `dark` only) wins, and their `color-scheme` and `theme-color` follow the theme they show

## Scope

- The inline theme script in `<head>` of each of `public/400.html`, `public/404.html`, `public/406-unsupported-browser.html`, `public/422.html` and `public/500.html`, the same text in all five. It keeps running at once, before the first paint, as now, and runs the same read again on `pageshow` when `event.persisted`:
  - `theme` cookie `light` or `dark`: `data-theme` set to it on `<html>`, and one `theme-color` meta, with no `media`, holding that theme's color (`#F9FAFB` light, `#030712` dark)
  - no cookie, or any other value: no `data-theme` on `<html>`, and the two `theme-color` metas exactly as the file ships them: `#F9FAFB` with `media="(prefers-color-scheme: light)"`, then `#030712` with no `media`. The script rebuilds them when an earlier read removed one
  - a non-persisted `pageshow` does nothing: the read that ran before the first paint already holds
- A new system spec under `spec/system/static_error_pages/`
- Must not touch: the pages' `<style>` blocks, titles, messages and header graphics; the layout's settings menu and `settings_controller.js` (ticket 77); `ThemesHelper` and the server's cookie handling (ticket 78). The pages stay free of Stimulus and of any script file: the script stays inline

## Acceptance criteria

Each criterion opens the page by its own address (such as `/404.html`), leaves for another site (a `data:` URL) and comes back with Back, and a window marker set before leaving is still there, so the page was restored from the back-forward cache, not loaded again.

- For each of the five pages, on a dark device with no `theme` cookie: a `theme=light` cookie set while the page is open, then away and Back, shows `data-theme="light"` on `<html>`, the light parts (`StaticErrorPages::LIGHT_PARTS`), `color-scheme` light and one `theme-color` meta, `#F9FAFB` with no `media`
- For each of the five pages, on a dark device opened with `theme=light`: the cookie deleted while the page is open, then away and Back, shows no `data-theme`, the dark parts, `color-scheme` dark, and the Match device pair `[#F9FAFB, (prefers-color-scheme: light)], [#030712, no media]`
- On `/404.html` opened with `theme=light`, `theme=dark` set while away shows `data-theme="dark"`, the dark parts and one `theme-color` meta, `#030712` with no media
- On `/404.html` on a dark device opened with `theme=light`, `theme=blue` set while away shows no `data-theme`, the dark parts and the Match device pair
- The inline theme script is the same text in all five pages (a spec reads it out of each file)
- The existing specs in `spec/system/static_error_pages/` stay green: a fresh load with or without the cookie shows what it shows today, metas included

## Verification

`bin/test-all && bundle exec standardrb`

Write first, in a new `spec/system/static_error_pages/back_from_another_site_spec.rb`, under 8 s (split it by `describe` group if `bin/test-all` names it):

1. The restore criteria above, each with `visit "data:text/html,<p>away</p>"` and `page.go_back`, using ticket 84's shared cookie writer, theme-color list reader and window marker and the "static error pages" context's parts and `data_theme`
2. The same-script criterion, reading each file under `Rails.public_path` and comparing the `<script>` block's text

Show 1 fails on the cookie-deleted and cookie-set criteria before the pages change. Triage confirmed headless Chrome restores `/404.html` and `/500.html` from the back-forward cache by their own address (`pageshow` `persisted` true, window state kept).

## Out of scope

- Any change to how the pages look, read or are served (their status codes, headers or the public file server)
- Card colors: the error pages show no cards and never read `card_colors`
- A shared script file for the five pages: they stay self-contained
- The settings menu's own back-forward cache sync (ticket 77)

## Comments

Decided: no spec change, because SPEC §10 Themes already counts Back or Forward to a page shown before as a page load that takes the cookie as it is then, on every page Onset shows, and its static error pages bullet already says what each cookie value shows. Instead of: adding "and again when restored from the back-forward cache" to the static error pages bullet.

Decided: built, not closed as not reproducible, though a probe showed headless Chrome never restores a page served with an error status (a missing route's 404 came back as a fresh load, marker gone), because the pages opened by their own address are served with 200 and restored, other browsers may restore error responses, and the fix is the same few lines in each page. Instead of: wontfix as Chrome never shows it.

Decided: the specs open each page by its own address, because that is the path headless Chrome restores from the back-forward cache, and it runs the same inline script a real error response runs. Instead of: a test-only route serving the pages with their error status, which Chrome would never restore.

Decided: a Back or Forward that loads the page again (from the network or the HTTP cache) needs no change, because a fresh document runs the inline script again with the cookie as it is then and starts from the shipped metas. Instead of: a second fix for that path, as 77's `connect()` call.

Decided: the script rebuilds the Match device pair when the cookie is gone, because the first read removes the device meta and a restore must show both again, as SPEC §10's static error pages bullet says with no cookie. Instead of: keeping both metas and rewriting their content, which would change what a fresh load leaves in the markup spec.

Decided: one test asserts the five scripts are the same text, because the fix lives in five copies and one drifting is the likeliest way it breaks. Instead of: running every criterion on every page, which would push the file over 8 s.

Decided: blocked by 84, because 84 moves the cookie writer, the theme-color reader and the window marker into one shared context and reshapes the "static error pages" context this spec uses, so building first would add copies 84 must then remove. Instead of: no blocker.

Decided: Priority low, Feature Themes (77's), Model and Security left empty, because it shows only after a pick in another tab while an error page is open, then Back from another site, in a browser that restores that page, and the change is five copies of a short inline script. Instead of: normal.
