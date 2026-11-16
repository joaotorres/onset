# 43: Light theme and the settings menu on the landing, join page and How to play

Status: deployed
Kind: visual
Blocked by: 39
Priority: normal
Feature: Themes
Model:
Effort:
Changelog: The landing, the join page and How to play now come in a light theme too, following your device or your pick in a new settings menu.

## Request

Split from 40 (Dark mode, with a settings menu to toggle it): the theme mechanism, the settings button and menu with its Theme option, and the light theme of the landing, the join page, How to play and the byline footer.

## Spec references

- SPEC.md, Shared: 10. Cards and visual system > Themes
- SPEC.md, Shared: 10. Cards and visual system > Visual system (surfaces and contrast)
- SPEC.md, 8. Settings menu
- SPEC.md, Shared: 7. Realtime > Hooks that must survive any markup change (Settings menu)
- SPEC.md, 8. Byline footer (Logo colours)
- SPEC.md, Shared: 17. Telemetry > Custom events (`theme_changed`) and Privacy
- SPEC.md, 8. Landing, 8. Join page, Shared: 8. Views & UX
- docs/design-system.md v6: Shared: Themes (v6), Shared: Rules added in v6, Components > Settings button, Settings menu, Landing mode toggle, layouts/_byline_footer, Stimulus controllers; Screens > Settings button placement, Landing, Join page, How to play
- Boards (canvas in docs/design-handoff.md): LightSheet, SettingsMenu, s-landing-p-dark, -p-dark-open, -p-light-open, s-landing-d-dark, -d-dark-open, -d-light-open, s-join-dark-open, s-join-light-open, l-landing-p, l-landing-p-notfound, LandingTh, l-landing-d-quick, JoinTh, l-join-creator, -taken, -started, -full, l-htp-p, s-htp-p-dark, HowToPlayTh, d-htp-d
- GLOSSARY.md: Settings menu, Theme

## Scope

- **The theme mechanism**, shared by every page and reused by 44 and 45: the `theme` cookie (`light` or `dark`, path `/`, a year, SameSite Lax, not HttpOnly) read by the layout and rendered on `<html>`, so the first paint is right; with no cookie, the theme follows `prefers-color-scheme` through CSS alone, live, and a device with no preference gets dark. `color-scheme` and the `theme-color` meta follow the theme (`#030712` dark, `#F9FAFB` light). One way, in `app/assets/tailwind/application.css`, to give any element its light value next to its dark one, keyed on `<html>` and never on markup rendered per viewer, so Turbo Stream partials stay the same for every screen
- **The settings button and menu**, in the layout, outside every broadcast target, with `data-controller="settings"` around both: the button as DESIGN v6 draws it (pages size), the popover with its title, close button and the Theme fieldset (Match device, Light, Dark, as native radios), and a `settings` Stimulus controller that writes or deletes the cookie, applies the choice to `<html>` at once with no reload, and sends `theme_changed` with `theme` (`device`, `light`, `dark`) when the pick differs from the current one. Closing, focus, the current choice and the arrow-key behaviour as SPEC 8. Settings menu says. The menu renders on the landing, the join page and How to play only: 44 and 45 add it to the player screen and the big screen
- **The light theme** of the landing (both layouts, Room not found, the mode toggle), the join page (every state: creator link, taken, started, full, field errors; the selected and taken swatches of the light theme), How to play (its panels, rings, rows and the light inset edge on borderless panels) and the byline footer (light logo colours, `gray-600` at rest with the `#C60B1E` underline), every value from DESIGN v6 Shared: Themes (v6), the light field border at rest `gray-500`. The card wrapper edge, light only, on the landing's fanned cards and How to play's diagrams. Dark stays exactly as built
- Must not touch: the `_card` partial and the card palette (41), the player screen and the big screen views (44, 45), the static error pages in `public/` (42)

## Acceptance criteria

- With no `theme` cookie, a browser emulating `prefers-color-scheme: light` renders the landing on the light page (`gray-50`), and one emulating dark or stating no preference renders it as today; switching the emulated preference with the page open switches the page with no reload
- With `theme=light`, the server-rendered `<html>` already carries the light theme (the response body, before any script runs), and the landing, join page and How to play render light even on a dark device; with `theme=dark`, they render dark on a light device
- `color-scheme` and the `theme-color` meta match the theme in each case above
- Every page above shows the settings button (accessible name "Settings", `aria-expanded` false, then true while open) in the place DESIGN v6 Settings button placement gives; it opens the menu, a dialog named "Settings" holding the Theme radios Match device, Light and Dark
- With no cookie, Match device is checked; picking Light sets `theme=light` (a year, SameSite Lax, path `/`) and the page turns light with no reload and the menu still open; picking Dark sets `theme=dark`; picking Match device deletes the cookie and the page follows the device again; a reload keeps the choice
- Arrowing from Match device to Dark applies Light then Dark and sends `theme_changed` once per step; picking the option already chosen sends nothing
- `theme_changed` carries `theme` `device`, `light` or `dark`, through `window.jtTrack?.`
- Escape and the close button close the menu and return focus to the settings button; a tap outside closes it, leaves focus where it was, and does not activate what it lands on (a tap on Start a game while the menu is open only closes the menu: no room is created)
- In the light theme, each page's surfaces, text, borders and meaning colors are those DESIGN v6 lists (spot checks: the page `gray-50`, the landing actions card white, primary text `gray-900`, the code field border at rest `gray-500`, "Room not found" `red-700`, the selected join swatch's `gray-900` ring, a taken swatch blended over `gray-50` with a `gray-700` initial, the byline at rest `gray-600`)
- In the dark theme every page above renders as it does before this ticket (the existing specs of these pages pass unchanged)
- The light card wrapper edge shows on the landing's fanned cards and How to play's diagrams in light only; the `_card` markup is unchanged
- The byline footer still fits the first screen on the landing and the join page, with the settings button on the page

