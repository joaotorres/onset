# 78: A theme or Color-blind pick lasts a year on Safari too

Status: ready-for-agent
Kind: behavioural
Blocked by:
Priority: high
Feature: Themes
Model:
Effort:
Changelog:

## Request

Deferred from 52. A theme or Color-blind pick lasts the year SPEC §10 gives it on Safari too. The `theme` and `card_colors` cookies are written only by script (`store` in `settings_controller.js`, `max-age` a year), and Safari caps a cookie a page's script writes at 7 days, so on an iPhone or in a Mac's Safari a pick lapses a week after it was made. Have the server send each valid cookie again with its year on page loads, or another way that keeps the pick itself in the browser with no request; both cookies, on every page the layout renders. The static error pages only read them.

## Spec references

- Shared: 10. Cards and visual system > Themes, "Stored per browser": every page the layout renders sends the `theme` cookie back with a fresh year while it holds `light` or `dark`; a value the server does not accept is not sent back; the pick itself still makes no request
- Shared: 10. Cards and visual system > Palette, "Stored per browser": the same for `card_colors` while it holds `colorblind`
- 8. Settings menu, "Picking": a plain browser control with no request to the server (unchanged)

## Scope

- The server side only: one place every page controller passes through (`ApplicationController`, or a concern it includes) that, on a response rendering a page with the application layout, writes back each of the two cookies whose current value the server accepts, by the same rule `ThemesHelper#chosen_theme` and `#chosen_card_colors` read with (`light` or `dark`; `colorblind`). Reuse that rule, do not copy the lists
- The renewed cookie keeps the attributes the menu's script writes: name unchanged, path `/`, expiring a year from now, SameSite Lax, not HttpOnly (the menu must still read and write it). The value is written back unchanged. Production's `force_ssl` marks it Secure; that is fine, since the menu writes from the HTTPS page and still replaces it
- Pages covered: the landing, How to play, the join page, the big screen and the player screen, and a page rendered back with its error or limit (the join page's 422, the landing's and join page's 429)
- Not on responses that render no page: the `204` actions, `/clock`'s JSON, redirects, the `403`/`404`/`429` heads
- Must not touch: `settings_controller.js` (its `store` writes and the sync ticket 77 adds), the static error pages in `public/`, the cookie-reading rule in `ThemesHelper`, the encrypted `player_token` and `host_game` cookies

## Acceptance criteria

- A GET of the landing, How to play, the join page, the big screen and the player screen with a `theme=light` cookie answers with a `Set-Cookie` for `theme=light`, path `/`, expiring a year from now (within a minute), SameSite Lax and without HttpOnly
- The same with `theme=dark`, and with `card_colors=colorblind`; with both cookies set, one response renews both
- With no `theme` or `card_colors` cookie, the response sets neither, so Match device and Classic stay deleted
- With a value the server does not accept (`theme=blue`, `card_colors=x`), the response does not send that cookie back
- The join page rendered back with a taken name (422) renews the cookies too
- A `204` action (such as the ready vote), `GET /clock` and the `GET /join?code=` redirect send no `theme` or `card_colors` `Set-Cookie`
- In the browser, on a page loaded with `theme=light` (so the server just renewed it), picking Dark in the settings menu and reloading shows dark, and picking Match device and reloading leaves no `theme` cookie: the server's renewal never blocks a later pick. The same for Color-blind then Classic
- The existing specs in `spec/requests/themes_spec.rb`, `spec/requests/card_colors_spec.rb` and `spec/system/settings_menu/` stay green

## Verification

`bin/test-all && bundle exec standardrb`

Write first, and show they fail before the change:

1. A new `spec/requests/display_cookie_renewal_spec.rb`, under 8 s: the header criteria above, one example per page for `theme=light` and grouped examples for the rest, reading the `Set-Cookie` lines for `theme=` and `card_colors=` and checking path, expiry, SameSite and the absence of HttpOnly
2. One system example in `spec/system/settings_menu/` (in an existing file when it stays under 8 s, else a new one): the pick-after-renewal criterion, reusing the cookie helpers already in `spec/system/settings_menu/other_tab_spec.rb`

Safari itself is not in the suite: the specs check the header the server sends, which is what Safari keeps for its full lifetime.

## Out of scope

- Moving the picks to `localStorage` or any other browser storage
- Renewing on responses that render no page (`204` actions, JSON, redirects)
- Deleting a cookie whose value the server does not accept
- Any change to the settings menu's script, ticket 77's back-forward cache sync or the static error pages
- Moving spec helpers to one home (ticket 81)

## Comments

Decided: SPEC §10 Themes and Palette now say every page the layout renders sends each accepted cookie back with a fresh year, because the year then counts from the last page load instead of the pick, a change the spec's "a year long" should state, and it records why the server writes a cookie the menu owns. Instead of: no spec change.

Decided: the server renews the cookies, not another store in the browser, because Safari's limits reach every store a script writes (a `document.cookie` cookie lives 7 days, `localStorage` is deleted after 7 days of Safari use without a visit), while a cookie the server sends keeps its full lifetime, and the pick itself still needs no request. Instead of: `localStorage`.

Decided: only responses that render a page renew, because §10 counts page loads, and an action answered while a pick is made in the same tab (a claim pick, a ready vote) would send the old value back and undo the pick. Instead of: every response.

Decided: a page load already on its way in another tab when a pick is made can bring the old pick back with its response; accepted, because it takes two tabs and a pick in the same moment, and picking again fixes it. Instead of: versioning the cookie value.

Decided: a value the server does not accept is left as it is, not deleted, because every reader already ignores it, and deleting is a change the request did not ask for. Instead of: deleting it on the next page load.

Decided: the fix covers the two cookies only, because a search of the app for storage a script writes finds just `theme` and `card_colors` (`settings_controller.js`) and the `game-events` `sessionStorage` entry, which lasts one tab session by design (§17 Privacy); `player_token` and `host_game` are set by the server already. Instead of: a wider sweep.

Decided: no blocker on 77, 80 or 81, because 77 changes the menu's script and must not touch the server helpers, 80 changes selectors in other spec files and 81 where spec helpers live, and this one only adds a server write; whichever builds second keeps the other's edit. Instead of: blocking on 77.

Decided: Priority high, Feature Themes (ticket 52's), Model and Security left empty, because it is broken behaviour in built work for every Safari and iPhone player who picks, the fix is one server-side write with request specs, and the cookies are display preferences with no identity that §17 Privacy already covers. Instead of: normal, Model: fable or Security: yes.
