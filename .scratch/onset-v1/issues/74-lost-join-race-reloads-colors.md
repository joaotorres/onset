# 74: A join that loses the race re-renders with fresh colors

Status: needs-triage
Kind: behavioural
Blocked by:
Priority:
Feature:
Model:
Effort:
Changelog:

## Request

Deferred from 61. A join that loses the race at the players color or name index re-renders the join page from colors loaded before the save: `PlayersController#create` rescues `RecordNotUnique` in `save_player` but never reloads `@color_owners` (`set_color_owners`), so `color_for_rerender` keeps the lost color selected, its swatch draws as free, and when the winner took the last color `full?` stays false and the page never says the room is full. Reload the taken colors in the rescue before re-rendering, and add request specs whose stubbed save commits the winner and then raises (today's race examples in `spec/requests/players/create_spec.rb` create the winner before the request, so they never see the stale load): the next free color selected, and the room-full answer when it was the last color.

## Comments
