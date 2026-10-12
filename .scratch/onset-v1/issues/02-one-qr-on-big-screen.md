# 02: One QR on the big screen, room code fits

Status: needs-triage
Kind: behavioural
Blocked by:
Model:
Effort:

## Request

Big screen: one QR only, on the waiting screen; side panel shows the room code without a QR during play; fit the room code at laptop width so it stops overlapping

Today the waiting big screen shows the hero QR (`games/_board.html.erb`) and the side panel's small QR (`games/show.html.erb`) at once. There is never a reason for both: while waiting the side panel's room tile is hidden, and during play it shows the room code without a QR, since late joining is blocked.

The overlapping text was not pinned down. Best guess: the 10rem room code running into the side panel at laptop width. Size the code with the viewport and check a screenshot at 1280px wide.

## Comments
