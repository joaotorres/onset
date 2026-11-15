# 49: Bring the records in line with the built settings menu

Status: done
Kind: behavioural
Blocked by:
Priority: low
Feature: Themes
Model:
Effort:
Changelog: Behind the scenes: the design records now match where the built settings menu opens and its size, and system specs pin where it opens.

## Request

Deferred from 43. Behind the scenes: bring the records in line with the built settings menu. SPEC §7 Hooks (Settings menu) and DESIGN v6 Settings button and Settings menu say the `settings` controller and menu sit "in the layout", but each page's view renders `layouts/_settings` (this ticket's Decided line, and 44 and 45 outside their broadcast targets); reword all three. And measure the player screen menu's offset from the bottom in portrait and on computer (play, Waiting, Game over) and write the built values into DESIGN Settings button placement, which says 36px and 60px while the classes give about 46px to 48px.

## Spec references

- SPEC.md, Shared: 7. Realtime > Hooks that must survive any markup change (Settings menu): reworded by this triage to say each page's own view renders the `layouts/_settings` partial, outside every hook root. Nothing else in SPEC changes
- SPEC.md, 8. Settings menu (Opening it, Outside every broadcast target): already right, unchanged
- docs/design-system.md v6: Components > Settings button, Settings menu; Screens > Settings button placement (tickets 40, 41); Changelog

## Scope

A records-only ticket: the code is the truth here, and no view, CSS or controller changes.

- **DESIGN, Components > Settings button and Settings menu:** replace "In the layout, outside every broadcast target" and "In the layout with its button, outside every broadcast target" with wording that says the `layouts/_settings` partial is rendered by each page's own view, outside every broadcast target, matching the SPEC §7 line as it now reads
- **DESIGN, Screens > Settings button placement:** measure, in headless Chrome, the open menu's distance from the window's bottom edge on the player screen in portrait (375×667) and on computer (1024×640) during play, in Waiting and in Game over, and write the measured values into the portrait and computer lines in place of 36px and 60px. The classes in `controllers/show.html.erb` and `layouts/_settings` give 10 + 28 + 8 = 46px for portrait and computer play and 8 + 32 + 8 = 48px for the computer Waiting and Game over footers: if the measurement differs, the measurement wins. Portrait gets one value if it is the same in every state, as the line says now
- **DESIGN, Components > Settings menu size:** the "304×290" was drawn before the built menu settled with both fieldsets. Measure the open menu's rendered width and height (dark theme, any page) and write the built size there if it differs
- **DESIGN, Changelog:** one entry, `v6, <date>: ticket 49, ...`, saying the records were corrected to the build, with no version bump, since nothing new is designed
- **A system spec** that pins the measured player screen menu offsets (right and bottom, as `spec/system/big_screen_theme/menu_spec.rb` pins the big screen's 40px and 108px), so a later class change that drifts from DESIGN fails
- Must not touch: any file under `app/`, `SPEC.md` (already reworded), the canvas boards

## Acceptance criteria

- No sentence in `SPEC.md` or `docs/design-system.md` says the settings button, the settings menu or the `settings` controller sit "in the layout"; both name the `layouts/_settings` partial rendered by each page's own view, outside every broadcast target
- DESIGN Settings button placement gives the menu's offset from the bottom as measured: portrait (every state), computer play, and computer Waiting and Game over each carry a value that matches the new system spec, and no 36px or 60px remains there unless measured
- DESIGN Settings menu gives the built menu's size as measured
- A new system spec opens the menu on the player screen in portrait (375×667, play, Waiting and Game over) and on computer (1024×640, play, Waiting and Game over) and asserts its right and bottom offsets from the window, within 1px, at the values DESIGN now gives
- DESIGN's Changelog has the ticket 49 entry, and its title still reads version 6
- `git diff` of the build touches no file under `app/`

## Verification

`bin/test-all && bundle exec standardrb`

Tests first: the system spec for the player screen menu offsets, written with the values the classes give (46px and 48px, 8px from the right in portrait, 40px from the right in the computer Waiting and Game over footers). It is green from the start, because this ticket changes no code: record that as a `Decided:` line instead of a red run. If a value differs, correct the spec to the measurement and write that value into DESIGN. Keep the file under 8 s, splitting it by layout if needed.

## Out of scope

- Moving the settings partial into the layout file, or any other change to where or how the menu renders
- The landscape player screen's menu offset: DESIGN gives none there, so nothing drifts
- Redrawing the canvas boards to the measured values
- Any other DESIGN or SPEC rewording beyond the three "in the layout" mentions, the placement offsets and the menu size

## Comments

Decided: triage rewords SPEC §7 Hooks (Settings menu) now, and the build rewords DESIGN and writes the measured values, because gate 1 wants the spec change committed before the brief, and the measurements need a browser. Instead of: triage writing DESIGN values computed from the classes without measuring.

Decided: the menu's built size (DESIGN "304×290") is in scope, because it is the same drift between the DESIGN Settings menu record and the build, from the Card colors fieldset added in 41. Instead of: leaving it for a request of its own.

Decided: the build pins the player screen menu offsets in a system spec, as the big screen's already are, because a measurement nothing checks drifts again. Instead of: measuring once in a throwaway script.

Decided: the DESIGN fix gets a v6 Changelog entry with no version bump, because nothing new is designed and no visual ticket waits on it. Instead of: bumping DESIGN to v7.

Decided: Priority low, because no user notices a records fix. Instead of: normal.

Decided: the offset specs were green on their first run with no red step, because this ticket changes no code and the classes' values (46px, 48px) matched the measurement. Instead of: forcing a red run against wrong values.

Decided: the offset specs are two files, portrait and computer, and computer play pins the right offset to the board column's right edge rather than a number, because DESIGN states it that way. Instead of: one file, or a fixed pixel value that changes with the board width.

Decided: the menu's measured size is 304×278 (dark, player screen), written into DESIGN; it is not pinned in a spec, because the ticket asks only for the offsets to be pinned. Instead of: a size assertion.
