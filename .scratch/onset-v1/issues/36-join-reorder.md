# 36: Lobby screens ignore an older join broadcast

Status: needs-triage
Kind: behavioural
Blocked by:
Model:
Effort:
Changelog:

## Request

The waiting board, the start button and every player screen's controller status carry the newer of the game's and the room's players' versions, so two joins that arrive out of order cannot leave the roster or the player count one join behind (SPEC §7, Screens ignore broadcasts older than what they show, extends the second bullet to the waiting #board, #start_button and #controller_status for the other players)

From review 20261022-163847, pending decision 1, a gap left by ticket 34. A join writes only the player (`belongs_to :game` has no `touch`), yet `Player#broadcast_player_joined` calls `Game#broadcast_lobby_state`, which resends the waiting `#board` (roster), `#start_button` (player count) and each player's `#controller_status` at the game's unchanged version. Equal versions render, so when two join broadcasts are delivered out of order the older roster wins until the next broadcast.

The fix uses the stamp `#scoreboard` already uses (`stream_version(game, *players)` over the room's players), applied to those three roots. No `touch` on the association and no migration: the user chose this over accepting the gap, because a later fix costs the same and ships a known hole.

## Comments
