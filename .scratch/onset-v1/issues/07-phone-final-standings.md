# 07: Full standings on the player screen game over

Status: needs-triage
Kind: visual
Blocked by:
Model:
Effort:

## Request

Player screen game over: full standings under the rank, own row highlighted

Below "2nd · of N players", a compact standings list: rank, color dot, name, score, the player's own row highlighted. Ties share a rank, as on the big screen podium.

## Comments

Decided: created docs/design-system.md v1 from the code before filing this first visual ticket, as loop-rules section 9 says. Instead of: no visual gate.

Design gap: SPEC §8 "Phone controller" item 8 (Game over) lists the rank, "of N players · P points", the winner line and "Play again from the big screen", but no standings list. Does the list sit under the winner line or replace it? Each row shows rank, dot, name and score: anything else, such as the Locked tag or ready marks? How is the own row marked? Up to 8 players (8 preset colors, unique per room): must the list fit without scrolling in portrait and landscape?

Decided: SPEC §8 Player screen > 8. Game over places the standings under the winner line and above Play again, keeping the winner line, because the request adds a list and drops nothing. Instead of: the list replacing the winner line.

Decided: rows show rank, dot, name and score only, with no ★, Locked tag or ready marks, because lockouts end with the game, the winner line carries the ★ and ticket 11 keeps vote marks off the game over. Instead of: copying the big screen scoreboard's Locked tag or showing Play again votes.

Decided: the own row gets a surface tint and "you" after the name, because §10 gives each meaning color one meaning and the waiting roster already marks the player with "you". Instead of: a yellow or player-color row.

Decided: no page scroll with 8 players at 375×667 portrait and 667×375 landscape, the list scrolling inside itself on shorter screens, because §8 says the player screen never scrolls and the 8 preset colors cap a room at 8 players. Instead of: page scroll or showing only the top rows.

Decided: the list holds every player in the room, sorted by score with ties in join order and ranks shared as "1, 1, 3", because Game#standings and Game#rank_of already work that way and "of N players" counts every player. Instead of: only active players.

Decided: the 07, 08, 09, 10 brief draws every screen fresh on a new empty canvas and says the code is the truth for what it does not change, because the canvas has no boards to redraw. Instead of: first drawing the built landing, join page and player screen on the canvas from the code.
