# 77: Back or Forward into Onset from another site shows the current theme and card colors

Status: ready-for-agent
Kind: behavioural
Blocked by:
Priority: normal
Feature: Themes
Model:
Effort:
Changelog:

## Request

Deferred from 52. Back or Forward into Onset from another site shows the theme and card colors picked meanwhile in another tab. SPEC §10 Themes counts "Back or Forward to a page shown before" as a page load that takes the cookies as they are then, but `settings#syncFromCookies` runs only on `turbo:before-render`, and a page the browser restores from its own back-forward cache (the landing, the join page or How to play, after leaving Onset by a typed address or an outside link) gets no Turbo render, so `<html>`, the `theme-color` metas and the menu's marked choice keep the old picks. Run the same sync when the page is shown again from that cache (`pageshow`), metas and radios included, for both cookies. Read from the code, not seen in a browser: reproduce it in a system spec first, and close this as already covered if no Onset page is restored that way.

## Spec references

No spec change. Already covered by:

- Shared: 10. Cards and visual system > Themes, "Picking a theme applies at once": a page load is every page Onset shows, Back or Forward to a page shown before included, and each takes the theme from the cookie as it is then, the `theme-color` and the menu's marked choice included
- Shared: 10. Cards and visual system > Palette, "Picking applies at once": card colors follow every kind of page load the theme names
- 8. Settings menu, "Closing it": leaving the page closes the menu, so Back or Forward to that page shows it closed

## Scope

- `app/javascript/controllers/settings_controller.js`: a new action for a page the browser shows again from its back-forward cache (`pageshow` with `event.persisted`). It runs `syncFromCookies`, then `applyThemeColor(this.theme)` and `syncRadios()`, and closes the menu if open without moving focus (`close(false)`). Non-persisted `pageshow` events do nothing
- In the same controller, `connect()` runs `syncFromCookies()` before `syncRadios()` and `applyThemeColor`, so a document the browser serves again from its HTTP cache on Back or Forward (stale server-rendered `<html>` attributes) also takes the cookies as they are now
- `app/views/layouts/_settings.html.erb`: wire the new action on the controller's element as `pageshow@window->settings#<action>`, beside the existing `turbo:before-render@document` and `turbo:before-cache@document` actions. The partial renders on every layout page, so the landing, How to play, the join page, the big screen and the player screen are all covered
- Keep the cookie-value rule as it is (`light` or `dark` for the theme, `colorblind` for card colors, anything else deletes the attribute)
- Must not touch: the static error pages in `public/`, the server-side helpers (`ThemesHelper`, `chosen_theme`, `chosen_card_colors`), the cookie writes in `store`

## Acceptance criteria

- On the landing with no `theme` cookie and a dark device, a `theme=light` cookie set while the page is open (as another tab would), then leaving to another site (a `data:` URL) and pressing Back, shows the landing restored from the back-forward cache (a window marker survives) with `<html data-theme="light">`, the light page background, the light `theme-color` (`#F9FAFB`) and, on opening the menu, Light checked
- The same with the cookie deleted after a light pick: Back from another site shows no `data-theme`, the dark background on a dark device, `#030712` as the `theme-color`, and Match device checked
- The same for card colors: a `card_colors=colorblind` cookie set while away shows `<html data-card-colors="colorblind">` and Color-blind checked after Back from another site; deleting it shows Classic
- A cookie value the server would not accept (`theme=blue`, `card_colors=x`) leaves both attributes unset after the restore
- With the settings menu open when the player leaves for another site, Back shows the menu, its shield and its button closed (`hidden`, `hidden`, `aria-expanded="false"`)
- When the settings controller connects on a document whose `<html>` attributes disagree with the cookies (the HTTP-cache path), `<html>`, the `theme-color` metas and the radios take the cookies' values
- The existing specs in `spec/system/settings_menu/` stay green

## Verification

`bin/test-all && bundle exec standardrb`

Write first, in a new `spec/system/settings_menu/back_from_another_site_spec.rb`, under 8 s:

1. The four restore criteria above, each leaving with `visit "data:text/html,<p>away</p>"` and returning with `page.go_back`, asserting a window marker set before leaving is still there, so the example proves a back-forward cache restore and not a fresh load. Triage confirmed headless Chrome restores the landing this way today, with `pageshow` `persisted` true and `<html>` keeping no `data-theme` while the cookie says `light`
2. The open-menu criterion the same way
3. The connect criterion: set the cookie and a stale `<html>` attribute by script, then remove and re-insert the `[data-controller="settings"]` element so Stimulus connects it again, and assert the values

Show 1 and 2 fail before the controller change. Reuse the cookie and meta helpers in `spec/system/settings_menu/other_tab_spec.rb` and the `card colors` shared context where they fit.

## Out of scope

- The static error pages' own inline script (see the Deferred line below)
- Any other state a restored page keeps, such as the board or scores on a big screen or player screen restored from the cache
- Server-side cookie refresh (ticket 78)
- Moving spec helpers to one home (ticket 81)

## Comments

Decided: no spec change, because SPEC §10 Themes already counts Back or Forward to a page shown before as a page load that takes the cookies as they are then, Palette follows it, and §8 Settings menu already says Back or Forward shows the menu closed. Instead of: spelling out "from another site" in §10.

Decided: not already covered, because a probe in headless Chrome showed Back from a `data:` URL restores the landing from the back-forward cache (window state kept, `pageshow` `persisted` true) with no `data-theme` on `<html>` while the `theme` cookie said `light`. Instead of: closing it wontfix.

Decided: the restore also closes an open settings menu, because it is the same flaw on the same path: `turbo:before-cache` does not fire when the player leaves for another site, so a restored page would show the menu open, against §8 Settings menu, Closing it. Instead of: only the theme and card colors.

Decided: `connect()` also takes the picks from the cookies first, because a page kept out of the back-forward cache can come back on Back or Forward from the browser's HTTP cache with its old server-rendered `<html>` attributes, the same flaw on the other path, and the fix is one call. Instead of: `pageshow` alone.

Decided: the new action listens on `pageshow@window` and acts only when `persisted`, because a fresh load is already right from the server render and `connect()`. Instead of: syncing on every `pageshow`.

Decided: the static error pages are left out and deferred, because their theme comes from their own inline script, which SPEC §10 Themes decides on its own ("before the first paint"), and that script removes the other `theme-color` metas, so a restore there needs its own change in five files. Instead of: folding them into this ticket.

Deferred: A static error page (400, 404, 406, 422, 500) shown again by Back or Forward from another site shows the theme picked meanwhile in another tab. Each page's inline script in `<head>` reads the `theme` cookie once before the first paint, so a page the browser restores from its back-forward cache keeps the old theme on `<html>` and in the `theme-color` meta, and the script removes the device-matching `theme-color` metas it would need when the cookie has since been deleted. Run the same read on `pageshow` when `persisted`, restoring both metas for Match device, in all five pages, with a system spec that leaves for another site and comes back. Filed as 87.

Decided: no blocker on 78, 80 or 81, because 78 changes the server's cookie handling, 80 the selectors in other spec files and 81 where spec helpers live, none the controller action or partial this one adds; whichever builds second keeps the other's edit. Instead of: blocking on 81.

Decided: Priority normal, Feature Themes (ticket 52's), Model and Security left empty, because it is broken behaviour in built work but only after a pick in another tab followed by Back from another site, and the fix is one Stimulus action and one call. Instead of: high, or Model: fable.
