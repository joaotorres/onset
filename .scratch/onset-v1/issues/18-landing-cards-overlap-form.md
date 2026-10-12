# 18: Landing cards overlap the start game form at narrow desktop widths

Status: needs-triage
Kind: behavioural
Blocked by:
Model:
Effort:

## Request

Reducing the screen size on the desktop makes an image overlap with the start game form, let's fix it.

From the screenshot (browser window about 800px wide, production): the desktop landing layout still applies, the brand column has shrunk so the tagline wraps to one or two words a line, and the three fanned example cards spill out of it over the Start a game card, covering "Have a room code?" and the code field.

## Comments

Decided: behavioural, because the desktop and phone landing layouts both already exist in docs/design-system.md (Landing, ticket 08) and the fix is which one applies at mid widths and keeping the cards inside their column. Instead of: visual.
