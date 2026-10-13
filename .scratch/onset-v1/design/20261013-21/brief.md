Canvas: https://claude.ai/artifact/123TNq7nwcKGoXDaroSGcM. Written against docs/design-system.md version 2, 2026-10-13.

# Design brief: Onset, refusing a No Set call (ticket 21)

Add new boards to the canvas above, beside the existing No Set boards. Change no existing board.

## Context

Onset is real-time multiplayer Set in the browser. Each player plays on their own **player screen** (a phone or a computer); a shared **big screen** (a TV or laptop the table can see) is optional. This ticket adds a way to answer a No Set call with "There's a Set": the call is cancelled and nobody can call No Set for 15 seconds, time to find the Set.

Users: friends at a table or on a call, mostly on phones. Glances, not reading: everything must read at arm's length, and the big screen at 2m.

Terms the screens show (from the glossary):

- **Player screen**: one player's own view of a game, on a phone or a computer. Never "phone", "controller" or "remote" in user-facing text
- **Big screen**: an optional shared display of a game. It is not a player. Never "board", "TV" or "host screen"
- **Board**: the face-up cards in play, 12 to 18 of them
- **Set**: three cards whose four attributes are each all the same or all different
- **No Set call**: a 15-second countdown any player starts when they believe the board holds no Set; when every active player agrees, or it runs out, three more cards are dealt
- **Refusal**: a player's answer to a No Set call that there is a Set to find ("There's a Set"): it cancels the call and blocks No Set for everyone for 15 seconds. One per board, no penalty. Never "veto", "reject" or "objection"
- **Lockout**: the 15 seconds after a wrong or timed-out claim during which that player cannot claim again

Use realistic names such as Alex, Sam, Priya, Jonas, Mei, Tomás, Ada, Leo, and room code `K7QF3M`.

Every screen here is built. The code is the truth for everything this brief does not change: since your last boards, the computer layout's "Room CODE" footer moved directly under the deck line, centred on the board (ticket 22), and the claim no longer dims the board (ticket 19). Neither touches the states below; keep the existing boards as they are and draw the new ones from the matching `-noset` and idle boards.

## What to design

### 1. Player screen, No Set countdown, may refuse (new state)

Widths: portrait 375×667, landscape 667×375, computer 1024×640. 8 players, 18 cards.

The existing "No Set, before agreeing" state, for a player who may refuse: the purple status panel, the round blue SET! (which cancels the call), and in the pill slot both **I agree, no Set** and **There's a Set**. How the two share the pill slot is yours to propose, in each layout. The slot is 220×44 in portrait, the full 9rem (144px) action column by 44 in landscape, and 248×46 on computer; SET! must not move.

States to draw:

- May refuse (the new pill pair), in all three layouts
- Locked out and may refuse, portrait only: SET! shows disabled as the lockout countdown, the refusal stays available
- Refusal already used on this board, portrait only: only **I agree, no Set**, as the existing board shows. Draw it only if your pill pair changes how the lone pill sits; otherwise say so in the return

### 2. Player screen, idle with No Set blocked (new state)

Widths: portrait 375×667, landscape 667×375, computer 1024×640. 8 players, 18 cards.

After a refusal every player screen returns to idle for 15 seconds with No Set blocked:

- The status slot (empty in plain idle) reads "Alex says there's a Set", Alex being the refuser
- The No Set pill is disabled and shows the seconds left: "No Set in 12 s". It comes back on its own when the block ends
- SET! stays as in idle: round blue, enabled

States to draw: blocked at 12 s left, in all three layouts. One more, portrait only: the refuser's own screen, if you think it should read differently (for example "You say there's a Set"); otherwise say in the return that it is the same.

### 3. Big screen, Refused announcement panel (new board)

Width: 1920×1080 (TV), and it must also fit a laptop down to 1280px wide. There is no big screen board on the canvas yet: draw one board of the big screen during play with the Refused panel in the announcement band. The code is the truth for the rest of the big screen; draw the rest as described under Spec facts.

## Spec facts

### Refusal, from SPEC §2 Game Rules > Round flow

