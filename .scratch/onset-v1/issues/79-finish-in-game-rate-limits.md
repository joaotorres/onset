# 79: Behind the scenes: finish ticket 60's rate limits

Status: deployed
Kind: behavioural
Blocked by:
Priority: low
Feature: Rate limits
Model:
Effort:
Changelog: Behind the scenes: the ready, Start game and Play again limits are checked before the room is looked up, and the in-game limits gain specs for broadcasts and cookie-less counts.

## Request

Deferred from 60. Behind the scenes: finish ticket 60's rate limits. In `GamesController` the `ready` and host `rate_limit` lines sit after `before_action :set_game`, so a refused ready, Start game or Play again still loads the game, against the ticket's "no model call", and a request for an unknown room code answers `404` without being counted: declare both limits before `set_game`, as the claims, No Set and End game controllers have theirs first. Add the request specs the criteria lack in `spec/requests/in_game_rate_limits_spec.rb`: a player at the No Set limit can still claim; a refused request broadcasts nothing, for each of the five limits; and a request with no `player_token` cookie, or no `host_game` cookie for the host's limit, is counted by its IP, two addresses apart and never against a cookie holder's count.

## Spec references

No spec change. Shared: 5. Routes, Rate limits already says it: a request over its limit "changes nothing: no claim taken, no pick stored, nothing judged, no vote counted, no broadcast", and a request with no player cookie, "refused anyway (`403` or `404`), is counted by IP", the host's likewise without the `host_game` cookie. The build brings `GamesController` and the specs in line with it.

- Shared: 5. Routes, Rate limits (the five in-game limits, their keys, nothing changed on a refused request)
- Shared: 5. Routes, URL surface (`404` for a room code that does not exist, `429` over a limit)

## Scope

- `app/controllers/games_controller.rb`: declare the `ready` (`name: "ready"`) and host (`name: "host"`) `rate_limit` lines before `before_action :set_game`, so both run ahead of the game lookup, as `ClaimsController`, `NoSetsController` and `EndGamesController` already order theirs. Their numbers, keys, names and `with:` stay as they are. The room-creation limit on `create` may move with them or stay; `create` has no `set_game`
- `spec/requests/in_game_rate_limits_spec.rb`: the request specs below, with the file's existing `MemoryStore` seam and `preload` helper, and `capture_turbo_stream_broadcasts` on the room's `game:<code>` stream and the acting player's `player:<id>` stream for "broadcasts nothing", as `spec/requests/claims_spec.rb` does. A request from another address passes `env: {"REMOTE_ADDR" => ...}`, as the file's stranger example does
- Must not touch: any limit's number, key, name or window; the key methods in `ApplicationController`; the room-creation and join limits (`PlayersController`'s join limit stays after `set_game`: its refusal renders the join page, which needs the room); the claims controller's `stamp_arrival` order; any view, JavaScript, model or the schema

## Acceptance criteria

- A ready request and a Start game or Play again request over their limits, for a room code that exists, answer `429` with an empty body without the game being looked up
- A ready request, and a Start game request, for a room code that does not exist answer `404` under the limit and are counted: with the count preloaded to 30 for that key, the next one answers `429`
- A player at the No Set limit still has SET! answered as today, and the claim is taken
- For each of the five limits (claims, ready, No Set, End game, the host's Start game and Play again), a refused request broadcasts nothing on the room's stream or the acting player's stream
- Ready, claims, No Set and End game requests with no `player_token` cookie are counted by IP: with one address at the limit, a cookie-less request from it answers `429`, one from a second address answers as today (`403` or `404`), and a player with the cookie on the first address is answered as today
- A player at the limit on one address does not use up a cookie-less request's count from that address: the cookie-less request answers `403` or `404` as today
- Start game requests with no `host_game` cookie are counted by IP the same way: one address at the limit answers `429` to a cookie-less request, a second address answers `403`, and the host at the first address still has Start game answered as today
- Every existing example in the file passes unchanged, and the file runs under 8 s

## Verification

`bin/test-all && bundle exec standardrb`

Write first: the unknown-room-code examples for ready and Start game (they fail today: the `404` comes before the count, so the preloaded request answers `404`, not `429`), then the rest. The examples for the criteria already met by the other controllers (broadcasts, the No Set limit leaving claims, the cookie-less counts) may pass on first run: they cover criteria ticket 60 left untested, so show them failing by commenting out the controller's `rate_limit` line, then restore it. Keep the file under 8 s; split it by its `describe` groups when `bin/test-all` names it.

## Out of scope

- Changing any limit's number, key or store, or adding a limit
- The bots limit (ticket 62, whose Scope now orders its limit before the room lookup)
- Moving the repeated `cache_store` stub into a shared helper (ticket 81)
- A message on any screen when a request is refused

## Comments

Decided: no spec change, because SPEC §5 Rate limits already says a refused request changes nothing and a cookie-less request is counted by IP; only the code and specs lag. Instead of: a spec edit restating it.

Decided: the same flaw searched in every controller: `ClaimsController`, `NoSetsController` and `EndGamesController` declare their limits before `set_game` already, `ControllersController`, `ClocksController` and `LobbiesController` have no limit (GETs, out of scope for 60), and `PlayersController`'s join limit stays after `set_game` because its refusal renders the join page from the room and its free colors. Only `GamesController` changes. Instead of: reordering the join limit too.

Decided: ticket 62's Scope gains a line to declare the bots limit before the room lookup, because the bots controller is not built yet and is the one other path of the same kind. Instead of: a follow-up fix after 62 is built.

Decided: "no model call" is checked by what a request answers (an unknown room code under the limit counted, at the limit `429` rather than `404`), because that is what the reorder changes and a spec needs no stub on `Game` for it. Instead of: expecting `Game.find_by!` not to be received.

Decided: examples that pass on first run are shown red by commenting out the limit, because they test criteria the code already meets. Instead of: skipping the red step for them.

Decided: no blocking edge on 81, though 81 moves this file's `cache_store` stub, because either order merges cleanly and neither changes the other's assertions. Instead of: Blocked by 81.

Decided: Priority low, because only a script meets a limit and the change is behind the scenes. Instead of: normal, as 60 was.

Decided: Security left empty, because the change reorders two limits and adds specs, leaving who can do or see what as it is, and the counting keys are only read. Instead of: Security: yes as 60 and 62 have, which would hold this build for review.

Decided: no schema change, because the counts stay in the cache store. Instead of: a counter column.

Decided: the two examples that check counts stay apart (No Set at its limit still claims; a player at the limit leaves the IP's count alone) were not shown red by removing the limits, because they can only fail when two keys merge, which commenting out a limit does not cause. Instead of: a contrived key change to force them red.
