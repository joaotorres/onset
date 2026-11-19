# 51: Escape closes the open settings menu wherever focus is

Status: deployed
Kind: behavioural
Blocked by:
Priority: normal
Feature: Themes
Model:
Effort:
Changelog: Escape now closes the open settings menu even after a click on its blank space.

## Request

Deferred from 43. Escape closes the open settings menu wherever focus is. `layouts/_settings` binds `keydown.esc` on its wrapper div only, so after a click on blank space in the open menu (its title, padding or a legend) focus drops to the page body and Escape does nothing (SPEC §8 Settings menu, "Closing it: Escape"). Bind it on the document (`keydown.esc@document->settings#escape`; `escape()` already checks the menu is open), so all five screens get it from the one partial, and add a system spec that clicks the menu's title and then presses Escape.

## Spec references

No spec change: the spec already says Escape closes the menu, with no condition on where focus is; the code falls short of it. The headings that cover it:

- SPEC.md, 8. Settings menu (Closing it: "Escape ... Escape and the close button return focus to the settings button")
- SPEC.md, Shared: 7. Realtime > Hooks that must survive any markup change (Settings menu, `data-controller="settings"` in `layouts/_settings`)

## Scope

- `layouts/_settings`: the Escape action listens on the document (`keydown.esc@document->settings#escape`) in place of the wrapper's own `keydown.esc`, so one Escape calls `escape()` once, wherever focus is on the page. The `turbo:before-cache@document` action stays as it is
- `settings_controller.js`: `escape()` keeps closing only an open menu and returning focus to the settings button; it does nothing, and moves no focus, when the menu is closed
- One partial serves all five screens (landing, How to play, join page, big screen, player screen), so no per-page change
- Must not touch: the tap-outside shield and its rule that a tap outside leaves focus where it was, the close button, the menu's markup, look and placement, SPEC 7's other hooks, the QR sheet (a native `<dialog>`, which closes on Escape on its own)

## Acceptance criteria

- With the menu open, a click on its title (blank text, no control) leaves focus on the page body, and Escape then closes the menu: the dialog is hidden, the settings button reads `aria-expanded="false"` and has focus
- Escape with focus on a radio in the menu still closes it and returns focus to the settings button, as now (the existing closing spec passes unchanged)
- With the menu closed, Escape does nothing: the menu stays hidden and focus stays where it was
- The settings partial carries no element-level `keydown.esc` action, only the document one

## Verification

`bin/test-all && bundle exec standardrb`

Tests first, in `spec/system/settings_menu/closing_spec.rb` (headless Chrome):

- Open the menu on the landing, click the menu's "Settings" title, check `document.activeElement` is `body`, press Escape on the page (not on an element), expect the menu closed and focus on the settings button. Red before the change
- With the menu closed and focus on another control (the room code field), press Escape: the menu stays hidden and focus stays on that field

## Out of scope

- Escape on any other overlay, or new keyboard shortcuts
- Trapping focus inside the open menu, or any change to Tab order
- The partial's `variant:` refactor (50) and the menu's other untested paths (53)

## Comments

Decided: no spec change, because SPEC 8 Settings menu already says Escape closes the menu with no condition on focus, and this ticket makes the code match. Instead of: adding "wherever focus is" to the spec.

Decided: the fix covers only the settings menu's Escape binding, because a search of the views and Stimulus controllers finds no other `keydown` or Escape handler; the one other overlay, the waiting screen's QR sheet, is a native `<dialog>` that closes on Escape by itself. Instead of: widening the scope to other overlays.

Decided: the wrapper's `keydown.esc` is replaced, not kept beside the document one, because the document listener already hears keys from inside the menu, and one binding means one call per Escape. Instead of: keeping both.

Decided: no blocker on 50, because 50 rewrites the partial's class cascades and this ticket changes one action on the wrapper; whichever builds second keeps the other's edit. Instead of: blocking one on the other.

Decided: Priority normal, Feature Themes (ticket 43's), Model left empty, because it is broken behaviour in built work but only on a keyboard path after a click on blank space, and the fix is one Stimulus action with a system spec. Instead of: high, or Model: fable.
