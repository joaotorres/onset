# 30: How to play: rename @game_path to @player_screen_path

Status: done
Kind: behavioural
Blocked by:
Model:
Effort:
Changelog: Behind the scenes: the How to play page names its player screen link more clearly in the code.

## Request

How to play: rename @game_path in LobbiesController#how_to_play and its view to @player_screen_path, since game_path is the big screen route helper; no behaviour change

From review 20261017-132315 (Pending decisions 1, Standards smell 1). Ticket 29 renamed `@return_to` to `@game_path`, but the `game_path` route helper goes to `games#show`, the big screen, and `app/views/players/new.html.erb` and `app/views/players/controller/_invite.html.erb` use it that way. `@game_path` holds the player screen path (`game_controller_path`). `@back_path` is not part of this request. Players notice nothing.

## Spec references

No spec change. §5 Routes, the `GET /how-to-play?game=` row, already states the behaviour this rename leaves untouched: a `?game=` matching `Game::CODE_FORMAT` sends **← Back** and **Back to the game** to that room's player screen; anything else, or no code, sends Back to `/`.

## Scope

- `app/controllers/lobbies_controller.rb`, `#how_to_play`: rename the instance variable `@game_path` to `@player_screen_path`. `@back_path` keeps its name and keeps reading `@player_screen_path || root_path`
- `app/views/lobbies/how_to_play.html.erb`: the `if @game_path` guard and the **Back to the game** link read `@player_screen_path`

Nothing else changes: no route, no SPEC, no other view or controller, no spec file, no rendered HTML. The `game_path` route helper and its callers in `app/views/players/` stay as they are. Every page renders byte for byte as before.

## Acceptance criteria

- `grep -rn '@game_path' app/` finds nothing
- `@player_screen_path` holds `game_controller_path(code)` in the controller when the code matches `Game::CODE_FORMAT`, and drives the closing **Back to the game** link and its guard in the view
- `@back_path` still falls back to `root_path`, and **← Back** still reads it
- Every existing example in `spec/requests/lobbies_spec.rb` passes unchanged, including the two ticket 29 added for **← Back** and the valid-code **Back to the game** case

## Verification

`bundle exec rspec spec/requests/lobbies_spec.rb && bundle exec standardrb app/controllers/lobbies_controller.rb && ! grep -rn '@game_path' app/ && echo ok`

Tests to write first: none. The request is a rename with no behaviour change, and ticket 29's examples already pin both links for a valid code and for no code. The `grep` in the Verification command is the red step: it fails until the rename is done.

## Out of scope

- Any behaviour change on the How to play page, in the link text or in which links appear
- Renaming `@back_path`, or folding it into `@player_screen_path`
- Touching the `game_path` route helper, its name, or its callers on the join page and the invite panel
- Rewriting the existing hardcoded `/games/ABC234/controller` expectation to the route helper (review 20261017-005226 smell 2, not in this request)
- A §8 view section for How to play in SPEC

## Comments

Decided: no new tests, because the request is a rename with no behaviour change and the ticket 29 examples already pin where both links go; the Verification grep for `@game_path` is the red step. Instead of: a request example that passes before and after and proves nothing.
