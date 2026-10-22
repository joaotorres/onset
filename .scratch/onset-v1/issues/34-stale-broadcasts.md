# 34: Screens ignore broadcasts older than what they show

Status: needs-triage
Kind: behavioural
Blocked by:
Model:
Effort:
Changelog:

## Request

Screens must never fall back to an older game state when two broadcasts arrive out of order (ActionCable delivers each message through a multi-thread worker pool, so a stale ready-vote broadcast can land after the game-start one and leave the big screen and phones on the lobby; reproduced in big_screen_spec.rb:95, CI run 39411616401). Agreed fix: stamp each broadcast target's root element with a version from updated_at (board, announcement, start_button, room_tile: the game's; scoreboard and controller_status: the newer of the game's and the players'/player's), and a global Turbo before-stream-render listener drops a replace whose version is strictly older than the element on the page, letting equal versions through so the time-driven rebroadcasts (UnblockNoSetJob, UnlockBroadcastJob) still render. No migration and no lock_version column. Specs cover older, equal and newer versions and both jobs; SPEC §7 gets a short addition.

Settled in conversation:

Evidence: under CPU stress the example failed 1 in 40. A probe on Turbo::StreamsChannel#transmit showed the big screen's connection receive the second voter's board=playing, then the first voter's board=waiting about 90 ms later: a worker thread picked the stale message up first and was descheduled before writing it. In the test env the second /ready request waits for the first one's broadcast (transactional fixtures pin one locked connection), so only delivery reorders there. In production the emission can reorder too: the first voter's after_commit renders from a waiting in-memory game after the lock is released (inferred from the code, not reproduced).

Equal versions must pass: UnblockNoSetJob and UnlockBroadcastJob rebroadcast because time passed, with no game write. Player-only changes (claim.rb lockout, Player#broadcast_controller_status) do not touch the game, which is why scoreboard and controller_status take the newer of game and player times.

Version source is updated_at, not a counter column: no migration, and SQLite's single writer with Rails 8 immediate transactions keeps it monotonic. A column named lock_version would turn on optimistic locking, so it is ruled out.

big_screen_spec.rb:95 stays as it is: waiting for the first vote to show before the second would hide this bug. realtime_sync_spec and telemetry_spec share the back-to-back vote and the same rare flake until this lands.

## Comments
