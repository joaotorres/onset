# 02: One QR on the big screen, room code fits

Status: ready-for-agent
Kind: behavioural
Blocked by:
Model:
Effort:

## Request

Big screen: one QR only, on the waiting screen; side panel shows the room code without a QR during play; fit the room code at laptop width so it stops overlapping

Today the waiting big screen shows the hero QR (`games/_board.html.erb`) and the side panel's small QR (`games/show.html.erb`) at once. There is never a reason for both: while waiting the side panel's room tile is hidden, and during play it shows the room code without a QR, since late joining is blocked.

The overlapping text was not pinned down. Best guess: the 10rem room code running into the side panel at laptop width. Size the code with the viewport and check a screenshot at 1280px wide.

## Spec references

- §8 Views & UX > Big screen (`/games/:code`) (room tile is room code and host with no QR, hidden while waiting, shown from the start of play; fits a laptop down to 1280px wide)
- §8 Views & UX > Big screen > Waiting (the join hero holds the only QR; room code at up to 10rem, shrinking with the viewport; hero text never runs into the rail)
- §10 Cards and visual system > Visual system (QR: dark modules on a white tile, unchanged)

## Scope

Confirmed by code path: the big screen page renders the rail's room tile (small QR, code, host) in every state, and the waiting `#board` renders the 288px hero QR beside it, so the waiting screen shows two QRs. At 1280px wide the play area is about 744px; beside the 336px QR tile the hero text column is about 350px, while the 6-character code at 10rem with its tracking needs roughly 700px, so it runs under the rail.

Touches the big screen page's rail room tile, the waiting branch of the `games/board` partial and whatever broadcast keeps the room tile current when the game starts. The room tile lives outside the broadcast targets today (`#board`, `#scoreboard`, `#announcement`, `#start_button`), so showing it on start without a reload needs it rendered from a broadcast. Must not touch the player screen, the join page, the QR helper's output format, the `#board`/`#scoreboard`/`#announcement`/`#start_button` ids and the other §7 hooks, or the playing and ended layouts beyond the room tile.

## Acceptance criteria

- `GET /games/:code` for a waiting game renders exactly one QR (the 288px hero), and no room tile in the rail
- For a playing game and for an ended game it renders no QR, and the rail's room tile shows "Room", the room code and the join host
- With the big screen open on a waiting game, when the last ready vote starts the game, the room tile appears in the rail without a reload, still with no QR
- Play again (straight to playing) keeps the room tile shown with no QR
- At a 1280x800 window on a waiting game, the room code and every other line of hero text end left of the rail's left edge (bounding boxes), and the code stays on one line
- At 1920x1080 the room code still renders at 10rem
- The QR stays dark modules on a white tile

## Verification

`bundle exec rspec`

Write first: request specs in `spec/requests/games_spec.rb` counting QR `<svg>`s and checking the room tile on `/games/:code` for waiting, playing and ended games; a system spec that opens the big screen on a waiting game at 1280x800, asserts via `getBoundingClientRect` that the code and hero text end before the rail starts, then starts the game through ready votes and expects the room tile with the code and no QR. Update `spec/system/realtime_sync_spec.rb`, which reads the room code from the rail tile (`p.text-5xl`) on the waiting screen: read it from the hero instead.

## Out of scope

- A "Join from this computer" link (ticket 03), invite or share UI (ticket 10)
- Changing the hero QR's size, the scoreboard, the waiting player pills or the start button
- Resizing the playing card grid or the announcement band for laptops
- Renaming user-facing text to "big screen" / "player screen" (ticket 12)

## Comments

Decided: the room tile shows in the ended state as well as playing (code and host, no QR), because late joining is blocked there too and the code still identifies the room. Instead of: hiding it after the game ends.

Decided: the room code sizes with the viewport (capped at 10rem) and the QR stays 288px, because the QR has to scan from the couch and only the text overflows. Instead of: shrinking the QR at laptop width.

Decided: the fit requirement covers every line of hero text, not only the code, because the request's overlap was not pinned down and the rules line's unbroken URL can overflow the same 350px column. Instead of: fixing the code alone.

Decided: the room tile becomes something a broadcast renders so it appears on start without a reload, because the waiting to playing switch happens by broadcast and the rail is outside every broadcast target today. Instead of: a full-page refresh on start.
