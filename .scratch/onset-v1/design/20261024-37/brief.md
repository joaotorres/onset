Canvas: https://claude.ai/artifact/123TNq7nwcKGoXDaroSGcM. Written against docs/design-system.md version 4, 2026-10-24.

# Design brief: Submit button for a SET! claim (ticket 37)

## Context

Onset is real-time multiplayer Set. Each player plays on their own **player screen**, on a phone or a computer, from which they call SET!, pick cards and vote; a shared **big screen** is optional. A player who calls SET! holds the **claim**: 15 seconds to pick three cards on the **board** (the face-up cards). Today the claim is judged only when the 15 seconds run out, so even a correct **Set** waits out the full timer. This ticket adds a **Submit** button to the claiming screen so the player can have their three picks judged at once.

Glossary terms these screens show:

- **Player screen**: One player's own view of a game, on a phone or a computer, from which they call SET!, pick cards and vote.
- **Board**: The face-up cards in play, 12 to 18 of them.
- **Set**: Three cards whose four attributes are each all the same or all different.
- **Claim**: A player's call of SET!, which gives them the sole right to pick three cards and submit them before the claim window closes; a claim never submitted is judged on its picks when the window closes.
- **Lockout**: The 15 seconds after a wrong or timed-out claim during which that player cannot claim again.

## What to design

One screen, **Player screen, Claiming (mine)**, in its three layouts and two portrait densities, at the boards' sizes: portrait 375×667, landscape 667×375, computer 1024×640.

For each of portrait 8 players / 18 cards, portrait 3 players / 12 cards, landscape 8/18 and computer 8/18, draw:

1. **0/3**: the claim just started from SET!, Submit disabled
2. **2/3**: Submit disabled
3. **3/3**: Submit enabled, three cards selected, the board not dimmed
4. **Submitted**: the moment after the Submit tap, before the broadcast that resolves the claim: no more picks, Submit takes no second tap, the countdown ring still running

The existing `-claiming` boards (1/3) stay as they are unless Submit's place changes their layout; if it does, update them to match and list them under Artboards added or changed.

Not new states, already drawn: what follows Submit is the found-set banner (correct, the `-found` boards) or Locked out (wrong, the `-wrong` boards), exactly as at expiry. A submit request that never reaches the server gives the screen back as in 3/3: the spec names no error message, so draw none unless you propose one under Decisions the spec does not cover.

The big screen does not change.

## Spec facts

### SPEC §2 Game Rules, Round flow, rule 4

> The claiming player has **15 seconds** (`Game::CLAIM_TIMEOUT`) to pick 3 cards on their player screen and submit them. A tap picks a card, a second tap unpicks it, and the server keeps the current picks (§11). With exactly 3 picks the player taps **Submit** and the server judges those 3 at once; if the 15 seconds run out first, the server judges the picks it holds. Either way one of three outcomes:
>    - **Correct Set** (3 picks that form a Set): +1 point, those 3 cards are removed, 3 new cards are dealt from the deck. Board unfreezes.
>    - **Wrong Set** (3 picks that do not): −1 point, claiming player is locked out (cannot claim again) for **15 seconds**, as long as the claim window. The lockout reads `Game::CLAIM_TIMEOUT`, the same constant, so the two never drift. Board unfreezes. History: 5 seconds until ticket 20; that barely outlasted the announcement, so a wrong claim cost little more than the point.
>    - **Time's up** (fewer than 3 picks): same penalty as a wrong Set: −1 point and the same lockout. Board unfreezes.

### SPEC §8 Views & UX, Player screen

> Full height, no page scroll. A strip of the player's color across the top, "Room CODE" footer. The player screen stands alone (§1): in every playing state it shows the board, the scoreboard and the deck count, so a room needs no big screen. Waiting and game over keep a header with dot, name and score, since their bodies already list every player. Three layouts, chosen by the viewport alone, whatever the input:
>
> - **Portrait** (narrower than tall, under 1024px wide): the scoreboard across the top, the board under it at the full width, then the state's panel, SET! and its pill at the bottom, under the thumb.
> - **Landscape** (wider than tall, under 1024px wide): three columns, the board on the left, a 9rem action column, a scores column.
> - **Computer** (1024px wide and up, Tailwind `lg:`): a board-sized card grid on the left and a side column with the scoreboard stacked above the state's panel, SET! and its pill, so the board keeps the width.

> - With 8 players and 18 cards there is no page scroll at 375×667 portrait, 667×375 landscape and 1024×640 computer, in every state: the cards shrink to fit.

