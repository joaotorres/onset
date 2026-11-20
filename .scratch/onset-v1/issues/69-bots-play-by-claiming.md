# 69: Bots play: each claims a Set after its level's delay

Status: ready-for-agent
Kind: visual
Blocked by: 68
Priority: normal
Feature: AI opponent
Model:
Effort:
Changelog:

## Request

Split from 47 (AI opponent the host can add from the lobby): a bot's timer, its SET! call and 2-second submit through the claim lock, and the bot mark everywhere a bot shows in play and game over.

## Spec references

- SPEC.md, AI opponent > How a bot plays (Its timer and the level table, When it runs out, Its claim, It never votes); Adding a bot > Shown everywhere a player is
- SPEC.md, Shared: 4. Data Model > `Player` (`bot_timer`)
- SPEC.md, Shared: 6. Round State Machine > Key invariants (the current claim, a bot's submit), Lost races are logged
- SPEC.md, Shared: 12. Background Jobs (`BotMoveJob`, `BotSubmitJob`; all jobs idempotent)
- SPEC.md, 11. Selection submission UX (a bot's submit is judged as any Submit)
- SPEC.md, 8. Big screen (Scoreboard, Announcement band, Ended), 8. Player screen (Scoreboard, 4. Someone else claiming, 7. Found-set banner, 8. Game over)
- docs/design-system.md v8: Shared: Rules added in v8; Components > Bot mark (every play and game over size and color); Screens > Big screen (Bots), Player screen, during play (A bot claiming), Player screen, Game over (A bot wins)
- Boards (canvas in docs/design-handoff.md, row "11 · Bots"): bot-big-claiming-light, bot-big-ended-dark, bot-play-p8-other-dark, bot-gameover-p-light

## Scope

- **Schema**: one additive migration, `players.bot_timer` (integer, default 0, not null)
- **The timer**: whenever the room starts or restarts, the board changes (a Set removed or cards dealt) or a claim resolves (correct, wrong or expired), each bot in the room draws a delay, uniform in its level's range (Easy 30 to 50 s, Medium 15 to 30 s, Hard 6 to 15 s), raises its `bot_timer` without callbacks and enqueues `BotMoveJob` with that delay and the new number. Draws happen after the transaction that caused them commits, so a rolled-back change draws nothing
- **`BotMoveJob`**: inside the game lock, acts only if its number equals the bot's `bot_timer`, the room is playing and no claim runs; then picks a random Set among those on the board (`Card.any_set_on?`'s combinations) and takes the claim lock as a person's SET! does (`try_claim!`), cancelling a running No Set countdown. No Set on the board: nothing. A lost race is logged as any lost SET! is
- **The bot's claim**: stores the chosen three as its picks, shows on every screen as a person's claim with the ring ("Easy bot is calling SET!"), and `BotSubmitJob` 2 seconds after the claim is acquired submits those three as a Submit does, only while it is still the room's current claim. `ExpireClaimJob` stays the fallback
- **Never votes**: no bot code path calls No Set, agrees, refuses or votes End game or Play again
- **The bot mark** (DESIGN v8 Components > Bot mark, `role="img"`, `aria-label="bot"`) after a bot's name in each place Shared: Rules added in v8 lists that ticket 68 did not: the big screen's rail scoreboard rows, the announcement band (Claiming, Correct), the ended headline and the podium; the player screen's play scoreboard chips and rows, the status panel (someone else claiming), the found-set banner, the winner line and the standings, at each place's size and color (on a claim-filled entry `gray-950`, in a band the band's name color)
- Must not touch: adding bots, the ready vote and start rules and the telemetry (68), the host's player screen control (70), removing a bot (48), the claim rules for people, the claim and No Set timeouts

## Acceptance criteria

- Starting a room with a Hard bot enqueues one `BotMoveJob` for it with a delay between 6 and 15 s; Easy between 30 and 50 s, Medium between 15 and 30 s
- When the job runs with the latest number, the room playing, no claim running and a Set on the board, the bot holds the claim, its picks are a valid Set on the board, and every screen shows it calling SET!; a running No Set call is cancelled
- An older job (a later draw raised `bot_timer`) does nothing; a job during a claim, with the room ended, or with no Set on the board does nothing
- A person's SET! that takes the lock first wins: the bot's job then changes nothing
- 2 seconds after the bot's claim, `BotSubmitJob` submits it: +1, the three cards replaced as any correct Set, and every bot draws a new timer; a submit job for a claim that is no longer current does nothing
- A person's claim resolving (correct, wrong or expired), No Set dealing 3 cards and Play again each draw a new timer for every bot, and each bot's earlier job then does nothing
- A bot is never locked out and never has a wrong claim; no bot ever appears in `no_set_voters`, `end_game_voters` or as a refuser
- The bot mark, accessible name "bot", follows a bot's name in every play and game over place listed in Scope, on the big screen and the player screen in portrait, landscape and computer, in both themes at DESIGN v8's sizes and colors (spot checks: `gray-950` on the claiming chip, the band's name color, the winner line "★ Hard bot [mark] wins with 9")
- With 8 players and 18 cards the player screen keeps no page scroll at 375×667, 667×375 and 1024×640 with bots in the room

## Verification

`bin/test-all && bundle exec standardrb`

Tests first:

- Job specs for `BotMoveJob` (latest number acts, older does nothing, during a claim, ended, no Set, lost race) and `BotSubmitJob` (current claim submitted, stale one ignored), with the random draw and the Set choice behind a seam the specs fix
- Model specs that each draw trigger (start, restart, Set removed, No Set deal, claim resolved) raises every bot's `bot_timer` and enqueues its job within the level's range
- View or system specs for the bot mark in each play and game over place, and the no-scroll check with bots

## Out of scope

- Wrong claims or hesitation on easy levels, any difficulty but the delay
- A bot voting in any form
- Changing the claim lock, `ExpireClaimJob` or the near-tie log for people
- Adding or removing bots (68, 48), the host's player screen control (70)

## Comments

Decided: split from 47 as its second child, blocked by 68, because a bot must exist in a room before it can play, and the bot mark's play places ship with the play that shows them. Instead of: one ticket with 68.

Decided: additive migration, `players.bot_timer` (integer, default 0, not null), the draw count SPEC §4 now lists, because a scheduled Solid Queue job is never cancelled, so each job must tell whether it is still its bot's latest draw, and a counter compared inside the lock does that without comparing timestamps. Instead of: comparing the job's scheduled time with a stored datetime, or no column and a fingerprint of the board.
