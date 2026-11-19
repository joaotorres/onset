# 59: The player screen reads its claim in one place

Status: needs-triage
Kind: behavioural
Blocked by:
Priority:
Feature:
Model:
Effort:
Changelog:

## Request

Deferred from 56. The player screen reads its claim in one place. `ControllersController#show` sets `@my_claim = @game.current_claim if @game.claim_player_id == @player.id`, but nothing reads it: `controllers/show.html.erb` renders `players/_controller_status`, which works the same claim out again on its own line 4. Drop the controller's copy and check no other controller, view or broadcast computes the claiming player's claim apart from `_controller_status`.

## Comments
