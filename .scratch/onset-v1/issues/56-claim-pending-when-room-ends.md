# 56: A claim still pending when the room ends is not judged after the game is over

Status: deployed
Kind: behavioural
Blocked by:
Priority: high
Feature: Claiming a SET
Model: fable
Effort:
Changelog: A SET! call still running when the game ends can no longer reopen the game or change the scores; an End game tap during a call does nothing, so tap it again once the call is judged.

## Request

Deferred from 55. A claim still pending when the room ends is judged after the game is over: `Game#vote_end_game!` ends the room without checking for a running claim, and `ExpireClaimJob`, `Claim#submit!` and `Claim#pick!` check only that the claim is pending, never that the room is playing. So a correct one flips the ended room back to `playing` (`resolve_correct!` writes `status: :playing`), a wrong or timed-out one costs a point after the podium shows, and after Play again (`restart!` clears `claim_player_id` but leaves the Claim row pending) the old claim can still be submitted or expire in the new game, against the new board. Decide in SPEC §2 and §6 whether the End game vote waits for a running claim or voids it, then make every claim path (submit, pick, expiry, `BotSubmitJob` once built) act only while the room is playing and the claim is the room's current one.

## Spec references

- SPEC `## Shared: 2. Game Rules`, `### Round flow`, item 6 (Game end): an End game vote that lands while a claim runs is ignored, so the room never ends with a claim pending
- SPEC `## Shared: 5. Routes`, the `POST /games/:code/end_game`, `PATCH /games/:code/claims/:id` and `POST /games/:code/claims/:id/submit` rows
- SPEC `## Shared: 6. Round State Machine`, `### Key invariants`: the End game vote is refused while a claim is active; a claim is acted on only while it is the room's current claim
- SPEC `## Shared: 12. Background Jobs`, the `ExpireClaimJob` and `BotSubmitJob` entries

## Scope

Confirmed from the code. Every place the flaw lives:

- `Game#vote_end_game!` (`app/models/game.rb`): ends the room with no claim check. Inside its lock, return `nil` before recording the vote when `claim_active?`, as `call_no_set!` does
- `Claim#pick!` and `Claim#submit!` (`app/models/claim.rb`): check only `reload.pending?`. Inside the lock, check the claim is the room's current one instead
- `ExpireClaimJob#perform` (`app/jobs/expire_claim_job.rb`): checks only `claim.reload.pending?`. Same check
- The claiming player's claim lookup, in `ControllersController#show` (`@my_claim`) and at the top of `app/views/players/_controller_status.html.erb` (`my_claim`): both take `find_by(player:, result: :pending)`, which can return a leftover pending claim of the same player from an earlier game rather than the running one, so the screen would post picks to a claim the server now ignores. Both read the room's current claim
- `BotSubmitJob` is not built (ticket 47): its §12 entry now names the current-claim check, so it is not in this ticket's code

One definition of the current claim, used by every path above: the game is `playing?`, the claim is `pending?`, `claim_player_id == claim.player_id`, and the claim is the room's newest `Claim` (highest id). `try_claim!` creates a claim only when none is active, so the newest is the running one. Put it on the model, for example `Game#current_claim` (nil unless a claim runs while playing) and `Claim#current?`; the builder names them. Every check runs after the lock's reload, so it reads the state under the lock.

Existing specs that build a pending claim without making it the room's current one (status `playing`, `claim_player_id` set, no newer claim) will go red under the new check: `spec/models/claim_spec.rb`, `spec/jobs/expire_claim_job_spec.rb`, `spec/requests/claims_spec.rb` and the claim system specs and their support files. Set them up through `try_claim!` or set those fields; search for `result: :pending` before the run.

Must not touch: how a claim is judged once it is current (`expire!`, `resolve_correct!`, `resolve_wrong!`, `resolve_expired!`), `try_claim!`, `restart!` and `start!` (ticket 55), the views beyond the claim lookup, the End game pill (already not shown during a claim), telemetry.

## Acceptance criteria

- `vote_end_game!` while a claim runs (deck empty, playing) returns `nil`, leaves `end_game_voters` and the status unchanged, even when it would be the last vote
- `vote_end_game!` with no claim running still records the vote and ends the room once every active player has voted (existing specs stay green)
- `POST /games/:code/end_game` while a claim runs answers `204` and the room stays playing with the vote not recorded
- A pending claim on an ended room: `submit!` with a valid Set, `pick!`, and `ExpireClaimJob` each leave the claim pending, the player's score and `locked_until`, the room's status, board, deck and discard unchanged
- A pending claim left from an earlier game after a restart (room playing, `claim_player_id` nil): `submit!`, `pick!` and `ExpireClaimJob` each change nothing, as above
- The same leftover claim when its player holds a new claim in the new game (`claim_player_id` is that player, a newer claim exists): `submit!`, `pick!` and `ExpireClaimJob` on the old claim change nothing, and the new claim still judges as today
- `POST /games/:code/claims/:id/submit` and `PATCH /games/:code/claims/:id` on such a leftover claim, from its player, answer `204` and change nothing
- The claiming player's screen (`GET /games/:code/controller`), with a leftover pending claim of theirs and a newer running one, renders the running claim's PATCH and submit URLs
- A current claim still picks, submits and expires as today (existing specs stay green)

