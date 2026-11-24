# 79: Behind the scenes: finish ticket 60's rate limits

Status: needs-triage
Kind: behavioural
Blocked by:
Priority:
Feature:
Model:
Effort:
Changelog:

## Request

Deferred from 60. Behind the scenes: finish ticket 60's rate limits. In `GamesController` the `ready` and host `rate_limit` lines sit after `before_action :set_game`, so a refused ready, Start game or Play again still loads the game, against the ticket's "no model call", and a request for an unknown room code answers `404` without being counted: declare both limits before `set_game`, as the claims, No Set and End game controllers have theirs first. Add the request specs the criteria lack in `spec/requests/in_game_rate_limits_spec.rb`: a player at the No Set limit can still claim; a refused request broadcasts nothing, for each of the five limits; and a request with no `player_token` cookie, or no `host_game` cookie for the host's limit, is counted by its IP, two addresses apart and never against a cookie holder's count.

## Comments
