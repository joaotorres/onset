# 07: Full standings on the player screen game over

Status: ready-for-agent
Kind: visual
Blocked by:
Model:
Effort:

## Request

Player screen game over: full standings under the rank, own row highlighted

Below "2nd · of N players", a compact standings list: rank, color dot, name, score, the player's own row highlighted. Ties share a rank, as on the big screen podium.

## Spec references

- §8 Views & UX > Player screen (`/games/:code/controller`) > 8. Game over (the winner line, the standings paragraph, the tied rank, the three layouts, no page scroll)
- §8 Views & UX > Player screen: the three layouts, chosen by the viewport alone
- §10 Cards and visual system > Visual system (surfaces, the meaning table)
- docs/design-system.md v2: `players/controller/_standings`, Screens > Player screen, Game over (ticket 07), Rules added in v2 (`green-700` under white text)

## Scope

The ended branch of the player screen status (`#controller_status` while `Game#ended?`), plus a new `players/controller/_standings` partial. Reuse `Game#standings` (score desc, join order) and `Game#rank_of` (competition rank) for the rows; add a model method only if a row's rank cannot be read from those.

Do not touch: the big screen ended view and its podium, the header partial, the ready vote logic (`POST /games/:code/ready`, `start_voters`, `play_again_waiting_count`), the waiting and playing branches, the during-play scoreboard (ticket 09), the waiting invite (ticket 10).

## Acceptance criteria

- Game over shows, in order: "Game over", the rank, "of N players · P points", the winner line, the standings, then Play again or the voted line
- The standings list every player in the room (as many as "of N players" counts), one row each with rank, color dot, name and score, sorted by score with ties in join order
- Tied players share a rank: scores 5, 5, 3 read ranks 1, 1, 3
- No ★, Locked tag or ready marks inside the rows
- The viewing player's row has a `gray-800` tint with a `gray-600` border and "you" after the name; other rows are transparent. No color from the §10 meaning table marks it
- Names truncate with an ellipsis on one line
- Winner line: "★ Alex wins with 9" for another sole winner, "★ You win with 9" when the viewer is the sole winner, "★ Tied for first at 9" on a tie for first
- A viewer tied for first sees the rank "1st", not "=1st"
- Play again uses `green-700` with white text; the voted line "Ready ✓ · waiting for n more" keeps its text and reads as outlined `green-700` on a 12% `green-700` tint with `green-300` text
- Portrait stacks everything; landscape (667×375) puts rank, winner line and Play again in a left column and the standings on the right; computer (1024px wide and up) uses a 360px left column and the standings in a `gray-900` panel on the right
- With 8 players there is no page scroll (document scroll height equals the viewport) at 375×667, 667×375 and 1024×640
- At 375×560 with 8 players the page still does not scroll and the standings list scrolls inside itself

## Verification

`bundle exec rspec`

Write first:
- request specs in `spec/requests/games_spec.rb` for `GET /games/:code/controller` on an ended game: row count and order, shared ranks 1, 1, 3, the own row's "you" and tint class, no ★ or "Locked" inside the standings, the three winner line variants and "1st" for a viewer tied for first
- a system spec with 8 players (one per preset color, long names) on an ended game, resizing the viewport as `spec/system/big_screen_spec.rb` does, asserting no page scroll at 375×667, 667×375 and 1024×640, and at 375×560 that the page does not scroll while the standings element does

## Out of scope

- The big screen podium or ended view
- Showing Play again votes or lockouts in the rows
- A during-play scoreboard or the computer layout of playing states (ticket 09)
- Animations on the standings, or a "you" star or medal
- Any change to `Game#winner`, `Game#rank_of` or `Game#standings` behaviour

## Comments

Decided: created docs/design-system.md v1 from the code before filing this first visual ticket, as loop-rules section 9 says. Instead of: no visual gate.

Design gap: SPEC §8 "Phone controller" item 8 (Game over) lists the rank, "of N players · P points", the winner line and "Play again from the big screen", but no standings list. Does the list sit under the winner line or replace it? Each row shows rank, dot, name and score: anything else, such as the Locked tag or ready marks? How is the own row marked? Up to 8 players (8 preset colors, unique per room): must the list fit without scrolling in portrait and landscape?

Decided: SPEC §8 Player screen > 8. Game over places the standings under the winner line and above Play again, keeping the winner line, because the request adds a list and drops nothing. Instead of: the list replacing the winner line.

Decided: rows show rank, dot, name and score only, with no ★, Locked tag or ready marks, because lockouts end with the game, the winner line carries the ★ and ticket 11 keeps vote marks off the game over. Instead of: copying the big screen scoreboard's Locked tag or showing Play again votes.

Decided: the own row gets a surface tint and "you" after the name, because §10 gives each meaning color one meaning and the waiting roster already marks the player with "you". Instead of: a yellow or player-color row.

Decided: no page scroll with 8 players at 375×667 portrait and 667×375 landscape, the list scrolling inside itself on shorter screens, because §8 says the player screen never scrolls and the 8 preset colors cap a room at 8 players. Instead of: page scroll or showing only the top rows.

Decided: the list holds every player in the room, sorted by score with ties in join order and ranks shared as "1, 1, 3", because Game#standings and Game#rank_of already work that way and "of N players" counts every player. Instead of: only active players.

Decided: the 07, 08, 09, 10 brief draws every screen fresh on a new empty canvas and says the code is the truth for what it does not change, because the canvas has no boards to redraw. Instead of: first drawing the built landing, join page and player screen on the canvas from the code.

Design question: game over rank when tied for first is drawn as "1st" with "Tied for first" under it. Should it read "=1st" or similar? Also in docs/design-system.md v2 open questions.

Design question: when the viewer wins, the winner line is drawn with their name ("★ Ada wins with 7"). Should it say "You"? Also in docs/design-system.md v2 open questions.

Decided: a tied rank stays a plain ordinal ("1st", never "=1st"), written into SPEC §8 Player screen > 8. Game over, because the winner line and the shared ranks in the standings already say who tied and the code renders `rank.ordinalize`. Instead of: "=1st" or "T-1st".

Decided: the winner line says "★ You win with 9" when the viewer is the sole winner and "★ Tied for first at 9" on a tie, written into SPEC §8, because the built code already reads so and the standings mark the viewer "you"; the design-system open questions now point there and the -win boards get redrawn with the next game over brief. Instead of: the winner's own name, as the boards drew it.

Decided: 07 builds game over in all three layouts, the computer one too, adding 1024×640 to the no-scroll line in SPEC §8, because §8 picks layouts by viewport alone and the design pass drew a computer game over for this ticket. Instead of: leaving game over's computer layout to ticket 09, whose request is the playing states.

Decided: Play again moves to `green-700` and the voted line to the v2 Waiting look in this ticket, because docs/design-system.md v2 game over anatomy names them and green-600 fails contrast under white text. Instead of: leaving the v1 green-600 button.

Decided: no Blocked by, because 07 touches only the ended branch and ticket 11, which built the Play again vote, is done. Instead of: blocking on 09 for the computer layout.
