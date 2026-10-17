# 29: How to play Back link: specs and a clearer name

Status: deployed
Kind: behavioural
Blocked by:
Model:
Effort:
Changelog: Behind the scenes: tests now cover where the How to play Back link goes, and a variable got a clearer name.

## Request

How to play Back link: add request specs that ← Back goes to the player screen with a valid ?game= room code and to / with no game param, and rename @return_to in LobbiesController#how_to_play and its view to @game_path; no behaviour change

From review 20261017-005226 (Spec test gap, Standards smell 1). `spec/requests/lobbies_spec.rb` checks a valid code only through the closing **Back to the game** button, never the top **← Back** link, and has no case for a missing `game` param. `@return_to` names the old `return_to` param removed in 94839cd; it now holds the player screen path. SPEC §5's `GET /how-to-play?game=` row (ticket 28) already describes the behaviour, so no spec change. Players notice nothing.

## Spec references

No spec change. §5 Routes, the `GET /how-to-play?game=` row, already states the behaviour the new specs prove: a `?game=` matching `Game::CODE_FORMAT` sends **← Back** and **Back to the game** to that room's player screen; anything else, or no code, sends Back to `/`.

## Scope

- `LobbiesController#how_to_play` and `app/views/lobbies/how_to_play.html.erb`: rename the instance variable `@return_to` to `@game_path`. `@back_path` keeps its name and meaning (the game path, else `root_path`)
- `spec/requests/lobbies_spec.rb`, the `GET /how-to-play` block: two new examples, described under Acceptance criteria

Nothing else changes: no route, no SPEC, no other view or controller, no rendered HTML. Every page renders byte for byte as before.

## Acceptance criteria

- With `game=ABC234`, the response body contains the **← Back** link with `href` equal to `game_controller_path("ABC234")` (`/games/ABC234/controller`)
- With no `game` param at all, the response body contains the **← Back** link with `href` equal to `root_path`, and does not contain "Back to the game"
- `grep -rn return_to app/` finds nothing; `@game_path` holds the player screen path in the controller and drives the closing **Back to the game** link in the view
- Every existing example in `spec/requests/lobbies_spec.rb` still passes unchanged, including the four invalid-`game` cases and the valid-code **Back to the game** case

## Verification

`bundle exec rspec spec/requests/lobbies_spec.rb && bundle exec standardrb app/controllers/lobbies_controller.rb spec/requests/lobbies_spec.rb && ! grep -rn return_to app/ && echo ok`

Tests to write first: the two new request examples in the `GET /how-to-play` block (valid code, ← Back; no param, ← Back to root). The valid-code example is expected to pass before the rename since the behaviour already exists; the no-param example is also expected to pass. Both document behaviour the suite never asserted, which is what the review asked for. The rename is checked by the `grep` in the Verification command, which fails until it is done.

## Out of scope

- Any behaviour change on the How to play page, in the link text or in which links appear
- Renaming `@back_path`, or folding it into `@game_path`
- Rewriting the existing valid-code expectation's hardcoded `/games/ABC234/controller` to the route helper (review smell 2, not in this request)
- A case for an empty `game=` param: the existing invalid-`game` loop and the no-param case cover the "anything else, or no code" clause between them
- Changes to the landing's or the player screen's How to play links
- A §8 view section for How to play in SPEC

## Comments

Decided: the new examples assert the `href` through `game_controller_path("ABC234")` and `root_path`, because the route helper reads as the spec's "that room's player screen" and survives a route change. Instead of: the hardcoded `/games/ABC234/controller` string the existing example uses.

Decided: `@back_path` keeps its name and the view keeps reading `@game_path` for the closing button and `@back_path` for ← Back, because the request names only `@return_to` and the two variables mean different things (the game path, and the game path or the root). Instead of: a single `@game_path` with `|| root_path` repeated in the view.

Decided: the existing hardcoded expectation stays as it is, because the request was filed from the review's smell 1 only and the loop treats a request's edges as the scope. Instead of: also moving it to the route helper while in the file.
