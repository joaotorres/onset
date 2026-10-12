Design return for tickets 07, 08, 09, 10.

## New tokens
None. Every color is from the Tailwind default palette or the existing tokens.

## New components
- players/controller/_scoreboard: shared play scoreboard. Portrait: 4 chips per row (max 2 rows), the Locked tag as a red badge on the chip's top-right corner. Landscape and computer: one row per player, Locked tag inline before the score. Own entry gray-800 with a gray-500 border, claiming entry solid yellow-400 with gray-950 text, locked entry content at 45% opacity.
- players/controller/_status_panel: one fixed slot above SET! (portrait 64px tall, landscape 144x104, computer 248x76). Variants: claim bar (yellow-400, ring, "Your SET!", "Tap 3 cards", n/3), someone else ("Alex is calling SET!", gray-900 with a yellow-400 border), No Set (purple-950 with a purple-500 border, ring, "No Set called by Alex", "n/m agreed"), locked (red-950 with a red-600 border, "Wrong! −1" or "Time's up! −1").
- players/controller/_found_banner: green-950 panel with a green-500 border, 3 mini cards, caller dot, "Alex found a Set", "+1" in green-400. Absolutely positioned over the top of the board area (portrait: over the scoreboard). pointer-events none, .found-set-flash.
- players/controller/_roster: two-column roster for Waiting with dot, name, "you" and a green-400 ✓ for ready.
- players/controller/_invite: room code in display type, "or open onset.joaotorr.es and enter the code", link button (Copy link / Copied ✓ / Couldn't copy / Share link), Show QR button, "Show on a big screen →" text link.
- players/controller/_qr_sheet: overlay gray-950 at 85%. Portrait: bottom sheet. Landscape: centered card with the QR left and code + Done right. Computer: centered 352px modal. QR on a white tile (288px portrait and computer, 300px landscape), code under it, Done in blue-600.
- players/controller/_standings: game over rows (rank, dot, truncated name, "you", score). Own row gray-800 with a gray-600 border.
- Landing mode toggle: two radios styled as a segmented control inside one form. Selected Standard is gray-700, selected First to 5 is violet-600.

## New or changed rules
- White text on green uses green-700 (#15803D). green-600 is about 3.3:1, same reasoning as orange-700. Applies to I'm ready and Play again.
- Filled purple pills (No Set, I agree, no Set) use purple-700 for white text. The agreed waiting text is outlined purple-500 with purple-200 text.
- Card face #FAFAFA with a #E5E5E5 border. Selected card: 4px blue-400 ring + scale 0.95. Arrive: 3px green-400 ring.
- Taken color swatch: preset blended 30% over gray-950 with the taker's initial in gray-300 (opacity would also fade the initial).
- Portrait play keeps the status slot at a fixed 64px in every state, empty in idle, so the board never resizes on a state change.
- Card sizes at 8 players / 18 cards: portrait 54x76, landscape 55x77, computer 106x148. Portrait 3/12: 71x99. Formula: cw = floor(min((boardW - (cols-1)*gap)/cols, ((boardH - 2*gap)/3) * 5/7)), cols = cards/3. Gap 5px on phones, 12px on computer.
- Play SET! slot is 128x128 everywhere (button 104, 108 on computer). Ring states use a 128 ring around a 100 disabled gray-800 button.
- Copy link feedback states stay neutral gray, since green and red are reserved by the meaning table.

## Decisions the spec does not cover
1. Computer play: the scoreboard is stacked above the state panel, SET! and pill in a 248px side column, not beside it. Cards grow from about 84px to 106px wide at 18 cards.
2. Landscape play at 18 cards: cards shrink to fit the board width (55x77) so there is no sideways scroll. At 12 cards they fill the height. §10 says landscape "fills the height and scrolls sideways".
3. Portrait claiming (mine): the yellow claim bar takes the status slot and the 3-slot tray replaces SET! and its pill. Landscape and computer: one yellow block replaces the panel and SET!, and the pill slot is empty.
4. Someone else claiming: the disabled SET! shows the seconds large with a small "SET!" label under them.
5. Locked out: the No Set pill stays enabled, since lockout only blocks SET!.
6. Portrait found-set banner covers the scoreboard for its 3s, so the caller's +1 shows once it fades. The board under it shows the replaced cards with the arrive outline.
7. Read-only boards (someone else claiming, No Set, locked out) are not dimmed.
8. Landing on phones: wordmark + tagline, then the join form, then mode + Start a game, then the fanned cards and caption at the bottom.
9. "Room not found" sits under the code field, with the field red-bordered and empty after the redirect.
10. Join copy where the code may differ (the code wins): "Name can't be blank", "That name is already taken in this room", "That color was just taken, so the next free one is picked", base error "This game has already started".
11. Waiting keeps the "Room K7QF3M" footer even though the invite shows the code large.
12. Share link is drawn on the landscape boards (touch). Copy link is drawn on computer and in the default portrait board.

## Open questions
1. Waiting with 1 player: can the creator vote alone? If yes, "Ready ✓ · waiting for 0 more" reads wrong. Proposal: "Ready ✓ · waiting for others to join".
2. Join with every color taken: the room is full and Join can only fail. Proposal: base error "This room is full" and Join disabled. Drawn as the spec says for now.
3. Game over rank when tied for first: drawn as "1st" with "Tied for first" under it. Should it read "=1st" or similar?
4. Winner line when the viewer wins: drawn with the name ("★ Ada wins with 7"). Should it say "You"?

## Artboards added or changed
All new. Components (each also a board, with state tweaks): Main.dc.html (landing), Join.dc.html, Waiting.dc.html, PlayPortrait.dc.html, PlayLandscape.dc.html, PlayComputer.dc.html, GameOver.dc.html.
1. Landing: landing-phone, landing-phone-quick, landing-phone-notfound, Main (desktop Standard), landing-desktop-quick, landing-desktop-notfound.
2. Join: Join (joiner), join-creator, join-name-blank, join-taken, join-started, join-full.
3. Waiting portrait: waiting-p-1, Waiting (8 players, Copy link), waiting-p-voted (Copied ✓), waiting-p-failed, waiting-p-share, waiting-p-qr.
3. Waiting landscape and computer: waiting-l-1, waiting-l-8, waiting-l-voted, waiting-l-qr, waiting-c-1, waiting-c-8, waiting-c-voted, waiting-c-qr.
4. Play portrait 8/18: PlayPortrait (idle), play-p8-deck-empty, -claiming, -other, -noset, -agreed, -wrong, -timeup, -found, -arrive.
4. Play portrait 3/12: play-p3-idle, -deck-empty, -claiming, -other, -noset, -agreed, -wrong, -timeup, -found, -arrive.
4. Play landscape 8/18: PlayLandscape (idle), play-l-deck-empty, -claiming, -other, -noset, -agreed, -wrong, -timeup, -found, -arrive.
4. Play computer 8/18: PlayComputer (idle), play-c-deck-empty, -claiming, -other, -noset, -agreed, -wrong, -timeup, -found, -arrive.
5. Game over portrait: GameOver (2nd, before voting), gameover-p-voted, -tie, -win, -long.
5. Game over landscape and computer: gameover-l-second, -voted, -tie, -win, -long; gameover-c-second, -voted, -tie, -win, -long.