> SET! sits in the same fixed slot across idle, locked out, someone else claiming and the No Set countdown, so the thumb never has to move. The pill slot under it holds the state's secondary action: **No Set**, the **End game** vote or **I agree, no Set**, with **There's a Set** (the refusal) beside it while the player may refuse.

State 3:

> 3. **Claiming (mine)**: a solid yellow bar with the countdown ring, "Your SET!", "Tap 3 cards" and an n/3 count, and a **Submit** button. Portrait puts the bar in the status slot above SET! and a tray of three slots, which fill as cards are tapped, in place of SET! and its pill. Landscape and computer show the bar as one block in place of the panel and SET!, the pill slot left empty. Where Submit sits in each layout comes from the design pass. No Set is not offered during the player's own claim. A claim started by tapping a card opens with that card picked (1/3) if it is still on the board. Tap a card to pick it, tap again to unpick, up to three; three picks stay changeable until Submit is tapped or the time runs out. Submit is shown disabled below three picks and enabled at exactly three, in one fixed place, as SET! keeps its slot. Tapping it sends the three picks and the server judges them at once (§11): correct or wrong, announced on every screen exactly as a claim judged at expiry (the found-set banner, or state 6). From the tap on the screen takes no more picks and Submit takes no second tap, until the broadcast that resolves the claim replaces the screen; the countdown ring keeps running, since the timer stays the fallback. A submit request that never reaches the server (a network error) gives the board and Submit back, and the player taps again. A redraw of the screen during the claim (any room update, §7) shows the picks again, tray and count included, the latest ones even with a pick still on its way to the server (§11).

States 6 and 7, what follows a submit:

> 6. **Locked out** (after a wrong claim or a timeout): the panel tints red and shakes once. "Wrong! −1" or "Time's up! −1". SET! becomes the lockout countdown with "Locked": `Game::CLAIM_TIMEOUT` seconds, the same length as the claim ring. The pill slot keeps the idle secondary action, **No Set** or the **End game** vote, enabled: lockout only blocks SET! (§2 Edge cases). Locked out during the block after a refusal, the refused panel takes the status slot (state 2), SET! keeps its lockout countdown and the pill is the blocked No Set.
> 7. **Found-set banner**: when anyone finds a Set, a banner across the top shows the cards, "Alex found a Set" and "+1", then fades. It ignores taps.

### SPEC §11 Selection submission UX (decision)

> A claim is judged when the claiming player submits exactly three picks, or when its 15 seconds run out, whichever comes first. Every tap on the board picks or unpicks a card, up to three, and sends the current picks to the server at once (`PATCH /games/:code/claims/:id`, §5): one request at a time, each carrying the whole selection, so a quick sequence of taps arrives in order. The server stores them on the pending claim (`Claim#card_ids`) and broadcasts nothing: the picks are private to the claiming player.

> On the player screen each tap also copies the card into the portrait tray's next free slot and updates the n/3 count. The board never dims and three picks stay changeable until Submit is tapped or the time runs out. Submit is rendered disabled and the controller enables it at exactly three picks; on the tap it sends the submit at once, whatever pick request is in flight, and freezes the screen (no pick, no second submit) until the resolving broadcast replaces it. The freeze is lifted only when the request fails to reach the server, so the player can tap again; a response of any kind leaves the screen to the broadcast, or to the timer.

### SPEC §10 Cards and visual system, Palette

> Selected card on the player screen: `ring-4 ring-blue-400 scale-95`.

### Built today (the code is the truth for these)

- Portrait claiming: the claim bar in the 64px status slot; under it the tray, a 176px-tall row of three 72px-wide 5:7 slots, 14px apart, dashed `gray-700` borders with the slot number in display type until filled. The tray takes the place of the 128×128 SET! slot and the pill slot (44px tall)
- Landscape claiming: the yellow block, 242px tall, fills the 9rem (144px) action column: ring 64px, "Your SET!" 22px, "Tap 3 cards" 13px, n/3 at 30px; the pill slot under it (144×44) is empty
- Computer claiming: the same block 216px tall in the 248px side column, ring 72px, "Your SET!" 28px, "Tap 3 cards" 15px, n/3 at 32px; the pill slot under it (248×46) is empty
- At three picks the board does not dim (ticket 19 removed the v1 dimming)

## Design rules

Quoted from `docs/design-system.md` version 4.

### Components

> - `players/controller/_board_strip`: the play card grid with the deck line, sized by the card size rule in portrait and landscape

> - `players/controller/_secondary_action`: the pill under SET!: No Set, the End game vote, or during a No Set countdown I agree, no Set (filled purple) or the waiting text (outlined purple).

