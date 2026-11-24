# 73: Big screen waiting pills with long names fit laptops 800px tall and shorter

Status: needs-triage
Kind: visual
Blocked by:
Priority:
Feature:
Model:
Effort:
Changelog:

## Request

Deferred from 72. On the big screen at 1280×800 and shorter, keep the waiting play area inside the window with 8 players whose names run to 20 characters, whose pills wrap to four rows at 1280 wide, without the QR going under 160px.

## Comments

Decided: Kind visual, because fitting the pills needs a pill layout the design system does not draw (columns, truncation or smaller text), and the choice between them is one a user would notice. Instead of: behavioural, as 72 was.

Decided: SPEC §8 Big screen, Fit covers 8 names of up to 20 characters (the §4 limit) instead of 10, with a History line, because the request is a change a user would notice and the bullet said long names were not fitted yet. Instead of: no spec change.

Decided: the fit for long names holds on every window from 1280×720 up, as the Fit bullet already promises (tested at 1280×720, 1366×768, 1280×800, 1440×900 and 1280×1024), not only at 1280×800 and shorter, because the same four rows of pills take height at every window the bullet names and a fix covers the whole flaw. Instead of: only the heights the request names.

Decided: a pill shows the whole name where the design's long-name layout fits it, and a name that still does not fit truncates with an ellipsis, the dot, ✓, bot mark and remove control always in full, because the rail's rows and the player screen's lists already truncate names, and only the winner's announced name is never cut (SPEC §8 Big screen, Fit); the design pass chooses the layout (columns, smaller text or both). Instead of: never truncating, which with the 160px QR floor leaves no fit at 1280×720.

Decided: the No Set and claiming headlines' long names (DESIGN Open questions) and the rail's rows stay out, because the rail already truncates and the headlines are the band, not the play area, and wait for a request of their own as DESIGN says. Instead of: folding them in.

Waiting for the design pass: docs/design-system.md has no changelog entry for this ticket (its entries since the filing, v8's ticket 65 records correction and v9's ticket 76 locked-entry fix on the player screen, design nothing for the big screen's pills; rechecked 2026-11-24, no spec change since the last deploy and no open ticket's request conflicts). Spec settled in SPEC.md §8 Big screen, Fit. Missing: the waiting pills' long-name layout on the big screen, 8 players with 20-character names (bots among them with the bot mark, and room for ticket 48's remove control on a bot's pill), at 1280×800 and 1280×720 in both themes, the QR at least 160px and nothing under the announcement band: how the pills lay out (columns, smaller text or both), their text size at each height, and where a name truncates. Best drawn in one round with 48, which also changes the waiting pills: `/design-brief 48 73`.
