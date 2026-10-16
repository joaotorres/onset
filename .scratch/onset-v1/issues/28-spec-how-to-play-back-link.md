# 28: SPEC: How to play Back link takes a room code

Status: needs-triage
Kind: behavioural
Blocked by:
Model:
Effort:
Changelog:

## Request

SPEC §5: add a GET /how-to-play row: with ?game=<room code> matching the code format, Back returns to that room's player screen; anything else goes Back to /. Never a path or URL. Documents 94839cd, docs only

From review 20261017-004042, pending decision 1. 94839cd already built this: `LobbiesController#how_to_play` checks `params[:game]` against `Game::CODE_FORMAT` and builds `game_controller_path` itself; the player screen links `how_to_play_path(game: game.code)`. It replaced a `return_to` path param that let a crafted `/\host` link send Back off the site. SPEC has no How to play route or Back link line today, so this documents the code; no code or test change. Players notice nothing.

## Comments
