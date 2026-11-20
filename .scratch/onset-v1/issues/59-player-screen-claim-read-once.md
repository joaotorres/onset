# 59: The player screen reads its claim in one place

Status: deployed
Kind: behavioural
Blocked by:
Priority: low
Feature: Claiming a SET
Model:
Effort:
Changelog: Behind the scenes: the player screen no longer computes an unused copy of the claim.

## Request

Deferred from 56. The player screen reads its claim in one place. `ControllersController#show` sets `@my_claim = @game.current_claim if @game.claim_player_id == @player.id`, but nothing reads it: `controllers/show.html.erb` renders `players/_controller_status`, which works the same claim out again on its own line 4. Drop the controller's copy and check no other controller, view or broadcast computes the claiming player's claim apart from `_controller_status`.

## Spec references

No spec change. SPEC `## Shared: 6. Round State Machine`, `### Key invariants`, the current-claim item ("The claiming player's screen reads its claim the same way") already covers it; this removes a second, unread copy of that read.

## Scope

Confirmed from the code (searched `current_claim`, `my_claim`, `claim_player_id`, `claims.` and `pending` across `app/`):

- `ControllersController#show` (`app/controllers/controllers_controller.rb`, line 7): drop the `@my_claim = ...` line. Nothing reads `@my_claim`: `controllers/show.html.erb` renders `players/_controller_status` with `player:` and `flash_claim:` only, and no spec reads it
- `players/_controller_status.html.erb`, line 4, stays the one place the claiming player's claim is read, through `Game#current_claim`
- Checked and left alone, as they are not the same read: the three `players/controller_status` broadcasts (`Game` lines 102-107 and 279-284, `Player#broadcast_controller_status`) pass no claim, so the partial reads it itself; `games/_scoreboard` and `players/controller/_scoreboard` compare `claim_player_id` to mark who is claiming, never the claim; `ClaimsController#held_claim` looks up the claim in the URL and its player, and `Claim#pick!`/`#submit!` then check `current?`; `Player#lockout_reason` reads resolved claims

Must not touch: `Game#current_claim`, `Claim#current?`, the partial's markup, the broadcasts, `ClaimsController`.

## Acceptance criteria

- `ControllersController#show` no longer computes the claim; `@my_claim` appears nowhere in `app/`
- The claiming player's screen still posts picks and Submit to the running claim, not a leftover one from an earlier game (`spec/requests/players/controller_spec.rb`, "posts picks to the running claim, not a leftover one from an earlier game", stays green)
- Every other player screen spec stays green

## Verification

`bin/test-all && bundle exec standardrb`

No new test to write first: the change removes an unread assignment and alters nothing a test can observe, so the existing request spec above is the guard.

## Out of scope

- Moving the claim read out of the partial into a helper or `Player` method
- Any other unused instance variable or cleanup in other controllers
- The claim paths' current-claim checks (ticket 56)

## Comments

Decided: no spec change, because SPEC §6 Key invariants already says the claiming player's screen reads the room's current claim, and the partial does; the controller's copy is dead code. Instead of: a §6 edit.

Decided: the scope is the controller line alone, because a search of `app/` found no other controller, view or broadcast computing the claiming player's claim: broadcasts pass none, the scoreboards compare `claim_player_id` only, and `ClaimsController#held_claim` is the URL's claim checked by `current?`, a different read. Instead of: also reworking `held_claim` or the scoreboards.

Decided: no new failing test before the change, because removing an unread assignment changes nothing observable and a spec on a controller's instance variable would test the implementation; the existing leftover-claim request spec guards the behaviour. Instead of: an `instance_variable_get` spec.

Decided: Priority low, as a cleanup no user notices. Instead of: normal.

Decided: Feature "Claiming a SET", ticket 56's, where the duplicate read came from. Instead of: a new feature name.

Decided: no conflict with open tickets 42, 46, 47, 48, 54 or 60, none of which touches the player screen's claim read; there is no spec change to check against those not yet deployed. Instead of: blocking on 47, which shows a bot's claim through the same partial.
