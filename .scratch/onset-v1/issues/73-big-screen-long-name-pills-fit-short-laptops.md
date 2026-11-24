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

Decided: briefed with 48 in brief 20261124-48-73: boards at 1280×800 (light) and 1280×720 (dark) with 8 players, 5 people with names of 17 to 20 characters and 3 bots with their remove controls, one theme per board because a light screen changes colors only (DESIGN Shared: Rules added in v6), and the return gives what 1366×768, 1440×900 and 1280×1024 take. Instead of: a board per size and theme.

Decided: left every existing board alone, as for 48: the 1920×1080 waiting boards are as built (ticket 72 kept 1920), and `bot-big-waiting8-light` belongs to the unbuilt bots (tickets 68 to 70). Instead of: redrawing the waiting boards from the code.

Decided: design entry v10 (docs/design-system.md) writes the long-name layout's sizes and the width cap into Screens > Big screen, Waiting pills, and leaves where the small pill and the 1440×900 step apply to SPEC §8 Big screen, Fit, because that is behaviour triage settles (the Design proposes below). It changes no existing rule but a note that `bot-big-waiting8-light` draws the hero from before ticket 72. The canvas holds exactly the boards and title note the return lists, so no difference to record. Instead of: writing the count-based trigger into the design system before the spec decides it.

Design proposes: the small pill (34px tall, 20px text, 6px gaps) applies by the number of players and the window's height, not by how long the names are: with 7 or 8 players on a window under 820px tall (1280×800, 1366×768, 1280×720), every pill takes it. So a room of 7 or 8 short names on such a laptop also gets 20px pills, where SPEC §8 Big screen, Fit says 24px pills at 1280×800 "where they fit". Chosen because it holds by construction with CSS alone (a rule by name length cannot be guaranteed without measuring text, and with remove controls even 10-character names can reach four rows at 24px: three "Medium bot" pills and five people). The Fit sentence would need "with 7 or 8 players the pills take the small size". Rooms of up to 6 players keep the built pill.

Design proposes: with 7 or 8 players on a window 820px to 919px tall (1440×900), the pills step down to the built under-740 pill: 44px tall, 12px gaps, text stays 24px. Every other size at every height is as built.

Design proposes: from 1080px tall, every pill is capped at a third of the row (450px at 1920×1080), so 8 pills of 20-character names take at most three rows instead of four (320px in 256px of room). It changes nothing for names of up to 10 characters, which SPEC keeps as built at 1920×1080. Not drawn on a board.

Design question: 1366×768 with 5 or 6 names all over about 13 characters. Three rows of the built pill are 168px, 8px more than the 160px of room, 4px past the play area's box at top and bottom, nothing reaching the band. Left as built; dropping the list's row gap to 8px under 820px tall would close it and move 1280×800 rooms by 4px when their pills wrap.

Design question: between the named windows (740px to 761px tall, and 820px to 887px tall) the hero and Start game leave less room than the pill block needs (under 154px and under 212px). The rule fits every window the spec names; a fit at every height would need the hero's steps changed, which this brief left alone.

Design question: a window 1080px tall or more but narrow (under about 1770px wide) is not one the spec names, and a third of its row is too little for a bot's pill at 30px. Should the cap there be half the row instead?