## Verification

`bin/test-all && bin/rubocop`

Tests first:

- A request spec: the layout renders the theme on `<html>` for `theme=light`, `theme=dark` and no cookie, and the `theme-color` meta for each
- System specs (headless Chrome, emulating `prefers-color-scheme` through the driver) for: device-following with no cookie, the menu's open, pick, close and focus behaviour, the cookie written and deleted, the tap outside that creates no room, arrow-key picking, and `theme_changed` (stub `window.jtTrack` and read its calls, as the existing telemetry specs do)
- Computed-style spot checks of the light values listed above

## Out of scope

- The Card colors option in the menu, the Classic palette and the color mark: ticket 41 adds them to this menu
- The settings button on the player screen and the big screen, and their light theme (44, 45)
- Raising dark-theme contrast (muted text, field borders): deferred from 40
- Themed static error pages (42)
- Any setting stored on `Player` or `Game`, or any request to the server when picking

## Comments

Decided: blocked by 39, because 39 rebuilds How to play's box and the byline footer's, and DESIGN v6 draws How to play's light boards in that box. Instead of: building on the old box and redoing it.

Decided: the one way to give an element its light value is a `light:` Tailwind custom variant in `application.css` (matches `html[data-theme=light]`, or no `data-theme` under `prefers-color-scheme: light`), plus `@variant light` inside plain CSS rules (byline, card edge, `color-scheme`), because it puts each light class next to its dark one in the same static markup. Instead of: remapping the gray scale through CSS variables.

Decided: the settings partial (`layouts/_settings`) is rendered by each page's own view, top-right inside `main` on the landing and join page and in the nav row on How to play, because How to play's button sits in its nav and none of the three pages has a broadcast target. Instead of: one fixed spot in the layout file. 44 and 45 render it outside `#controller_status` and the big screen's targets.

Decided: a tap outside lands on a transparent full-window layer under the open menu, which closes it on click, so the tap never reaches what is under it and nothing is dimmed. Instead of: a document click listener that cancels the event, which a touch tap can still slip past.

Decided: opening the menu moves focus to the checked Theme radio, so arrow keys work at once. Instead of: leaving focus on the settings button.

Decided: quick review 20261115-132523 leaves the records' drift from the built settings menu to a follow-up, because the review changes only Changelog lines and Deferred paragraphs. Instead of: rewording SPEC and DESIGN in the review commit.

Deferred: Behind the scenes: bring the records in line with the built settings menu. SPEC §7 Hooks (Settings menu) and DESIGN v6 Settings button and Settings menu say the `settings` controller and menu sit "in the layout", but each page's view renders `layouts/_settings` (this ticket's Decided line, and 44 and 45 outside their broadcast targets); reword all three. And measure the player screen menu's offset from the bottom in portrait and on computer (play, Waiting, Game over) and write the built values into DESIGN Settings button placement, which says 36px and 60px while the classes give about 46px to 48px. Filed as 49.

Decided: deep review 20261115-142819 leaves its fixes on the settings menu to follow-ups, because the review changes only Changelog lines and Deferred paragraphs. Instead of: fixing them in the review commit.

Deferred: Escape closes the open settings menu wherever focus is. `layouts/_settings` binds `keydown.esc` on its wrapper div only, so after a click on blank space in the open menu (its title, padding or a legend) focus drops to the page body and Escape does nothing (SPEC §8 Settings menu, "Closing it: Escape"). Bind it on the document (`keydown.esc@document->settings#escape`; `escape()` already checks the menu is open), so all five screens get it from the one partial, and add a system spec that clicks the menu's title and then presses Escape. Filed as 51.

Deferred: A tab that follows a link inside Onset takes on the theme and card colors picked in another tab. The picks live on `<html data-theme>` and `<html data-card-colors>` (`layouts/application.html.erb`), but Turbo Drive keeps the old `<html>` on a link visit and copies over only `lang`, so the tab keeps its old theme and card colors while the new head brings the new `theme-color` meta and the menu's radios come checked from the new cookie (SPEC §10 Themes, "Other open tabs of the same browser take it on their next page load", and §10 Palette for card colors, ticket 41). Copy both attributes from the incoming document's `<html>` on `turbo:before-render`, and cover it with a system spec that changes the cookie, then follows a link. Filed as 52.

Deferred: Behind the scenes: bring the records in line with what is built, and cover the settings menu's untested paths. DESIGN `docs/design-system.md` Tokens (byline logo colours) says the dark byline values on `.byline-footer` are "the values every Onset screen uses", false since the light theme (SPEC §10 byline colours); DESIGN How to play says "the code still holds `max-w-5xl`", stale since ticket 39; DESIGN Settings menu placement says the menu opens "8px from it", while Settings button placement and ticket 45 give 12px on the big screen. SPEC §10 Palette "Selected card ... `ring-blue-400`" leaves out the light theme's `ring-blue-500` (ticket 44, `card_selection_controller.js`), and SPEC §8 Join page "select with a white ring" leaves out the light theme's `gray-900` ring. GLOSSARY Settings menu says "the menu on every page", while SPEC §8 and §10 leave the static error pages out. System specs for: the `theme-color` meta after a pick in the menu (only page load is checked), an open menu closed when the page is cached on navigation (`turbo:before-cache`), and a filled tray slot taking and losing `card-edge`. Filed as 53.
