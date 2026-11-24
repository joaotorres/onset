# 74: A join that loses the race re-renders with fresh colors

Status: done
Kind: behavioural
Blocked by:
Priority: low
Feature: Waiting room
Model:
Effort:
Changelog: A join that loses a split-second race for a color now comes back with the next free color picked, or says the room is full when that was the last one.

## Request

Deferred from 61. A join that loses the race at the players color or name index re-renders the join page from colors loaded before the save: `PlayersController#create` rescues `RecordNotUnique` in `save_player` but never reloads `@color_owners` (`set_color_owners`), so `color_for_rerender` keeps the lost color selected, its swatch draws as free, and when the winner took the last color `full?` stays false and the page never says the room is full. Reload the taken colors in the rescue before re-rendering, and add request specs whose stubbed save commits the winner and then raises (today's race examples in `spec/requests/players/create_spec.rb` create the winner before the request, so they never see the stale load): the next free color selected, and the room-full answer when it was the last color.

## Spec references

No spec change. The code falls short of what these already say:

- 8. Join page (a color taken between render and submit, a join at the same moment included, comes back with the color error and the next free color after it selected; any other re-render keeps a free choice; with every color taken the room is full: none selected, "This room is full", **Join** disabled; taken colors faded with the taker's initial)
- Shared: 4. Data Model, `Player` (The 8-player cap: a join that loses the race for a color comes back as a taken color does, one that loses it for a name as a taken name does)

## Scope

- `PlayersController#create`, the failed-save branch: read the room's taken colors again (`set_color_owners`, or the same query) after the save has failed and before `color_for_rerender` and the render, so every failed join re-renders from the players committed by then. This covers both ways the stale load shows: the `RecordNotUnique` rescue in `save_player`, and a save whose validations fail on a color or name another join committed after the `before_action` loaded `@color_owners`. Everything that reads `@color_owners` on that render then agrees: `free?`, `color_for_rerender`, `full?`, the swatches drawn taken with the taker's initial and their "Taken by" title, and the hint under the colors
- `spec/requests/players/create_spec.rb`: request specs whose stubbed `Player#save` commits the winner during the request, after the `before_action` has loaded the colors, then either raises `ActiveRecord::RecordNotUnique` (the race at the index) or carries on to the real save (the validations see the winner). Insert the winner with `create!`, which goes through `save!`, so the stub on `save` does not catch it. Use the file's existing helpers (`checked_colors`, `radio_for`, `presets`)
- Must not touch: the color rules of `color_for_rerender` (next free after the clash, wrapping; a free choice kept; anything else the first free), the error wordings, the join page's look and copy, the rate limit, the `game already started` redirect, the `player_joined` event, and the `host_player_id` handling ticket 70 adds to the same action

## Acceptance criteria

- A join whose save loses the race at the color index to a winner committed during the request (stubbed save: create the winner on the posted color, then raise `RecordNotUnique`) answers `422`, shows the color error, creates no player for the loser, selects the next free color after the posted one (preset order, wrapping), and draws the posted color as taken: its radio disabled and unchecked, the winner's initial on its swatch
- The same race when the winner took the last free color (seven other players already in the room) answers `422` with "This room is full" in the base error box, no color selected and **Join** disabled
- A join that loses the race on the name to a winner committed during the request on another color (stubbed save: create the winner, then raise) answers `422` with the name error, keeps the player's color when it is still free, and draws the winner's color as taken
- A join whose validations fail on a color another join committed during the request, with no `RecordNotUnique` (stubbed save: create the winner on the posted color, then call the real save), answers as a taken color does: `422`, the color error, the next free color after it selected, the posted color drawn taken; and when that was the last free color, the room-full answer above
- Every existing example in `spec/requests/players/create_spec.rb` passes unchanged: the plain taken color and name, the three races with the winner created before the request, the ninth join, the free join

## Verification

`bin/test-all && bundle exec standardrb`

Write first: the four request-spec groups above, in `spec/requests/players/create_spec.rb` next to the existing race examples. Show them failing (the posted color still checked and drawn free, no "This room is full") before the controller change.

## Out of scope

- Updating the join page live as others join: SPEC §8 Join page says it does not; only a re-render after a submit reads the colors again
- Changing which color a re-render selects, or any wording on the page
- Bots and the bot add path (tickets 68, 70): an add answers `204` and renders no page
- The `host_player_id` change ticket 70 makes in `PlayersController#create`

## Comments

Triage notes, 2026-11-20. Confirmed from the code: `before_action :set_color_owners` loads `@color_owners` once, before `create` saves; `save_player`'s rescue re-runs the validations against the database but leaves `@color_owners` as loaded, and the failed-save branch hands the stale hash to `color_for_rerender` and the view (`full?`, the swatches, the hint). Searched for every place the same flaw lives: the only readers of `@color_owners` are `free?`, `first_free_color`, `full?`, `color_for_rerender` and `players/new.html.erb`, all on that one render; the non-race failed save has the same stale load when another join commits between the `before_action` and the validations; `new`, `join` and the rate-limit answer load and render with no save in between, so they show what was taken when they loaded. No other controller re-renders a page after a failed write (bots and every screen action answer `204`).

Decided: reload the taken colors on every failed save, in `create`'s failure branch, not only in the `RecordNotUnique` rescue, because a save whose validations see a join committed after the `before_action` shows the same stale page, and one reload there covers both. Instead of: reloading inside the rescue alone, as the request names.

Decided: no spec change, because SPEC §8 Join page already says a color taken between render and submit comes back with the next free color selected and a room with every color taken comes back full; the code falls short of it. Instead of: adding a sentence that a re-render reads the colors afresh.

Decided: Priority low, because only joins landing in the same instant hit it, and the cost is a re-rendered page that offers a taken color, whose next submit answers correctly. Instead of: high, for broken behaviour in built work.

Decided: `set_color_owners` queries `Player.where(game: @game)` instead of `@game.players`, because once `create` builds the join on the association its cached target holds the unsaved player and not the players committed since, so a reload through it would draw the loser's own color as taken and miss the winner. Instead of: `@game.players.reload`, which drops the built player from the association as a side effect.
