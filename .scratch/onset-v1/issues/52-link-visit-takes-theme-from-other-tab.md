# 52: A tab that follows a link takes on the theme and card colors picked in another tab

Status: deployed
Kind: behavioural
Blocked by:
Priority: normal
Feature: Themes
Model:
Effort:
Changelog: A theme or card colors picked in another tab now show on the next page you open by a link or Back, not only after a reload.

## Request

Deferred from 43. A tab that follows a link inside Onset takes on the theme and card colors picked in another tab. The picks live on `<html data-theme>` and `<html data-card-colors>` (`layouts/application.html.erb`), but Turbo Drive keeps the old `<html>` on a link visit and copies over only `lang`, so the tab keeps its old theme and card colors while the new head brings the new `theme-color` meta and the menu's radios come checked from the new cookie (SPEC §10 Themes, "Other open tabs of the same browser take it on their next page load", and §10 Palette for card colors, ticket 41). Copy both attributes from the incoming document's `<html>` on `turbo:before-render`, and cover it with a system spec that changes the cookie, then follows a link.

## Spec references

- SPEC.md, Shared: 10. Cards and visual system > Themes ("Picking a theme applies at once": a page load is every page Onset shows, a reload, a link or a form inside Onset, and Back or Forward, each taking the theme from the cookie as it is then, `theme-color` and the menu's marked choice included)
- SPEC.md, Shared: 10. Cards and visual system > Palette ("Picking applies at once": every kind of page load the theme names, from the cookie as it is then)
- SPEC.md, 8. Settings menu (The current choice; Picking)
- SPEC.md, Shared: 7. Realtime > Hooks that must survive any markup change (Settings menu, `data-controller="settings"` in `layouts/_settings`)

## Scope

- **On every Turbo Drive render** (a link or form visit, its cache preview, and a Back or Forward restoration from the cache), before the new body paints, `<html data-theme>` and `<html data-card-colors>` are set from the `theme` and `card_colors` cookies as they are at that moment, with the same rule as `ThemesHelper#chosen_theme` and `#chosen_card_colors`: `light` or `dark` sets `data-theme`, anything else removes it (Match device); `colorblind` sets `data-card-colors`, anything else removes it (Classic). Bound as a `turbo:before-render@document` action on the `settings` controller in `layouts/_settings`, beside the `turbo:before-cache@document` one, so the controller that writes the cookies and the dataset also reads them back. Not copied from the incoming document: the event carries only the new body, and a cached snapshot holds the values of the moment it was cached
- **The `theme-color` metas** match the theme on `<html>` after every render: the `settings` controller's `connect()` calls its existing `applyThemeColor` with the current theme, beside `syncRadios()`. A link visit already brings the right metas in the new head; a restoration from the cache brings the snapshot's stale ones, and this replaces them
- **The menu's radios** keep coming from `<html>` through `syncRadios()` on connect, which is right once `<html>` follows the cookie
- One partial serves all five screens (landing, How to play, join page, big screen, player screen), so no per-page change
- Must not touch: the layout's server render of `<html>` and `theme_color_tags`, the cookies and their attributes, what a pick in the menu does and the events it sends, the static error pages, SPEC 7's other hooks, the menu's markup and look

## Acceptance criteria

- On the landing with no `theme` cookie and a dark device, after the `theme` cookie is set to `light` from outside the page (as another tab's pick does), following the How to play link (a Turbo visit, not a full load) shows How to play light: `<html data-theme="light">`, the page background `gray-50`, `color-scheme` light, the matching `theme-color` `#F9FAFB`, and the menu's Light radio checked
- The same with the `theme` cookie deleted while a page shows `light`: after the link visit `<html>` carries no `data-theme`, the page follows the device and the Match device radio is checked
- After the `card_colors` cookie is set to `colorblind` from outside the page, a link visit shows the next page's cards in the Color-blind palette with the color mark showing, `<html data-card-colors="colorblind">` and the Color-blind radio checked; with the cookie deleted, the attribute is gone and the cards are Classic
- Back to a page shown before the cookie changed (a restoration from the cache) shows the theme and card colors of the cookie as it is now, its `theme-color` meta matching, not those the page had when it was cached
- A cookie value the server would not accept (`theme=blue`, `card_colors=x`) sets nothing on a link visit, as on a page load
- A full page load still renders the theme and card colors on `<html>` before any script runs, and picking in the menu still applies at once with the same cookies and events: the existing themes request spec and settings menu, theme and card colors system specs pass unchanged

## Verification

`bin/test-all && bundle exec standardrb`

Tests first, in a new `spec/system/settings_menu/other_tab_spec.rb` (headless Chrome, the `settings menu` shared context). Change the cookie with `page.driver.browser.manage.add_cookie` or `delete_cookie`, mark the window (`window.__noReload = true`) before clicking, and check the mark survives so each check runs on a Turbo visit, not a full load:

- Landing, dark device, no cookie; set `theme=light`; click How to play: `data-theme`, page background, `color-scheme`, `theme-color` and the checked radio as above. Red before the change
- From light, delete the cookie, follow the link back: no `data-theme`, the device's theme, Match device checked
- Set `card_colors=colorblind`, follow a link to a page with cards (How to play's diagrams or the landing's fanned cards): `data-card-colors`, a card's computed color from the Color-blind palette, the Color-blind radio checked. Red before the change
- Visit the landing, follow the link to How to play, set `theme=light`, go back (`page.go_back`): the landing is light and its `theme-color` is `#F9FAFB`. Red before the change
- `theme=blue`: a link visit leaves `data-theme` off

## Out of scope

- Live sync of an open tab with no navigation (a `storage` event, `BroadcastChannel`, polling): SPEC 10 says other tabs take a pick on their next page load
- The static error pages, which read the cookie in their own inline script
- The partial's `variant:` refactor, the one cookie-and-dataset writer and the theme colors as a Stimulus value (50), Escape on the document (51), the records and the menu's other untested paths (53)
- Any change to what a pick looks like or sends

## Comments

Decided: SPEC 10 Themes says what a page load is (a reload, a link or a form inside Onset, Back or Forward) and that each takes the theme from the cookie as it is then, `theme-color` and the menu's marked choice included, and Palette points to it, because with Turbo Drive "next page load" left the in-app visits, which never reload the page, open to reading as excluded. Instead of: no spec change.

Decided: `<html>` takes its attributes from the cookies on `turbo:before-render`, not from the incoming document's `<html>` as the request proposed, because the event carries only the new body, and on a Back or Forward restoration the incoming document is a cached snapshot holding the values of when it was cached, so copying it would undo a pick made since. Instead of: copying the incoming `<html>` attributes.

Decided: the fix covers the Back and Forward restoration and the cache preview too, and the `theme-color` metas a restoration brings back stale from the snapshot's head, because they are the same flaw on the other Turbo render paths: a search over every place per-browser state reaches a page finds only the two `<html>` attributes, the `theme-color` metas and the menu's radios, and nothing else in the layout comes from a browser cookie. Instead of: only link visits.

Decided: the listener is a `turbo:before-render@document` action on the `settings` controller and the metas are refreshed in its `connect()` with its existing `applyThemeColor`, because that controller already writes the cookies and the dataset and holds the meta logic, so no colors or cookie names are copied into a second module, and ticket 50 can move both to its one writer and Stimulus value in place. Instead of: a global module beside `stream_versions.js`.

Decided: no blocker on 50, 51 or 53, because 51 and this ticket each change one action on the partial's wrapper, and 50 refactors the code this one calls without changing what it does; whichever builds second keeps the other's edit. Instead of: blocking on 50.

Decided: Priority normal, Feature Themes (ticket 43's), Model left empty, because it is broken behaviour in built work, but only for a browser with two Onset tabs open or a pick followed by Back, and the fix is one Stimulus action with a system spec. Instead of: high, or Model: fable.

Decided: deep review 20261120-094918 leaves two cases where a pick does not hold for follow-ups of their own, a page the browser itself restores and Safari's one-week limit on cookies a page writes, because SPEC §10 already says what should happen in both and each has a plain fix. Instead of: pending decisions.

Deferred: Back or Forward into Onset from another site shows the theme and card colors picked meanwhile in another tab. SPEC §10 Themes counts "Back or Forward to a page shown before" as a page load that takes the cookies as they are then, but `settings#syncFromCookies` runs only on `turbo:before-render`, and a page the browser restores from its own back-forward cache (the landing, the join page or How to play, after leaving Onset by a typed address or an outside link) gets no Turbo render, so `<html>`, the `theme-color` metas and the menu's marked choice keep the old picks. Run the same sync when the page is shown again from that cache (`pageshow`), metas and radios included, for both cookies. Read from the code, not seen in a browser: reproduce it in a system spec first, and close this as already covered if no Onset page is restored that way. Filed as 77.

Deferred: A theme or Color-blind pick lasts the year SPEC §10 gives it on Safari too. The `theme` and `card_colors` cookies are written only by script (`store` in `settings_controller.js`, `max-age` a year), and Safari caps a cookie a page's script writes at 7 days, so on an iPhone or in a Mac's Safari a pick lapses a week after it was made. Have the server send each valid cookie again with its year on page loads, or another way that keeps the pick itself in the browser with no request; both cookies, on every page the layout renders. The static error pages only read them. Filed as 78.
