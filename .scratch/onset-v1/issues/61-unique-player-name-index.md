# 61: Back the unique player name rule with a database index

Status: done
Kind: behavioural
Blocked by: 54
Priority: low
Feature: Waiting room
Model:
Effort:
Changelog: Two players joining at the same moment with the same name can no longer both get in; the second sees the taken-name message.

## Request

Deferred from 54. Back the rule that no two players in a room share a name (case-insensitive) with a database unique index, so two joins at the same moment with one name cannot both get in; today it is a read-then-write check in `Player`, and a join that loses the race should come back with the name error as a taken name does.

## Spec references

- Shared: 4. Data Model, `Player` (Validations: the `(game_id, lower(name))` index; The 8-player cap: a join or bot add that loses a race)
- 8. Join page (a name already in the room, a join at the same moment included)

## Scope

- One additive migration: a unique expression index on `players` over `game_id` and `lower(name)`, the same `LOWER` the model's `name_unique_within_game` check uses, so the two agree on what counts as one name. The index must survive `db/schema.rb` (the test database loads from it): if the schema dump cannot carry the expression, say so in a `Decided:` line and fix it there, never by switching the check to Ruby's `downcase`
- `Player` keeps its read-then-write name check as the friendly first answer; the index is the guarantee behind it
- `PlayersController#create`: a save that fails on the unique index (`ActiveRecord::RecordNotUnique`) is answered as the validation would have answered it. Ticket 54 (built first, `Blocked by`) adds a `RecordNotUnique` rescue for the color index; extend that one handling rather than adding a second: once the race is lost the winning row is committed, so re-running the validations names what is now taken, the name error under the name field, the color error and the next free color as 54 does, or both. `422`, the join page re-rendered, no 500
- Specs: a model spec for the index and request specs for the race in the players create request specs, next to the existing taken-name examples
- Must not touch: the join page's look or copy, the name error's wording, the color rules and index of ticket 54, the join rate limit, bots (ticket 47 builds them on this index)

## Acceptance criteria

- The database refuses a second player in one game whose name matches an existing one case-insensitively ("Alex" then "alex"), even when the model's check is skipped: a model spec inserting past the validation raises `ActiveRecord::RecordNotUnique`
- The same name in two different games is still accepted by the database
- A join that hits the name index (the model's check passed, the insert lost the race) answers `422` with the name error under the name field and creates no player, not a 500 (request spec, simulating the race by stubbing the check or raising `RecordNotUnique` on save); the player's color choice is kept when it is still free
- A join that loses the race on both name and color shows both errors, and the color moves to the next free one as ticket 54's race handling does
- A join with a name already taken, no race involved, answers as today: `422`, the name error
- A join with a free name and color still works as today: player created, `player_token` cookie set, redirect to the player screen
- `db/schema.rb` carries the new index, so a database loaded from it refuses the duplicate too (the model spec above runs against the schema-loaded test database)

## Verification

`bin/test-all && bundle exec standardrb`

Write first: the model spec (case-variant duplicate in one game raises `RecordNotUnique`, same name in another game saves) and the request specs (name race answered `422` with the name error, both-race answered with both errors). Show them failing before the migration and the controller change.

## Out of scope

- Unicode case folding beyond what SQLite's `LOWER` does (it folds ASCII only, as the model's check already does): "Émile" and "émile" stay two names, as today
- Trimming or normalising names before the check
- The bot add path and its names (tickets 47, 48): SPEC §4 says what a bot add that loses a race does, and 47 builds it
- Deleting or renaming players already stored with clashing names

## Comments

Triage notes, 2026-11-19. Confirmed from the code: `Player#name_unique_within_game` checks `LOWER(name) = LOWER(?)` in the game before insert, and `players` has indexes only on `game_id` and `session_token`. Searched for every read-then-write uniqueness of the same kind: the color check gets its index in ticket 54 (ready, not built), `session_token` and `games.code` already have unique indexes, and the bots' "lowest free name" (47, 48, not built) will meet this index when built. The 8-player cap is the color index, so nothing else needs one.

Decided: one additive migration, a unique expression index on `players` over `game_id` and `lower(name)`; no column added, nothing backfilled, its rollback drops the index and loses nothing. If a live room already holds two players whose names differ only in case (only a race could make one), the index fails to build, the deploy stops and the running version stays up, as ticket 54 decided for colors. Instead of: leaving the rule to the model's read-then-write check.

Decided: the index lowers with SQLite's `LOWER`, the function the model's check already compares with, because then the database and the validation agree on every name and a race never answers differently from a plain taken name. Instead of: a Ruby-side `downcase` or a stored lowered column.

Decided: Blocked by 54, because both rescue `RecordNotUnique` in `PlayersController#create` and this one extends 54's handling to tell the name from the color by re-running the validations. Instead of: building them in either order and merging two rescues.

Decided: a bot add that loses the name or color race is ignored, still `204`, as an add with no color free, written into SPEC §4, because SPEC §5 already ignores a bot add it cannot place and 47's triage notes chose the same for the color race. Instead of: retrying with the next free name.

Decided: Priority low, because only two joins with one name in the same instant hit it, and the cost is two players sharing a name, not a broken room. Instead of: normal.

Decided: quick review 20261120-055231 leaves the lost race's stale colors to a follow-up, because the fix is plain and the build met its criteria as its specs read them. Instead of: reopening 61.

Deferred: A join that loses the race at the players color or name index re-renders the join page from colors loaded before the save: `PlayersController#create` rescues `RecordNotUnique` in `save_player` but never reloads `@color_owners` (`set_color_owners`), so `color_for_rerender` keeps the lost color selected, its swatch draws as free, and when the winner took the last color `full?` stays false and the page never says the room is full. Reload the taken colors in the rescue before re-rendering, and add request specs whose stubbed save commits the winner and then raises (today's race examples in `spec/requests/players/create_spec.rb` create the winner before the request, so they never see the stale load): the next free color selected, and the room-full answer when it was the last color.
