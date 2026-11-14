# 40: Dark mode, with a settings menu to toggle it

Status: needs-triage
Kind: visual
Blocked by:
Priority:
Model:
Effort:
Changelog:

## Request

Add a dark mode, toggled from a new settings menu.

Settled in conversation:
- The setting is stored per device in the browser (localStorage or a cookie), not on `Player`: onset is guests-only until v1.5, so no schema change. Dark mode defaults to the OS setting until the player chooses.
- The settings menu is new and is meant to hold more options later; ticket 41 (colour-blind palette) adds its option there.
- Stack stays Hotwire (Stimulus) and Tailwind only.

## Comments
