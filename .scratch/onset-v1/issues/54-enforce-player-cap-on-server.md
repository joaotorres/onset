# 54: Enforce the 8-player cap on the server

Status: needs-info
Kind: behavioural
Blocked by:
Priority:
Feature:
Model:
Effort:
Changelog:

## Request

Enforce the 8-player cap on the server: a join whose color is not one of the free presets is refused, so a room never holds more than 8 players, with a unique index on a room's player colors so two joins at once cannot share one; today any #RRGGBB color is accepted, so a script can fill a room with hundreds of players and each game update then renders every player's screen for every player inside the request, stalling the app for all rooms (security review .scratch/onset-v1/reviews/security-20261115.md, section "F1. The 8-player cap is not enforced on the server", severity medium; touches security, so triage asks the owner before deciding).

From the review, so triage does not look it up again:

- Where: `PlayersController#create` saves any posted color; `Player` checks only the `#RRGGBB` format and uniqueness in the game; `players` has no unique index on `(game_id, color)`. `full?` and `PRESET_COLORS` only feed the join page
- Why it matters: `Game#broadcast_game_state` and `broadcast_lobby_state` render one `players/controller_status` per player, synchronously, on every join and every game update, and each of those lists every player. Joins are limited to 20 a minute per IP, which slows this but sets no cap; the gameplay POSTs (`/ready`, `/claims`, `/no_set`, `/end_game`) have no limit
- The review also suggests, for triage to take or leave: a `rate_limit` on the gameplay POSTs. The bots of ticket 47 take "the first free color", so they count towards the same 8
- Filed by the security pass of 2026-11-16, run on Fable while the owner was away. Nothing was run against the app: the finding is read from the code

## Comments

Triage notes, 2026-11-17. Parked because the request asks the owner before deciding a security fix. Confirmed from the code: `PlayersController#create` saves any posted `#RRGGBB` color, `Player` checks only the format and a read-then-write uniqueness, and `players` has no `(game_id, color)` index. The only other path that will add players, the bots of ticket 47 (not built), already takes "the first free color" and is ignored with none free (SPEC §5, AI opponent), so it fits the same cap. The fix as triage would scope it, under option 1 below:
- SPEC §4 `Player`: `color` is one of the 8 presets, checked on create only, so a live room holding a non-preset row from before the deploy keeps playing; `(game_id, color)` unique in the database too
- The preset list moves from `PlayersController::PRESET_COLORS` to `Player`, and the SPEC §10 references follow
- One additive migration: a unique index on `players (game_id, color)`. If a live room already holds two players with one color (only a race could make one), the index fails to build, the deploy stops and the running version stays up; nothing is deleted or rewritten
- A join that loses the race at the index comes back like any taken color: the color error and the next free color selected, or "This room is full"
- Request and model specs: a non-preset color is refused, a ninth join is refused, a join racing for the same color is refused. About 50 existing spec players use non-preset colors (`#648FFF`, `#FE6100`, `#3498DB`, `#DC267F`) and move to presets

Questions for the owner:
- **Room flooding.** Today a script can add hundreds of players to one room by posting made-up colors, and every game update then renders each of their screens, stalling every room on the server. The fix: a join must take one of the 8 player colors still free, checked on the server, with a database rule so two joins at the same moment cannot share one. People joining normally notice nothing; a refused join shows the color error or "This room is full", as today.
  1. Build it as above (recommended): closes the flood, changes nothing for real players, and undoing it later is one migration and a few lines.
  2. Accept the risk and close the ticket unbuilt: rooms stay open to flooding.
- **A limit on in-game taps.** The review also suggests capping how often one player may send game actions (I'm ready, SET!, card picks, Submit, No Set, End game). With the 8-player cap each tap's cost is already bounded, so this only guards against one player hammering the server.
  3. A ticket of its own, filed now (recommended): the cap fixes the stall the review found, while a tap limit needs its own numbers so a player picking cards fast is never refused mid-claim; a filed ticket is undone with wontfix.
  4. Add it to this ticket: one build, but its numbers are picked without play data, and a limit set too tight drops real taps during a claim.
  5. Drop it: no limit on taps.
