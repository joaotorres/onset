# 46: Dark theme muted text and field borders meet contrast

Status: done
Kind: visual
Blocked by: 43, 44, 45
Priority: normal
Feature: Themes
Model:
Effort:
Changelog: In the dark theme, faint gray text and the borders of the room code and name fields are easier to read.

## Request

Deferred from 40. In the dark theme, muted text (the "Room CODE" footer, the big screen's empty band text, the tray slot numbers) reads at 4.5:1 or more on its ground, and field borders at rest at 3:1 or more, as the light theme's do.

Ticket 40 kept dark as built, so muted `gray-500` (4.16:1 on `gray-950`) and the `gray-700` field border stayed below the spec's contrast.

## Spec references

- SPEC.md, Shared: 10. Cards and visual system > Visual system (the 4.5:1 text rule, muted and placeholders included, disabled labels exempt; the 3:1 form field border rule; the `muted` token)
- SPEC.md, Shared: 10. Cards and visual system > Themes (every themed color from CSS keyed on `<html>`, never per-viewer markup)
- docs/design-system.md v7: Shared: Tokens (`muted`), Shared: Themes (v6) Text (Muted and Placeholder rows) and Surfaces and borders (Field border at rest), Shared: Rules added in v7, Screens > Player screen (portrait tray slot numbers); board `DarkSheet`

## Scope

Colors only, in the dark theme. The light theme keeps every value it has.

- Add the `muted` color token, `#7C8390`, to the Tailwind theme in the app's stylesheet, beside the existing tokens
- Dark muted text becomes `muted` everywhere the views draw it in `gray-500` today, keeping `gray-500` in light: the player screen's "Room CODE" footer, the player screen's settings button icon, the portrait tray's empty slot numbers (also when the browser empties a slot again after a pick is undone), the big screen's empty band text ("Spot a Set? Hit SET! on your screen."), the "/N" of the No Set vote count, the big screen scoreboard's "No one yet" and a locked player's entry, and the join page's hint under the colors
- Dark placeholders become `muted` in the landing's room code field and the join page's name field, `gray-500` in light
- The dark border at rest of those two fields becomes `gray-500` (already `gray-500` in light). Their error borders and focus rings stay as they are
- Every themed color stays CSS keyed on `<html>` (the `light:` variant), so broadcast partials (the announcement band, the scoreboards) render the same markup for every viewer
- Update the existing specs that assert the old dark values

Must not touch: the disabled labels (Join when the room is full, Start game with one player, `gray-800` with `gray-500`), any `gray-700` border that is not one of the two form fields (the mode toggle's track, the Join, Copy link and Show QR buttons, the settings menu and its toggles, the QR sheet, the empty tray slot's dashed border, the waiting box), the player screen scoreboard's own-entry `gray-500` border, layouts, sizes, the `_card` partial, the light theme's values and the static error pages.

## Acceptance criteria

- In the dark theme, each muted place in Scope computes its text color to `#7C8390`: the "Room CODE" footer, the settings button icon on the player screen, an empty tray slot's number (both as rendered and after a picked card is taken back out of the slot), the big screen's empty band text, the "/N" of the No Set count, "No one yet" and a locked player's entry on the big screen scoreboard, and the join page's hint
- In the light theme each of those still computes to `gray-500`
- In the dark theme the room code field's and the name field's placeholder color is `#7C8390`, and in light `gray-500`
- In the dark theme the room code field (phone and desktop) and the name field at rest have a `gray-500` border; with an error they keep `red-500` dark and `red-600` light
- The disabled Join and Start game labels still compute to `gray-500` on `gray-800` in dark
- The mode toggle's track, the Join button on the landing, the settings menu and the empty tray slot's dashed border keep `gray-700` in dark
- A broadcast partial that shows muted text (the announcement band, the big screen scoreboard) renders the same markup for a viewer in either theme: no theme-dependent markup
- `muted` is defined once, as a theme token in the stylesheet, and no view writes `#7C8390` inline

## Verification

`bin/test-all && bundle exec standardrb`

Tests first: a system spec in the dark theme reading the computed `color` of each muted place, the placeholder color (`::placeholder`) and the at-rest border color of both fields, plus the disabled labels and one non-field `gray-700` border as built; the light-theme values beside them, extending the existing light specs (the player screen light play spec, the settings menu light values spec) where they already read these elements. Keep each spec file under 8 s, splitting by `describe` group.

## Out of scope

- Raising disabled controls' labels or any non-field border
- Redrawing the built dark boards on the canvas (DESIGN v7 and `DarkSheet` win, Shared: Rules added in v7)
- The static error pages (ticket 42), which hold no muted text and no form field in DESIGN v7
- Moving text and border shades into the one source for theme colors from ticket 50 (it covers the card palettes and the theme-color metas only)
- Any light theme value

## Comments

Decided: the fix covers every dark text in the muted shade, not only the three the request names: the "Room CODE" footer, the big screen's empty band text, its scoreboard's "No one yet" and locked player entry, the "/N" of the No Set vote count, the join page's hint under the colors, the tray slot numbers and the placeholders of the room code and name fields, all `gray-500` today, because they are one flaw, a muted shade under 4.5:1 on `gray-950` and `gray-900`, and SPEC 10 Visual system now holds every text to 4.5:1 whatever its size. Instead of: the three named places only.

Decided: the labels of disabled controls (Join when the room is full, Start game with one player, `gray-800` with `gray-500`) are exempt and stay as built, because WCAG exempts inactive controls and the design system gives them their own disabled looks. Instead of: raising them with the muted text.

Decided: a field border at rest must reach 3:1 against both the field's fill and the surface around it, and only the two form fields (the landing's room code field, the join page's name field) are field borders; the mode toggle's track and the Join and invite button borders are not, and stay as built, because a button's label and a toggle's selected segment show the control, while an empty field shows only its border. Instead of: raising every `gray-700` border.

Decided: blocked by 43, 44 and 45, because they move every dark color of each screen into the theme CSS keyed on `<html>`, and raising the dark muted text and field border after them changes each role once there instead of colliding with their rewrite of the same views. Instead of: building it first on the dark-only markup.

Decided: when ticket 42 is built first, this ticket's scope also covers the static error pages' dark muted text and field borders, which copy Onset's dark shades as plain hex, because SPEC 10 Themes gives them Onset's text shades and the Visual system contrast rule covers every page. Instead of: a follow-up for the error pages.

Spec settled in SPEC.md, Shared: 10. Cards and visual system > Visual system (the contrast rule for text and form field borders, both themes). Gate 2 not met: docs/design-system.md v6 has no changelog entry for this ticket and keeps dark muted text `gray-500` and the dark field border at rest `gray-700`. Missing: the dark muted text shade (`gray-400`, the secondary shade, is the first Tailwind gray to reach 4.5:1 on `gray-900`, so the pass also says how muted stays apart from secondary, or that the two merge), the dark field border at rest, and the placeholder shade in both themes, on a dark sheet beside `LightSheet`; the layouts do not change, so no board needs redrawing. Waiting for /design-brief 46.

Rechecked 2026-11-17: still waiting for the design pass. docs/design-system.md has no changelog entry for this ticket (the latest, v6, is tickets 40 and 41, plus ticket 49's records correction, which changes no color). Blockers 43, 44 and 45 are deployed, so the brief can be written now. The dark shades are still as filed: the views keep dark muted text `text-gray-500` (the light theme's own shades sit under the `light:` variant), and the dark field border at rest `gray-700`. One muted use the first triage did not list has been built since: the player screen's settings button icon, drawn "in muted text" (DESIGN, Settings button). It is an icon, not text, so SPEC 10's 4.5:1 text rule does not reach it, and `gray-500` already clears 3:1 for graphics; the brief says whether it follows the muted shade or keeps its own. No conflict with the spec changes since the first triage (47 and 48's AI opponent, 49's settings partial, 52's page loads) or with open tickets 42, 47, 48 and 50 to 55: 42 is the error pages this ticket's scope already covers if it is built first, and 50's one source for theme colors is where the new muted and border shades will live once it is built.

Rechecked 2026-11-17, second time: still waiting for the design pass. docs/design-system.md has no changelog entry for this ticket; its one entry since, ticket 53's records correction, changes no text or border color. The dark shades are still as filed: muted text `text-gray-500` in eight views, the settings button icon included, the field borders at rest `border-gray-700`, the placeholders `gray-500`. Ticket 50 is built: its one source for theme colors covers the card palettes and the browser's theme-color metas, not the text and border shades, which the views still give as Tailwind classes. No conflict with the spec changes since the last recheck (53's records wording, 55's Start game and Play again, 56's current claim) or with open tickets 42, 47, 48, 54 and 57.

Decided: brief 20261119-42-46 leaves every existing board as drawn, the dark boards that show muted text, placeholders or the form fields (built by 08, 09, 10, 21, 37, 43 to 45) included, and puts the new dark shades and the light ones beside them on one new `DarkSheet` board, with the code the truth for each screen's layout, because this ticket changes three color roles and no layout. Instead of: redrawing every dark board that shows muted text from the code.

Design entry: docs/design-system.md v7, Shared: Tokens, Shared: Themes (v6) and Shared: Rules added in v7, board `DarkSheet`. Dark muted text and placeholders `muted` `#7C8390` (5.28:1 on `gray-950`, 4.88:1 on the No Set band, 4.65:1 on `gray-900`), dark field border at rest `gray-500` (3.67:1 against `gray-900`, 4.16:1 against `gray-950`), the player screen settings icon follows muted; light unchanged.

Decided: DESIGN v7 changes these rules and tokens, each one this ticket's request asked for: a new token `muted` `#7C8390`, the first outside the Tailwind palette (Shared: Tokens, and the Themes intro's "every value is from the Tailwind default palette"); Shared: Themes (v6) Text, the Muted row's dark value `gray-500` to `muted`, and a new Placeholder row; Surfaces and borders, the Field border at rest row's dark value `gray-700` to `gray-500`, dropping its stale "the boards draw `gray-400`" note; the v6 rule on muted text, now light only; the portrait tray slot numbers in muted rather than `gray-500`. Instead of: asking first, since the request and the brief decided them.

Decided: muted stays a separate role a step below secondary, not merged into `gray-400`, because merged, the footer, the empty band, "No one yet" and a locked player's row would read as loud as labels and the deck line, and dark keeps the five text steps light has. Instead of: merging muted into secondary `gray-400` (7.93:1).

Gate 2 met: docs/design-system.md v7 (commit cf36849, after the ticket was filed) covers this ticket, and its Comments hold no Design proposes, conflicts or question lines. No conflict with the undeployed spec changes (triage 42's error page rules) or with open tickets 42, 47, 48, 54, 58, 59 and 60. A search of the views, the stylesheet and the Stimulus controllers finds the muted `gray-500` places, the two placeholders and the two field borders the Scope lists, and no other.

Decided: the static error pages are out of this ticket's scope whichever of 42 and 46 is built first, because DESIGN v7's error pages hold only primary, body, the numerals and the red status name, no muted text and no form field. Instead of: keeping the earlier conditional scope on them.

Decided: SPEC 10 Visual system lists `muted` `#7C8390` beside the other stylesheet tokens, as the one color outside the Tailwind default palette, so the build defines it once as a theme token rather than as an inline hex in each view. Instead of: leaving the spec's "Tailwind default palette plus these tokens" unchanged and the token to DESIGN alone.

Decided: Priority normal, because it raises built text that is readable but under the spec's contrast on every dark screen, neither broken nor rare. Instead of: high as broken built work, or low as polish.

Decided: deep review 20261119-233807 leaves this ticket's untested criteria, the duplicated theme spec helpers and the design system's stale SPEC quote for two follow-ups, because the built classes are right and none changes what a user sees. Instead of: a pending decision.

Deferred: Behind the scenes: cover the rest of ticket 46's criteria in the system specs and share the theme spec helpers. Test that the disabled Join and Start game labels compute to `gray-500` on `gray-800` in dark; that the mode toggle's track and the settings menu keep their `gray-700` borders in dark (only the landing Join button and the tray slot are checked today); and that in light the tray slot numbers, the "/N" of the No Set count and "No one yet" compute to `gray-500`. Move the shared helpers into `spec/support/system/`: `style_of(element, property)`, now copied in `spec/system/dark_contrast/big_screen_spec.rb` and `spec/system/big_screen_theme/light_values_spec.rb`, and one `theme_cookie!(value)` for the `theme` cookie `add_cookie` line repeated in `spec/support/system/{big_screen_theme,player_screen_theme,card_colors,static_error_pages}.rb`, `dark_contrast/landing_and_join_spec.rb`, `settings_menu/device_theme_spec.rb` (twice), `settings_menu/light_values_spec.rb` and `big_screen_theme/light_values_spec.rb`; rename `dark!` in `spec/support/system/dark_contrast.rb` to `dark_device!`, since the other `light!` helpers set the cookie, not the device.

Deferred: Behind the scenes: bring the "Quoted from `SPEC.md`" part of `docs/design-system.md` (Shared: 10 Visual system) up to date with SPEC: add SPEC's `muted` `#7C8390` token bullet, and end its History line with SPEC's "which raises them to `muted` and `gray-500`". Check the rest of that quoted part against SPEC word for word and correct any other line that has drifted.
