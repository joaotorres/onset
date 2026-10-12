# 10: Invite from the player screen waiting room

Status: needs-triage
Kind: visual
Blocked by:
Model:
Effort:

## Request

Devices-first: waiting room invite on the player screen (room code, copy or share link, QR, "Show on a big screen")

The player screen's waiting room shows the room code, a "Copy link" button (the native share sheet on phones), a QR for someone sitting next to you, and a "Show on a big screen" link to `/games/:code`. Late joining stays blocked, remote play included.

## Comments

Design gap: SPEC §8 "Phone controller" item 1 (Waiting) shows "You're in", the roster and I'm ready, with no invite. Not decided: does every player see the invite or only the creator? Which URL "Copy link" shares (the join page `/games/:code/players/join`, §5)? Web Share API on phones with copy as the fallback, and what confirms a copy? The QR's size on a phone, and whether it shows by default or behind a tap. Does "Show on a big screen" open `/games/:code` in a new tab?

Decided: every player's waiting screen shows the invite, not only the creator's, because the request names the player screen's waiting room with no limit and the big screen QR already invites anyone. Instead of: the creator's browser only (`host_game`).

Decided: Copy link shares the join page URL `/games/:code/players/join`, the one the big screen QR encodes, because a joiner lands on the name and color form either way. Instead of: the player screen or big screen URL.

Decided: the button reads Share link and opens the native share sheet where the Web Share API exists on a touch screen (`pointer: coarse`), otherwise Copy link copies to the clipboard and reads "Copied ✓" for 2s, a failed copy reading "Couldn't copy" with the code and host still on screen, because the request asks for the share sheet on phones and desktop browsers with Web Share would otherwise open a share sheet for a copy. Instead of: Web Share wherever it exists, or a toast.

Decided: the QR sits behind a Show QR tap that opens a sheet with the QR up to 18rem, the code and Done, because a QR plus 8-player roster plus invite does not fit 375×667 without page scroll (§8). Instead of: an always-visible small QR.

Decided: a room update re-rendering `#controller_status` closes an open QR sheet, one tap reopening it, because keeping it open across Turbo Stream replaces needs markup outside `#controller_status` or morphing for little gain. Instead of: a sheet that survives broadcasts.

Decided: Show on a big screen opens `/games/:code` in a new tab, because leaving the player screen mid-waiting would make the player find their way back, and Join from this computer already opens a new tab. Instead of: the same tab, as the creator's join page link does.

Decided: the invite shows the room code with "or open HOST and enter the code", the "Room CODE" footer staying, because that is the big screen's wording and the footer is shared by every state. Instead of: dropping the footer while waiting.

Decided: the 07, 08, 09, 10 brief draws every screen fresh on a new empty canvas and says the code is the truth for what it does not change, because the canvas has no boards to redraw. Instead of: first drawing the built landing, join page and player screen on the canvas from the code.