## Verification

`bin/test-all && bundle exec standardrb`

Write first: in `spec/models/game_spec.rb`, under `#vote_end_game!`, a "while a claim runs" context; in `spec/models/claim_spec.rb`, contexts for `#submit!` and `#pick!` on a claim in an ended room, a claim left from an earlier game and a claim superseded by its player's newer claim; the same three in `spec/jobs/expire_claim_job_spec.rb`; in `spec/requests/end_games_spec.rb` a vote while a claim runs; in `spec/requests/claims_spec.rb` a submit and a PATCH on a leftover claim; in `spec/requests/players/controller_spec.rb` the screen with a leftover and a running claim. Show them red before the guards.

## Out of scope

- Closing or deleting claims already left pending in the database (they stay `pending`, never judged)
- A `games.current_claim_id` column
- Clearing `end_game_voters` when a claim changes the board
- `BotSubmitJob` itself (ticket 47)
- The Start game and Play again guards (ticket 55)

## Comments

Decided: an End game vote that lands while a claim runs is ignored (not recorded, still `204`), so the claim is judged first and the room never ends with one pending, because §6 already refuses a No Set call while a claim is active, every claim path keys on the claim lock, and no screen offers End game during a claim (the pill slot shows the disabled No Set or Submit), so only a stale tap or a race meets it. Instead of: the vote voiding the running claim, which would throw away a Set the claimer may be about to score, or recording the vote and ending the room once the claim resolves.

Decided: the room's current claim is the pending claim whose player is `claim_player_id`, while the room is playing, and that is the room's newest `Claim`, so no migration, because `try_claim!` creates a claim only when none runs and the newest-id check tells a leftover claim from the same player's new one. Instead of: an additive `games.current_claim_id` column, or matching `claim_started_at` against `Claim#started_at`, which `try_claim!` stamps with two separate `Time.current` calls.

Decided: the scope adds the claiming player's claim lookup in `ControllersController#show` and `players/_controller_status.html.erb`, because it is the same flaw on the read side: `find_by(player:, result: :pending)` can return a leftover claim and send the picks to a claim the server now ignores. Instead of: the four write paths alone.

Decided: leftover pending claims already in the database stay as they are, because they are only audit records and the new check never judges them. Instead of: a backfill that closes them, a data change.

Decided: §12's `BotSubmitJob` entry names the current-claim check now, so ticket 47 builds it in, because the job is not built yet. Instead of: code for it here.

Decided: Priority high, as broken behaviour in built work (a claim can reopen an ended game or cost a point after the podium). Instead of: normal.

Decided: Model fable, because the current-claim check is logic every claim path and the bot's submit depend on, and a wrong one is hard to spot in review. Instead of: empty.

Decided: Feature "Claiming a SET", because the fix guards the claim paths. Instead of: "Game lifecycle", 55's.

Decided: no conflict with tickets 47, 54 or 55 nor the spec changes since the last deploy (tickets 52, 53, 55): 55 guards `start!` and `restart!` and leaves the claim paths to this ticket, and 47's `BotSubmitJob` takes the same check. Instead of: blocking on 55, which touches neither the claim paths nor the End game vote.

Decided: quick review 20261117-203012 corrected the Changelog line, which read as if an End game vote during a call is held and counted later; it is dropped and the player taps again (SPEC §2). Instead of: the original wording.

Decided: the glossary gap the quick review found is a follow-up, because it is a plain record fix with no choice in it. Instead of: a pending decision.

Deferred: GLOSSARY.md's Claim entry still says without condition that "a claim never submitted is judged on its picks when the window closes", and has no entry for "current claim", which SPEC now uses as a defined term (§5 PATCH and submit rows, §6 Key invariants, §12 ExpireClaimJob and BotSubmitJob). Add a Current claim entry matching §6 Key invariants (the room is playing, the claim is pending, held by `claim_player_id` and the room's newest claim; a claim left pending by an earlier game is never judged), and qualify the Claim entry so only the room's current claim is ever judged. Check every other glossary entry that mentions a claim being judged, expiring or submitted for the same unconditioned wording. Filed as 57.

Decided: deep review 20261117-211428 found the player screen's claim lookup written twice, the copy in `ControllersController#show` unread, and makes its removal a follow-up, because it is a plain cleanup with no choice in it. Instead of: a pending decision.

Deferred: The player screen reads its claim in one place. `ControllersController#show` sets `@my_claim = @game.current_claim if @game.claim_player_id == @player.id`, but nothing reads it: `controllers/show.html.erb` renders `players/_controller_status`, which works the same claim out again on its own line 4. Drop the controller's copy and check no other controller, view or broadcast computes the claiming player's claim apart from `_controller_status`. Filed as 59.
