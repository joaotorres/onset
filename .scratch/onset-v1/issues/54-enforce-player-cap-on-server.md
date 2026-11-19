# 54: Enforce the 8-player cap on the server

Status: ready-for-agent
Kind: behavioural
Blocked by:
Priority: high
Feature: Waiting room
Model:
Security: yes
Effort:
Changelog:

## Request

Enforce the 8-player cap on the server: a join whose color is not one of the free presets is refused, so a room never holds more than 8 players, with a unique index on a room's player colors so two joins at once cannot share one; today any #RRGGBB color is accepted, so a script can fill a room with hundreds of players and each game update then renders every player's screen for every player inside the request, stalling the app for all rooms (security review .scratch/onset-v1/reviews/security-20261115.md, section "F1. The 8-player cap is not enforced on the server", severity medium; touches security, so triage asks the owner before deciding).

From the review, so triage does not look it up again:

- Where: `PlayersController#create` saves any posted color; `Player` checks only the `#RRGGBB` format and uniqueness in the game; `players` has no unique index on `(game_id, color)`. `full?` and `PRESET_COLORS` only feed the join page
- Why it matters: `Game#broadcast_game_state` and `broadcast_lobby_state` render one `players/controller_status` per player, synchronously, on every join and every game update, and each of those lists every player. Joins are limited to 20 a minute per IP, which slows this but sets no cap; the gameplay POSTs (`/ready`, `/claims`, `/no_set`, `/end_game`) have no limit
- The review also suggests, for triage to take or leave: a `rate_limit` on the gameplay POSTs. The bots of ticket 47 take "the first free color", so they count towards the same 8
- Filed by the security pass of 2026-11-16, run on Fable while the owner was away. Nothing was run against the app: the finding is read from the code

## Spec references

- Shared: 4. Data Model, `Player` (the `color` row, Validations, The 8-player cap)
- Shared: 5. Routes, `POST /games/:code/players`
- 8. Join page (a join at the same moment)
- Shared: 10. Cards and visual system, Palette and Visual system (the preset list is `Player::PRESET_COLORS`)

## Scope

- `Player` owns the 8 preset colors as `Player::PRESET_COLORS` (same 8 hex values, same order). `PlayersController` and the join view read them from there; `PlayersController::PRESET_COLORS` goes
- `Player` validates on create that `color` is one of the presets, alongside the existing format and `(game_id, color)` uniqueness checks. Updates of an existing row are not checked against the list
- One additive migration: a unique index on `players (game_id, color)`
- `PlayersController#create`: a save that fails on that index (`ActiveRecord::RecordNotUnique`) is handled like a taken color, the color error on the field and the join page re-rendered with `422`, the next free color selected as `color_for_rerender` does, or "This room is full" with none free. No 500
- A posted color that is not a preset re-renders the join page with the color error and the first free color selected (what `color_for_rerender` already does for a non-preset)
- Specs: every spec and spec helper that creates a player with a non-preset color (`#3498DB`, `#648FFF`, `#FE6100`, `#DC267F` and the like) moves to a preset, keeping each room's colors distinct. Card palette colors in card and theme specs are not player colors and stay
- `docs/design-system.md`: its two mentions of `PlayersController::PRESET_COLORS` read `Player::PRESET_COLORS`, a records correction with no version bump
- Must not touch: the join page's look or copy, the 20-a-minute join rate limit, the gameplay routes, the name uniqueness check

## Acceptance criteria

- Joining with a color that is not one of the 8 presets is refused: no player is created, the response is `422` with the color error, and the join page shows the first free preset selected
- With 8 players in a room, one per preset, a ninth join is refused, whatever color it posts (a preset or any other hex): no player is created and the page says "This room is full"
- Joining with a free preset still works as today: player created, `player_token` cookie set, redirect to the player screen
- The database refuses a second player with the same color in one game even when the model's uniqueness check is skipped (a model spec inserting past the validation raises `ActiveRecord::RecordNotUnique`)
- A join that hits the unique index (the model's uniqueness check passed, the insert lost the race) answers `422` with the color error and the next free color selected, not a 500 (request spec, simulating the race by stubbing the uniqueness check or raising `RecordNotUnique` on save)
- An existing player whose color is not a preset (a row from before the rule) can still be updated: score, `locked_until` and `last_seen_at` save
- `Player::PRESET_COLORS` holds the 8 values `#E74C3C #2ECC71 #F1C40F #9B59B6 #1ABC9C #E91E63 #00BCD4 #8BC34A` in that order, and `PlayersController::PRESET_COLORS` no longer exists
- The whole suite passes with every spec player on a preset color

## Verification

`bin/test-all && bundle exec standardrb`

Write first: the model specs (non-preset refused on create, update of a non-preset row still saves, the index refusing a duplicate) and the request specs in the players request specs (non-preset refused, ninth join refused, the index race answered `422`). Show them failing before the code.

## Out of scope

- A rate limit on the gameplay POSTs (ticket 60)
- A database index on player names
- Bots (tickets 47, 48): they take the first free preset when built
- Deleting or rewriting players already stored with a non-preset color
- Any change to the join page's layout or copy

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

Answer, 2026-11-19, from the owner: 1 (build the server-side 8-player cap as triaged above: presets only, unique index on (game_id, color), spec players moved to presets) and 3 (the in-game tap limit goes in a ticket of its own, filed now with /request).

Decided: build the server-side cap as triaged, presets only on create, a unique index on `players (game_id, color)`, because the owner chose option 1 on 2026-11-19. Instead of: accepting the flooding risk.

Decided: one additive migration, a unique index on `players` over `game_id` and `color`; no column added, nothing backfilled, its rollback drops the index and loses nothing. Instead of: leaving uniqueness to the model's read-then-write check.

Decided: the preset check runs on create only, because a room live at the deploy may hold a player with a non-preset color, and checking on update would fail that player's next score or lockout write. Instead of: validating on every save.

Decided: a join that loses the race at the index re-renders like a taken color (422, the color error, the next free color or "This room is full"), because SPEC §8 Join page already says what a taken color looks like. Instead of: a 500 or a new message.

Decided: the tap limit is ticket 60, already filed from the owner's option 3, so this ticket leaves it out. Instead of: folding it in.

Decided: Security: yes, because the cap decides who may join a room and the ticket came from the security review. Instead of: leaving it empty.

Decided: the same read-then-write flaw in the name check (two joins at once with one name) is left out, because it never lets a room grow past 8 and the spec decides duplicate names on its own; filed as a follow-up below. Instead of: adding a name index here.

Deferred: Back the rule that no two players in a room share a name (case-insensitive) with a database unique index, so two joins at the same moment with one name cannot both get in; today it is a read-then-write check in `Player`, and a join that loses the race should come back with the name error as a taken name does.
