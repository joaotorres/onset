# 40: Dark mode, with a settings menu to toggle it

Status: split
Kind: visual
Blocked by:
Priority: normal
Model:
Effort:
Changelog:
Split: yes

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

Deferred: Static error pages (404, 422, 500 and the others in public/) follow the device's light or dark setting, as the app's own pages do since the light theme. Filed as 42.

Decided: the static error pages stay dark and are deferred to a request of their own, because they cannot read the theme cookie and nobody plays on them. Instead of: folding them into this ticket.

Decided: brief 20261115-40-41 leaves every existing board as drawn and adds the light theme, settings menu and card colors boards beside them, because the light theme only recolours (SPEC 10 Themes keeps the layouts) and the brief describes as the truth what the code changed since the boards: the byline footer on the landing and join boards (tickets 24, 26), the narrow-desktop fanned cards (18), the computer "Room CODE" footer under the deck line (22), the 15 s lockout ring (20), the -win winner line (triage 07) and How to play's 944px box (39); the boards of tickets 21 and 37, still marked exploring in the handoff doc, are of deployed tickets and stay too. Instead of: redrawing the landing, join, computer play, locked out and game over boards from the code first.

Design proposes: a tap outside the open settings menu closes the menu and does nothing else; it does not press what it lands on, such as SET! under the portrait menu, since a stray SET! costs a point. Instead of: the tap also reaching the control underneath.

Design proposes: the game carries on under an open settings menu. Broadcasts keep updating the board, scores and status panel and the menu stays open; on portrait it covers SET! until it is closed. Instead of: pausing the player, or closing the menu when a claim or No Set starts.

Design proposes: each settings option group is a native radio group, so the arrow keys move and pick in one step: arrowing from Match device to Dark picks Light on the way, applies it and sends `theme_changed` once per step. Instead of: arrows that only move focus, with Space or Enter to pick.

Design proposes: Escape or the close button returns focus to the settings button; a tap outside does not move focus.

Design proposes: with no theme cookie, Match device is the selected Theme option, and the menu does not say which theme the device resolved to: the page shows it.

Design question: dark muted text (`gray-500`, the "Room CODE" footer, the empty band text, tray slot numbers) measures 4.16:1 on `gray-950` and 3.67:1 on `gray-900`, below the 4.5:1 SPEC 10 holds body and secondary text to. Dark is unchanged in this round. Move the dark muted role to `gray-400`, or keep it?

Design question: field borders at rest are below 3:1 in both themes (dark `gray-700` 1.72:1, light `gray-400` 2.54:1). Raise the light one to `gray-500` (4.84:1) and the dark one to match in a later pass?

Design question: the player screen settings button is 40×28, below the 44px touch height used elsewhere, because the 28px "Room CODE" footer cannot grow without shrinking the board. It meets the WCAG 2.2 AA 24px minimum. Accept it, or give the footer 16px from the board in portrait?

Decided: the user chose on 2026-11-15 that both dark disabled No Set pills (while someone else claims, and "No Set in 12 s" after a refusal) take the readable v5 look, `purple-700` at 35% with `purple-200` text at full opacity, instead of the whole button at 35%, a deliberate exception to dark staying as it is today; the blocked pill's code broke the v5 rule already. Instead of: keeping dark as built and the light theme alone readable.

Decided: design entry v6 changes these existing rules and tokens, each asked for by tickets 40 and 41: the card palette token (two palettes, Classic the default), the taken and selected join swatches (blended over and offset by the page of each theme), the selected and arrive rings (light shades `blue-500`, `green-600`), the disabled No Set pill while someone else claims (the v5 rule), the quoted SPEC 10 Palette, Component and Visual system text (now as SPEC reads), and the open question on the 5-second lockout ring (the light boards draw 15 s). Instead of: asking first.

Decided: the canvas, not the return, is followed where they differ: the canvas adds 13 section titles, not nine, and the light own scoreboard entry has a `gray-500` border as in dark, not `gray-300` as the return's raised row says; docs/design-system.md v6 lists it as its own row. Instead of: the return's account.

Decided: the light QR tile's 1px `gray-200` inset edge, the light selected join swatch's `gray-900` ring and the light `blue-500` selected card ring are not conflicts with SPEC 10 Themes, SPEC 8 Join page ("a white ring") or SPEC 10 Palette (`ring-blue-400`): the QR modules and white tile are unchanged, a white ring cannot show on the light page the brief asked a counterpart for, and SPEC 10 Themes lets the light theme use other shades of a meaning color. Instead of: flagging each as a conflict.

Decided: the return's note that How to play's code holds `max-w-5xl`, not the 944px box, gets no question here, because ticket 39 builds that box. Instead of: a design question.

Decided: the five Design proposes go into SPEC 8 Settings menu as proposed (a tap outside only closes the menu and never reaches what it lands on; the game carries on under an open menu; native radio groups, so arrows pick and send the event per step; Escape and the close button return focus to the settings button, a tap outside does not; Match device selected with no cookie, the resolved theme never named), because each follows the spec's intent (a stray SET! costs a point, a room update never closes the menu) and the platform's own radio behaviour. Instead of: the alternatives the design entry names.

Decided: dark muted text (`gray-500`) and the dark field border at rest (`gray-700`) stay as built, because the user chose that dark stays as it is today apart from the disabled No Set pills, and SPEC 10 names `gray-500` for dark muted text; raising them is deferred below. Instead of: moving dark muted text to `gray-400` and the dark field border up in this ticket.

Deferred: In the dark theme, muted text (the "Room CODE" footer, the big screen's empty band text, the tray slot numbers) reads at 4.5:1 or more on its ground, and field borders at rest at 3:1 or more, as the light theme's do.

Decided: the dark contrast fix above is deferred to a request of its own, because it changes how every dark screen looks and this ticket keeps dark as it is. Instead of: dropping it, or folding it in here.

Decided: the light field border at rest is `gray-500` (4.84:1 on white), not the boards' `gray-400` (2.54:1), docs/design-system.md updated, because a light input sits white on a white panel and its border is all that shows the field. Instead of: keeping `gray-400`.

Decided: the player screen settings button stays 40×28 (40×32 in the computer Waiting and Game over footers), because it meets the WCAG 2.2 AA 24px minimum, is tapped rarely, and growing the footer would shrink the board that every tap of play lands on. Instead of: a footer 16px taller in portrait.

Decided: split by screen into 43 (the theme mechanism, the settings menu with its Theme option and the light landing, join page, How to play and byline footer), 44 (the player screen, with the readable dark disabled No Set pills) and 45 (the big screen), 44 and 45 blocked by 43, because the light theme of every screen and its specs do not fit one session, and each screen gets its settings button in the ticket that themes it, so no deploy shows a menu whose choice leaves its screen dark. Instead of: one ticket, or splitting by layer (CSS, then menu).

Decided: 43 is blocked by 39, because 39 rebuilds How to play's and the byline footer's box, in which DESIGN v6 draws How to play's light boards. Instead of: building 43 on the old box.

Decided: ticket 41 is now blocked by 43, 44 and 45, and 42 by 43, because a split parent never reaches done, so their `Blocked by: 40` would wait forever; 41 recolours cards on every screen and needs each screen's light theme, 42 needs only the light values 43 builds. Instead of: leaving them blocked by 40.

Split into 43, 44, 45.
