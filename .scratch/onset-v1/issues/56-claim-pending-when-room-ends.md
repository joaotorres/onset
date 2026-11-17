# 56: A claim still pending when the room ends is not judged after the game is over

Status: needs-triage
Kind: behavioural
Blocked by:
Priority:
Feature:
Model:
Effort:
Changelog:

## Request

Deferred from 55. A claim still pending when the room ends is judged after the game is over: `Game#vote_end_game!` ends the room without checking for a running claim, and `ExpireClaimJob`, `Claim#submit!` and `Claim#pick!` check only that the claim is pending, never that the room is playing. So a correct one flips the ended room back to `playing` (`resolve_correct!` writes `status: :playing`), a wrong or timed-out one costs a point after the podium shows, and after Play again (`restart!` clears `claim_player_id` but leaves the Claim row pending) the old claim can still be submitted or expire in the new game, against the new board. Decide in SPEC §2 and §6 whether the End game vote waits for a running claim or voids it, then make every claim path (submit, pick, expiry, `BotSubmitJob` once built) act only while the room is playing and the claim is the room's current one.

## Comments
