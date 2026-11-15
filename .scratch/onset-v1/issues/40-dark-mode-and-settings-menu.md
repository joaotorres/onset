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

Decided: the user chose on 2026-11-15 that, since every screen is already dark (SPEC 10, Visual system), this ticket adds a light theme that follows the device's light or dark setting until the player picks one in the settings menu, so dark devices look as today; SPEC 10 now has two themes (Visual system, Themes). Instead of: a light theme defaulting to dark, only the settings menu, or wontfix.

Decided: the theme is a `theme` cookie (`light` or `dark`, a year, SameSite Lax, deleted for Match device) that the layout renders on `<html>`, because the server then paints the right theme first with no inline script and no flash, and Match device is CSS alone. Instead of: localStorage, which the server cannot read, so the page would flash the other theme before a script ran.

Decided: the menu offers Match device, Light and Dark, Match device the default, because with a two-way toggle a player who picked once could never go back to following the device. Instead of: a Light/Dark toggle.

Decided: a device that states no light or dark preference gets dark, because dark is the look every screen has today. Instead of: light.

Decided: the settings menu is on every page the app renders, the big screen and the player screen included, its place and how it opens left to the design pass, outside every Turbo Stream target so a room update never closes it, because the theme is per browser and the big screen runs on a browser of its own. Instead of: the landing only.

Decided: the cards, card palette, player colors, color meanings, QR tile, layouts and animations stay the same in both themes, the light theme only allowed other shades of a meaning color for contrast, because SPEC 10 says the card partial is never restyled and the meaning table holds everywhere. Instead of: a light card face or recoloured cards.

Decided: picking a theme sends `theme_changed` with `theme` (`device`, `light`, `dark`), added to SPEC 17 Custom events, and the cookie is noted in SPEC 17 Privacy as needing no consent, because CLAUDE.md asks for an event per new user-facing action. Instead of: no event.

Decided: GLOSSARY gains Settings menu and Theme, Theme avoiding "mode", which already names Standard and First to 5. Instead of: calling it dark mode.

Decided: the split waits for the triage after the design entry, as ticket 09's did, because a child briefed now would be ready before its screens are drawn and gate 2 would fail it. Expect a split by screen (shared theme mechanism and settings menu with the landing, join page, How to play and footer; then the player screen; then the big screen). Instead of: splitting now into children with no design.

Waiting for the design pass: docs/design-system.md has no changelog entry for this ticket (the latest, v5, is ticket 37's). The brief draws the light theme of every screen and the settings menu on each. The board's check counts the shape-records commit 6f3bf0c as the design pass, which it is not, so start the brief with `/design-brief 40`.

Deferred: Static error pages (404, 422, 500 and the others in public/) follow the device's light or dark setting, as the app's own pages do since the light theme.

Decided: the static error pages stay dark and are deferred to a request of their own, because they cannot read the theme cookie and nobody plays on them. Instead of: folding them into this ticket.
