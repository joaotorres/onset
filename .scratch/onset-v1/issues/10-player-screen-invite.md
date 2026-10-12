# 10: Invite from the player screen waiting room

Status: needs-triage
Kind: visual
Design gap: yes
Blocked by:
Model:
Effort:

## Request

Devices-first: waiting room invite on the player screen (room code, copy or share link, QR, "Show on a big screen")

The player screen's waiting room shows the room code, a "Copy link" button (the native share sheet on phones), a QR for someone sitting next to you, and a "Show on a big screen" link to `/games/:code`. Late joining stays blocked, remote play included.

## Comments

Design gap: SPEC §8 "Phone controller" item 1 (Waiting) shows "You're in", the roster and I'm ready, with no invite. Not decided: does every player see the invite or only the creator? Which URL "Copy link" shares (the join page `/games/:code/players/join`, §5)? Web Share API on phones with copy as the fallback, and what confirms a copy? The QR's size on a phone, and whether it shows by default or behind a tap. Does "Show on a big screen" open `/games/:code` in a new tab?