> - blocked No Set, after a refusal: the No Set pill at its usual size (portrait 220×44, landscape 144×44, computer 248×46), disabled, `purple-700` at 35% with `purple-200` text, "No Set in 12 s" with the seconds in display type. The block's seconds show only here, not in the status panel

> - `players/controller/_status_panel` (v2): one fixed slot above SET!, portrait 64px tall, landscape 144×104, computer 248×76. Variants:
>   - claim bar: `yellow-400`, ring, "Your SET!", "Tap 3 cards", n/3

> - Stimulus: `card-selection` (picks sent to the server, tray, count), `countdown` (rings and seconds)

### Screens, Player screen, during play (ticket 09)

> - Portrait, top to bottom: the scoreboard, the board at full width, the status slot (64px, empty in idle), the 128×128 SET! slot and its pill
> - Landscape: the board on the left, a 9rem action column (status panel, SET!, pill), a scores column
> - Computer: the board on the left; a 248px side column with the scoreboard stacked above the status panel, SET! and its pill
> - Claiming (mine): portrait, the claim bar takes the status slot and the 3-slot tray replaces SET! and its pill. Landscape and computer: one yellow block replaces the panel and SET!, and the pill slot is empty

### Rules added in v2

> - Card face `#FAFAFA` with a `#E5E5E5` border. Selected: a 4px `blue-400` ring and scale 0.95. Arrive: a 3px `green-400` ring
> - Player screen card size, in every layout: `cw = floor(min((boardW - (cols - 1) * gap) / cols, ((boardH - 2 * gap) / 3) * 5 / 7))`, `cols = cards / 3`, gap 5px on phones and 12px on computer. At 8 players and 18 cards: portrait 54×76, landscape 55×77, computer 106×148. Portrait at 3 players and 12 cards: 71×99. Landscape shrinks the cards to fit the width, with no sideways scroll; at 12 cards they fill the height
> - SET! slot 128×128 in every layout, the button 104px (108px on computer). Ring states put a 128px ring around a 100px disabled `gray-800` button
> - Portrait keeps the status slot at 64px in every state, so the board never resizes on a state change

### Visual rules (SPEC §10, Visual system)

> - `font-display`: Bricolage Grotesque (Google Fonts link in the layout). Only for display text: wordmark, room code, scores, SET!, headlines, countdown digits. Body copy stays on the default sans.

> Surfaces: page `gray-950`, panels `gray-900`, borders `gray-700`/`gray-800`. Secondary text `gray-400`, muted `gray-500` (not `gray-600`, which fails contrast on `gray-950`).

> Each color means one thing everywhere:
>
> | Color | Meaning |
> |---|---|
> | blue-600 | SET! and primary actions |
> | violet-600 | quick game |
> | yellow-400 | a claim in progress (big screen panel, scoreboard entries, player screen claim bar) |
> | purple | No Set. It used to be red; red now only means wrong or locked |
> | red | wrong claim, timeout, lockout |
> | green | ready, correct, start, play again (`green-700` for white text; `green-600` is only about 3.3:1) |
> | orange | deck empty and the End game vote (`orange-700` for white text; `orange-600` is only about 3.3:1) |

> Countdown rings: `r=45` in a 100 viewBox, gray track, colored progress with round caps, rotated -90° so they drain clockwise from the top. Seconds sit inside the ring, or inside the button the ring surrounds.

## Boundaries

- Change no existing board unless this brief names it. The only existing boards it names are the four `-claiming` boards (`play-p8-claiming`, `play-p3-claiming`, `play-l-claiming`, `play-c-claiming`), and those only if Submit's place changes their layout.
- The No Set refusal boards (`PlayPortraitRefusal`, `PlayLandscapeRefusal`, `PlayComputerRefusal`, `play-*-blocked`, `play-p8-refuse-locked`, `BigScreen`) are marked exploring: leave them alone.
- The code is the truth for every part of these screens the brief does not change: the scoreboard, the board and its card sizes, the deck line and the footer.
- Portrait must keep the 64px status slot, and no layout may scroll at 8 players and 18 cards.

## Return format

At the end of the work, return exactly this, writing `None` under a heading with nothing in it. Begin the return with the `Design return` line; no command such as `/request` or `/design-entry`, since a pasted command does not run.

```
Design return for tickets 37.

## New tokens
## New components
## New or changed rules
## Decisions the spec does not cover
## Open questions
## Artboards added or changed
```

## How every reply ends

```
End every reply with:

1. **Pending decisions:** what you need from me before going on,
   numbered, each with your recommendation first, explained so I can
   decide without opening anything else. `None` when there are none.
2. Only once the design is done: the line `Paste this into Claude
   Code:`, then the return alone, in the format above, in a fenced
   block of its own. Nothing after that block.
```
