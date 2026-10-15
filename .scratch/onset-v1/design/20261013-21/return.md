Design return for tickets 21.

## New tokens
None. Every color is from the Tailwind default palette.

## New components
None. The refusal adds variants to existing components, listed under New or changed rules.

## New or changed rules
- `players/controller/_secondary_action`, refusal pair: while the player may refuse, the pill slot holds two equal pills side by side, There's a Set on the left and I agree, no Set on the right. There's a Set is outlined: 2px `purple-400` border, no fill, white bold text. I agree, no Set stays filled `purple-700` with white text. The pair fills its column: in portrait the width of the status slot above it (351px at 375, 8px gap, 16px labels), in landscape the 9rem column (two 69×44 pills, 6px gap, 13px labels on two lines), on computer 248×46 (two 120px pills, 8px gap, 15px labels). SET! does not move
- `players/controller/_secondary_action`, blocked No Set: the No Set pill at its usual size (portrait 220×44, landscape 144×44, computer 248×46), disabled, filled `purple-700` at 35% with `purple-200` text so the seconds stay readable: "No Set in 12 s", the seconds in display type. The disabled No Set while someone else claims keeps its 35% opacity
- `players/controller/_status_panel`, new variant refused: `gray-900` with a `purple-500` border, the refuser's dot, the name bold and "says there's a Set" in `gray-300`, laid out as someone else claiming in each layout. On the refuser's own screen it reads "You say there's a Set" with their own dot
- `games/_announcement`, Refused panel: the No Set panel's tint, ring and type. The ring counts the block down (`purple-400` progress, `purple-300` seconds), "Alex says there's a Set" in 48px display bold with the name in `purple-400`, "No Set is back when the ring runs out" in 24px `gray-300`. Nothing on the right
- Locked out during a No Set countdown: SET! shows the lockout ring with the seconds and "Locked", as in Locked out. The code shows a plain disabled SET! there today

## Decisions the spec does not cover
1. I agree, no Set sits on the right, where iOS and Android put the confirming answer and the right thumb rests. There's a Set goes on the left.
2. The two answers differ in lightness, filled against outlined, so they tell apart at a glance and both stay purple. The outlined waiting text after agreeing never shows beside them.
3. Portrait widens the pill slot from 220 to the status slot's width while the pair shows, so both labels fit on one line at 16px. Landscape has no room to stack two 44px pills without moving SET!, so its labels wrap.
4. Refusal already used: the lone I agree, no Set sits as the existing board shows (220×44, centered), so it has no board.
5. The refused status panel is `gray-900` with a purple border, not `purple-950`, so it doesn't read as a call still running.
6. On player screens the block's seconds show once, in the pill. The status panel has no ring.
7. The refuser's own screen reads "You say there's a Set", as "You agreed" and "You called No Set" do. It is drawn as Alex's screen, with Alex's color strip and own chip.
8. Locked out and may refuse: the No Set panel keeps the status slot since the call is the news. The lockout shows on SET! and as the Locked tag on the chip, drawn at 9 of 15 s.
9. Big screen at 1280 wide: the play column is about 744px, so the Refused headline wraps onto two balanced lines inside the 9rem band, as "Alex called No Set" does.
10. The computer boards keep "Room K7QF3M" beside the deck line, as the existing boards do. The code (ticket 22) is the truth for the footer.

## Open questions
1. The existing Locked out boards still show the 5-second ring (4 left), though lockout is 15 s since ticket 20. Recommendation: redraw them in the next brief that touches lockout.
2. A 20-character name at 1280 wide pushes the Refused headline to three lines and out of the 9rem band, as it would the No Set and claiming headlines. Recommendation: truncate the name with an ellipsis so the headline stays within two lines.

## Artboards added or changed
Added. The play components are existing boards, so the new states live in three new components, each also a board, placed beside their layout's Idle and No Set boards:
- Portrait 8/18: PlayPortraitRefusal (No Set, may refuse), play-p8-refuse-locked (No Set, locked out, may refuse), play-p8-blocked (Idle, No Set blocked, 12 s), play-p8-blocked-self (Idle, No Set blocked, refuser's screen)
- Landscape: PlayLandscapeRefusal (No Set, may refuse), play-l-blocked (Idle, No Set blocked, 12 s)
- Computer: PlayComputerRefusal (No Set, may refuse), play-c-blocked (Idle, No Set blocked, 12 s)
- Big screen: BigScreen (during play, Refused at 12 s, 1920×1080), in a new row under Game over
Moved right to make room, content unchanged: in the portrait 8/18, landscape and computer rows, every board after Idle (deck-empty through arrive).
Changed: none.
Not drawn: refusal already used (decision 4).
