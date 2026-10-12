# 10: Invite from the player screen waiting room

Status: ready-for-agent
Kind: visual
Blocked by:
Model:
Effort:

## Request

Devices-first: waiting room invite on the player screen (room code, copy or share link, QR, "Show on a big screen")

The player screen's waiting room shows the room code, a "Copy link" button (the native share sheet on phones), a QR for someone sitting next to you, and a "Show on a big screen" link to `/games/:code`. Late joining stays blocked, remote play included.

## Spec references

- §8 Views & UX > Player screen (`/games/:code/controller`) > 1. Waiting (the roster, I'm ready, alone in the room, the invite: room code and `join_host` line, Copy link / Share link, Show QR, Show on a big screen, no page scroll)
- §8 Views & UX > Player screen: the three layouts, chosen by the viewport alone, and the "Room CODE" footer
- §7 Realtime > Hooks that must survive any markup change: `#controller_status` and the `invite` controller's attributes
- §5 Routes: `GET /games/:code/players/join` (the shared URL), `GET /games/:code` (the big screen), `POST /games/:code/ready`
- §10 Cards and visual system > Visual system (the meaning table: green and red are not used for the copy feedback)
- docs/design-system.md v2: `players/controller/_roster`, `_invite`, `_qr_sheet`, Screens > Player screen, Waiting (ticket 10), Rules added in v2 (`green-700` under white text, neutral Copy link feedback), Visual rules (QR dark on white). Boards: waiting-p-1, Waiting, waiting-p-voted, waiting-p-failed, waiting-p-share, waiting-p-qr, waiting-l-1, waiting-l-8, waiting-l-voted, waiting-l-qr, waiting-c-1, waiting-c-8, waiting-c-voted, waiting-c-qr (canvas link in docs/design-handoff.md)

## Scope

The waiting branch of the player screen status (`#controller_status` while `Game#waiting?`), split into new `players/controller/_roster`, `_invite` and `_qr_sheet` partials, plus a new `invite` Stimulus controller. Reuse `join_qr_svg` and `join_host` from the games helper for the QR and the host line, and `join_game_players_url` for the shared URL. The QR sheet lives inside `#controller_status`, so a broadcast replacing it closes the sheet.

Do not touch: the playing and ended branches (tickets 14 to 16 and 07), the header partial's markup, the ready vote logic (`Game#vote_start!`, `start_voters`, the 2-player minimum), the big screen and its join hero, the join page, any model, route or controller behaviour.

## Acceptance criteria

- Waiting shows, in order: the header, "You're in", the roster, the invite, then I'm ready or its replacement. The "Room CODE" footer stays
- Every player in a waiting room sees the invite, not only the creating browser; the invite is gone once the game is playing or ended
- The roster is two columns, each entry a dot, the name, "you" for the viewer and a `green-400` ✓ once ready
- I'm ready is `green-700` with white text. Once voted: "Ready ✓ · waiting for n more", outlined `green-700` on a 12% `green-700` tint with `green-300` text
- With one player in the room there is no I'm ready button: "Waiting for more players to join…" takes its place
- The invite shows the room code in display type and "or open HOST and enter the code" with HOST from `join_host`
- The link button carries the join page URL (`/games/:code/players/join`, absolute) as the `invite` controller's `url` value. Without a touch screen or Web Share, it reads Copy link; a click writes that URL to the clipboard and the button reads "Copied ✓" for 2s, then Copy link again. A failed write reads "Couldn't copy" for 2s. Both feedback states stay neutral gray, never green or red
- Where `navigator.share` exists and `matchMedia("(pointer: coarse)")` matches, the button reads Share link and a click calls `navigator.share` with the join URL and the title "Room CODE". A cancelled share (AbortError) leaves the button as it was
- Show QR opens a `<dialog>` sheet with the join URL's QR on a white tile (288px portrait and computer, 300px landscape, never over 18rem), the room code under it and Done (`blue-600`), which closes it. Portrait: a bottom sheet; landscape: a centered card, QR left, code and Done right; computer: a centered 352px modal. Overlay `gray-950` at 85%
- A broadcast that re-renders `#controller_status` (another player joins or votes) closes an open sheet; Show QR reopens it
- "Show on a big screen →" is a text link to `/games/:code` with `target="_blank"`
- Landscape and computer put the roster and the invite side by side
- With 8 players there is no page scroll (document scroll height equals the viewport) at 375×667, 667×375 and 1024×640, with the sheet closed and open

## Verification

`bundle exec rspec`

Write first:
- request specs in `spec/requests/games_spec.rb` for `GET /games/:code/controller` on a waiting game: the code and "or open HOST and enter the code", the `invite` controller with the absolute join URL as its `url` value, a QR SVG inside the `<dialog>`, the big screen link's href and `target="_blank"`, the invite shown to a player who is not the creating browser, no invite on a playing or ended game, and with one player "Waiting for more players to join…" and no I'm ready button
- a system spec (new `spec/system/waiting_invite_spec.rb`): stub `navigator.clipboard.writeText` with `execute_script`, click Copy link and see "Copied ✓", then a rejecting stub and "Couldn't copy"; open the sheet with Show QR, close it with Done; open it again, join another player and see the sheet closed; with 8 players, resizing as `spec/system/big_screen_spec.rb` does, no page scroll at 375×667, 667×375 and 1024×640
- the Share link path in the same spec: before the visit, use `page.driver.browser.execute_cdp` (`Emulation.setTouchEmulationEnabled`, and `Page.addScriptToEvaluateOnNewDocument` to stub `navigator.share`) so the button reads Share link and a click calls the stub with the join URL

## Out of scope

- The big screen's Start game and Play again on `green-600` (the known gap in docs/design-system.md, a later request)
- Late joining or any invite once play has started
- Keeping the QR sheet open across broadcasts (morphing, markup outside `#controller_status`)
- A toast, a share count or any analytics on shares
- Changing the ready vote rules or letting one player start alone
- Redrawing boards on the canvas

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

Design question: with 1 player in the room, can the creator cast the ready vote alone? If so "Ready ✓ · waiting for 0 more" reads wrong. Proposal: "Ready ✓ · waiting for others to join".

Decided: docs/design-system.md v2 adds the rule that white text on green uses `green-700`, the big screen's Start game and Play again staying on `green-600` as a known gap for a later request, decided by the user, because the big screen is outside tickets 07 to 10. Instead of: a player-screen-only rule, or folding the big screen buttons into this ticket.

Decided: with one player in the room no I'm ready shows and "Waiting for more players to join…" takes its place, written into SPEC §8 Player screen > 1. Waiting, because the code already does this and §5 needs 2+ voters, so "waiting for 0 more" never shows. Instead of: letting a lone player vote with "Ready ✓ · waiting for others to join".

Decided: the invite is driven by one `invite` Stimulus controller with `url` and `code` values, a `link` target and a `<dialog>` `sheet` target inside `#controller_status`, written into SPEC §7 hooks, because §7 asked for the controller's attributes and a native dialog gives Done, Escape and the overlay without extra markup. Instead of: leaving the names to the build, or a hidden div toggled by class.

Decided: no blocker on tickets 14 to 16, because they leave the waiting branch alone and this ticket builds the waiting computer layout itself. Instead of: blocking 10 on 16.
