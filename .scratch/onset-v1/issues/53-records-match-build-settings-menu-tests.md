# 53: Bring the records in line with what is built and cover the settings menu's untested paths

Status: needs-triage
Kind: behavioural
Blocked by:
Priority:
Feature:
Model:
Effort:
Changelog:

## Request

Deferred from 43. Behind the scenes: bring the records in line with what is built, and cover the settings menu's untested paths. DESIGN `docs/design-system.md` Tokens (byline logo colours) says the dark byline values on `.byline-footer` are "the values every Onset screen uses", false since the light theme (SPEC §10 byline colours); DESIGN How to play says "the code still holds `max-w-5xl`", stale since ticket 39; DESIGN Settings menu placement says the menu opens "8px from it", while Settings button placement and ticket 45 give 12px on the big screen. SPEC §10 Palette "Selected card ... `ring-blue-400`" leaves out the light theme's `ring-blue-500` (ticket 44, `card_selection_controller.js`), and SPEC §8 Join page "select with a white ring" leaves out the light theme's `gray-900` ring. GLOSSARY Settings menu says "the menu on every page", while SPEC §8 and §10 leave the static error pages out. System specs for: the `theme-color` meta after a pick in the menu (only page load is checked), an open menu closed when the page is cached on navigation (`turbo:before-cache`), and a filled tray slot taking and losing `card-edge`.

## Comments
