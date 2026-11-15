# 54: Enforce the 8-player cap on the server

Status: needs-triage
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
