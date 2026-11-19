# 55: Start game and Play again act only in their state

Status: deployed
Kind: behavioural
Blocked by:
Priority: high
Feature: Game lifecycle
Model:
Effort:
Changelog: A late or repeated Start game or Play again tap no longer reshuffles a running game or wipes the scores.

## Request

Deferred from 11. The host's Start game and Play again act only in the state they belong to. `Game#start!` (`app/models/game.rb`) takes no lock and checks no status, `restart!` runs in any status, and `GamesController#start` and `#restart` check only the `host_game` cookie. So a Start game tap that lands once the game is playing (the last ready vote started it a moment before, a double tap before the broadcast removes the button, or a big screen whose button is stale after a dropped connection or a back-button visit) deals a new board mid-game with the scores kept, a Play again that lands while a game is playing zeroes the scores, and one in a waiting room starts it whatever the player count; a claim pending at that moment stays pending and `ExpireClaimJob` later resolves it in the new game. SPEC §6 says transitions always run under the game lock, and §17 names the two as `waiting` to `playing` and `ended` to `playing`; the ready votes already check (`vote_start!`, `vote_play_again!`). Say in SPEC §5 Routes that each is ignored, still `204`, outside its state, as the bot routes say; make `start!` act only when `waiting?` and `restart!` only when `ended?`, both under the game lock (`vote_start!` and `vote_play_again!` call them inside theirs), and add model and request specs for a start while playing, a restart while playing and a restart while waiting. From the security review `.scratch/onset-v1/reviews/security-20261115.md`, finding F5.

## Spec references

- SPEC `## Shared: 5. Routes`, the `POST /games/:code/start` and `POST /games/:code/restart` rows: each ignored, still `204`, outside its state
- SPEC `## Shared: 6. Round State Machine`, `### Key invariants`: starting acts only from `waiting` and restarting only from `ended`, checked inside the lock

## Scope

Confirmed from the code: `Game#start!` updates with no lock and no status check; `Game#restart!` takes the lock but checks no status; `GamesController#start` checks the cookie and `players.count >= 2`, `#restart` only the cookie. The ready votes (`vote_start!`, `vote_play_again!`) already check status inside their lock and call `start!` / `restart!` there, so a nested `with_lock` on the same record is a no-op for them.

- `Game#start!`: inside `with_lock`, does nothing unless `waiting?`. Returns a truthy value when it started the game and `nil` when ignored, as the other refused transitions do
- `Game#restart!`: inside its existing `with_lock`, does nothing unless `ended?`, same return convention
- `GamesController#start` and `#restart`: unchanged apart from relying on the model guard; both still answer `403` without the cookie and `204` otherwise, ignored or not. The `players.count >= 2` check on Start game stays in the controller
- Existing specs that call `start!` on a game already playing must set it back to `waiting` first: today the model spec "clears the refusal on start!" in `spec/models/game_spec.rb` does. Every other `restart!` call in the suite already starts from `ended`; check with a search before the run

Must not touch: the views (the buttons already show only in their state), the ready votes' own checks, telemetry, the claim and No Set paths.

## Acceptance criteria

- `start!` on a playing game leaves its board, deck, discard and every player's score unchanged and returns `nil`
- `start!` on an ended game does nothing and returns `nil`
- `start!` on a waiting game starts it as today (12 cards, 69 in the deck, status `playing`)
- `restart!` on a playing game leaves its board, deck and every player's score unchanged and returns `nil`
- `restart!` on a waiting game leaves it waiting, its board and `start_voters` unchanged, and returns `nil`
- `restart!` on an ended game restarts it as today (scores zeroed, votes cleared, 12 cards, status `playing`)
- `POST /games/:code/start` from the host while the game is playing answers `204` and leaves the board and scores unchanged
- `POST /games/:code/restart` from the host while the game is playing answers `204` and leaves the board and scores unchanged
- `POST /games/:code/restart` from the host while the room is waiting with 1 player answers `204` and the room stays waiting
- Both routes still answer `403` without the `host_game` cookie
- `vote_start!` and `vote_play_again!` still start and restart the room once every voter is in (existing specs stay green)

## Verification

`bin/test-all && bundle exec standardrb`

Write first: in `spec/models/game_spec.rb`, under `#start!` a "while playing" and "while ended" context, under `#restart!` a "while playing" and "while waiting" context; in `spec/requests/games/start_spec.rb` a start while playing, in `spec/requests/games/restart_spec.rb` a restart while playing and a restart while waiting. Show them red before the guard.

## Out of scope

- A claim left pending when the room ends by the End game vote (see the Deferred paragraph below)
- Moving the 2-player check into the model, or the AI opponent's "at least one person" rule for Start game (ticket 47)
- Rate limits on host or gameplay actions (ticket 54)
- Any change to how the buttons look or when they show

## Comments

Decided: `start!` and `restart!` guard their own status inside the lock, rather than the controller checking `@game.waiting?` / `@game.ended?` before calling them, because the ready votes call the same methods and §6 puts transitions in the model under the lock. Instead of: a status check in `GamesController` only, which reads the status outside the lock.

Decided: the Start game player-count check (`players.count >= 2`) stays in `GamesController#start`, because dozens of specs start a game with no players through `start!` and `vote_start!` already checks the count itself. Instead of: moving it into `start!`.

Decided: both routes stay `204` when ignored, as the bot routes and every other screen action do (§5, §7), so a stale tap shows nothing and the next broadcast leaves the screen as it is. Instead of: a `409` or `422`, which no screen handles.

Decided: the SPEC §6 Key invariants gains a line that the room's own transitions check their status inside the lock, besides the §5 Routes rows the request names, because §6 is where the transition rules live. Instead of: §5 alone.

Decided: Priority high, as broken behaviour in built work (a stale or double Start game tap reshuffles a running game). Instead of: normal.

Decided: a claim still pending when the room ends by the End game vote, which then resolves after the game is over or in the next game, is left to a request of its own, below, because whether the vote waits for the claim or voids it is a behaviour the spec has not decided. Instead of: folding it into this fix.

Deferred: A claim still pending when the room ends is judged after the game is over: `Game#vote_end_game!` ends the room without checking for a running claim, and `ExpireClaimJob`, `Claim#submit!` and `Claim#pick!` check only that the claim is pending, never that the room is playing. So a correct one flips the ended room back to `playing` (`resolve_correct!` writes `status: :playing`), a wrong or timed-out one costs a point after the podium shows, and after Play again (`restart!` clears `claim_player_id` but leaves the Claim row pending) the old claim can still be submitted or expire in the new game, against the new board. Decide in SPEC §2 and §6 whether the End game vote waits for a running claim or voids it, then make every claim path (submit, pick, expiry, `BotSubmitJob` once built) act only while the room is playing and the claim is the room's current one. Filed as 56.
