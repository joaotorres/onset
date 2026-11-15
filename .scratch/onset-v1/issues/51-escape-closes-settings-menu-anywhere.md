# 51: Escape closes the open settings menu wherever focus is

Status: needs-triage
Kind: behavioural
Blocked by:
Priority:
Feature:
Model:
Effort:
Changelog:

## Request

Deferred from 43. Escape closes the open settings menu wherever focus is. `layouts/_settings` binds `keydown.esc` on its wrapper div only, so after a click on blank space in the open menu (its title, padding or a legend) focus drops to the page body and Escape does nothing (SPEC §8 Settings menu, "Closing it: Escape"). Bind it on the document (`keydown.esc@document->settings#escape`; `escape()` already checks the menu is open), so all five screens get it from the one partial, and add a system spec that clicks the menu's title and then presses Escape.

## Comments