> **Refusal**: any other active player who has not agreed can tap **"There's a Set"** to refuse the call. The call is cancelled at once and nobody, the refuser included, can call No Set for **15 seconds** (`Game::NO_SET_TIMEOUT`, the countdown's own length, so the two never drift): time to find the Set the refuser says is there. SET! stays open throughout. Refusing costs nothing. One refusal per board: the next No Set call on the same board cannot be refused, and the refusal comes back once the board changes (a Set removed or cards dealt).

> If anyone calls **"SET!"** during the countdown, the No-Set call is **cancelled** and the claim flow begins.

### SPEC §2 Edge cases

> Wrong-claim lockout (15s, `Game::CLAIM_TIMEOUT`) only prevents that player from calling SET; they can still observe, call No Set, join No-Set votes and refuse a call.

### SPEC §8 Views & UX > Player screen

> SET! sits in the same fixed slot across idle, locked out, someone else claiming and the No Set countdown, so the thumb never has to move. The pill slot under it holds the state's secondary action: **No Set**, the **End game** vote or **I agree, no Set**, with **There's a Set** (the refusal) beside it while the player may refuse.

> 2. **Idle**: round blue **SET!** with a halo, a purple **No Set** pill under it. During the block after a refusal (§2), No Set is disabled and shows the seconds left ("No Set in 12 s"), the status slot reads "Alex says there's a Set" and SET! stays as it is; the pill comes back on its own when the block ends. Deck empty: an orange **End game** vote with "Deck empty · n/m voted".

> 5. **No Set countdown**: a purple status panel (ring, "No Set called by Alex", n/m agreed in every layout) above the round blue **SET!**, which cancels the call, and a purple **I agree, no Set** pill under SET!. A player who may refuse (§4 `can_refuse_no_set?`: not the caller, has not agreed, and no refusal used on this board) also gets **There's a Set**, the refusal, in the pill slot; how the two pills share it comes from the design pass. After agreeing, or for the caller, the pill slot shows "You agreed · waiting for n more". Locked out, SET! shows disabled; the refusal stays available. A refusal returns every screen to idle with No Set blocked (state 2).

> 6. **Locked out** (after a wrong claim or a timeout): the panel tints red and shakes once. "Wrong! −1" or "Time's up! −1". SET! becomes the lockout countdown with "Locked": `Game::CLAIM_TIMEOUT` seconds, the same length as the claim ring. The pill slot keeps the idle secondary action, **No Set** or the **End game** vote, enabled: lockout only blocks SET! (§2 Edge cases).

From these: a player still locked out when a refusal lands keeps the red locked-out panel in the status slot, and the pill slot shows the blocked No Set ("No Set in 12 s"). No need to draw it.

### SPEC §8 Views & UX > Big screen

> Full screen, built for a TV at 2m, and must also fit a laptop down to 1280px wide. Two columns: the play area (`#board` over `#announcement`) and a 26rem right rail with the room tile (room code and the site address to open, `join_host`, no QR) and the **Players** scoreboard.

> - **Playing**: "N cards left in the deck" top right, or an orange "Deck is empty" pill. The card grid (§10). Cards dealt by the last replace get a green outline that fades over 3s.
> - **Announcement band**: always 9rem tall so the grid never jumps. Empty while playing: "Spot a Set? Hit SET! on your screen." Otherwise one tinted panel:
>   - Claiming (yellow): countdown ring, "Alex is calling SET!".
>   - No Set (purple): ring, "Alex called No Set", "Agree on your screen, or find one first", and "n/m agreed".
>   - Refused (purple): ring counting the block down, "Alex says there's a Set", "No Set is back when the ring runs out". Shown for the `NO_SET_TIMEOUT` block after a refusal (§2), then the empty-band text returns.

As built, the No Set panel is a rounded-3xl `purple-500` at 10% fill with a 2px inset `purple-500` ring, 32px side padding: a 96px ring (`purple-400` progress, `purple-300` seconds), then "Alex" in `purple-400` and "called No Set" in 48px display bold, "Agree on your screen, or find one first" in 24px `gray-300` under it, and the "n/m agreed" count right-aligned in 60px display. The page is `gray-950` with 40px padding and 40px gaps.

### SPEC §5 Routes

> Every action a player screen or the big screen POSTs answers `204 No Content`; the broadcast updates the screens (§7).

There is no loading or error state to draw: a refusal that loses a race (someone else refused or called SET! first) changes nothing, and the next broadcast redraws every screen.

## Design rules, quoted from docs/design-system.md

### Components

> - `games/_ring`: big screen countdown ring, size-24, seconds inside
> - `games/_announcement`: the 9rem announcement band and its tinted panels
> - `players/controller/_button_ring`: thin ring around the round SET! button
> - `players/controller/_small_ring`: countdown ring with seconds, any size
> - `players/controller/_secondary_action`: the pill under SET!: No Set, the End game vote, or during a No Set countdown I agree, no Set (filled purple) or the waiting text (outlined purple)
> - `players/controller/_status_panel` (v2): one fixed slot above SET!, portrait 64px tall, landscape 144×104, computer 248×76. Variants:
>   - claim bar: `yellow-400`, ring, "Your SET!", "Tap 3 cards", n/3
>   - someone else claiming: `gray-900` with a `yellow-400` border, "Alex is calling SET!"
>   - No Set: `purple-950` with a `purple-500` border, ring, "No Set called by Alex", "n/m agreed"
>   - locked out: `red-950` with a `red-600` border, "Wrong! −1" or "Time's up! −1", `animate-shake`
>   - idle: empty, the slot keeps its size

### Player screen, during play (ticket 09)

> - Portrait, top to bottom: the scoreboard, the board at full width, the status slot (64px, empty in idle), the 128×128 SET! slot and its pill
> - Landscape: the board on the left, a 9rem action column (status panel, SET!, pill), a scores column
> - Computer: the board on the left; a 248px side column with the scoreboard stacked above the status panel, SET! and its pill
> - Read-only boards (someone else claiming, No Set, locked out) are not dimmed

### Rules added in v2

> - Filled purple pills (No Set, I agree, no Set) use `purple-700` with white text. The waiting text after agreeing is outlined `purple-500` with `purple-200` text
> - SET! slot 128×128 in every layout, the button 104px (108px on computer). Ring states put a 128px ring around a 100px disabled `gray-800` button
> - Portrait keeps the status slot at 64px in every state, so the board never resizes on a state change

### Visual system (SPEC §10)

> Surfaces: page `gray-950`, panels `gray-900`, borders `gray-700`/`gray-800`. Secondary text `gray-400`, muted `gray-500` (not `gray-600`, which fails contrast on `gray-950`).

> | Color | Meaning |
> |---|---|
> | blue-600 | SET! and primary actions |
> | violet-600 | quick game |
> | yellow-400 | a claim in progress (big screen panel, scoreboard entries, player screen claim bar) |
> | purple | No Set. It used to be red; red now only means wrong or locked |
> | red | wrong claim, timeout, lockout |
> | green | ready, correct, start, play again |
> | orange | deck empty and the End game vote (`orange-700` for white text; `orange-600` is only about 3.3:1) |

> Countdown rings: `r=45` in a 100 viewBox, gray track, colored progress with round caps, rotated -90° so they drain clockwise from the top. Seconds sit inside the ring, or inside the button the ring surrounds.

> `font-display`: Bricolage Grotesque (Google Fonts link in the layout). Only for display text: wordmark, room code, scores, SET!, headlines, countdown digits. Body copy stays on the default sans.

The refusal belongs to the No Set exchange, so it stays in purple. Red, green and yellow keep their meanings.

## Boundaries

- Change no existing board. Add the new boards beside the No Set and idle boards of each layout, and the big screen board in a new row
- Propose no new color meaning. A new token or component goes under the return's headings
- Behaviour (who may refuse, the 15-second block, once per board) is settled in the spec. If a screen suggests changing it, put it under Open questions, do not draw it

## The return

When the design is done, return exactly this, writing `None` under a heading with nothing in it. Begin with the `Design return` line, with no command such as `/request` or `/design-entry` before it, since a pasted command does not run.

```
Design return for tickets 21.

## New tokens
## New components
## New or changed rules
## Decisions the spec does not cover
## Open questions
## Artboards added or changed
```

End every reply with:

1. **Pending decisions:** what you need from me before going on,
   numbered, each with your recommendation first, explained so I can
   decide without opening anything else. `None` when there are none.
2. Only once the design is done: the line `Paste this into Claude
   Code:`, then the return alone, in the format above, in a fenced
   block of its own. Nothing after that block.
