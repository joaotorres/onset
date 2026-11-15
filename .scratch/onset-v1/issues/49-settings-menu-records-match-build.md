# 49: Bring the records in line with the built settings menu

Status: needs-triage
Kind: behavioural
Blocked by:
Priority:
Model:
Effort:
Changelog:

## Request

Deferred from 43. Behind the scenes: bring the records in line with the built settings menu. SPEC §7 Hooks (Settings menu) and DESIGN v6 Settings button and Settings menu say the `settings` controller and menu sit "in the layout", but each page's view renders `layouts/_settings` (this ticket's Decided line, and 44 and 45 outside their broadcast targets); reword all three. And measure the player screen menu's offset from the bottom in portrait and on computer (play, Waiting, Game over) and write the built values into DESIGN Settings button placement, which says 36px and 60px while the classes give about 46px to 48px.

## Comments
