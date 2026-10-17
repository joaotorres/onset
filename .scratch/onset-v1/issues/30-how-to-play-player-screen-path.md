# 30: How to play: rename @game_path to @player_screen_path

Status: needs-triage
Kind: behavioural
Blocked by:
Model:
Effort:
Changelog:

## Request

How to play: rename @game_path in LobbiesController#how_to_play and its view to @player_screen_path, since game_path is the big screen route helper; no behaviour change

From review 20261017-132315 (Pending decisions 1, Standards smell 1). Ticket 29 renamed `@return_to` to `@game_path`, but the `game_path` route helper goes to `games#show`, the big screen, and `app/views/players/new.html.erb` and `app/views/players/controller/_invite.html.erb` use it that way. `@game_path` holds the player screen path (`game_controller_path`). `@back_path` is not part of this request. Players notice nothing.

## Comments
