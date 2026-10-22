# 34: Screens ignore broadcasts older than what they show

Status: done
Kind: behavioural
Blocked by:
Model:
Effort:
Changelog: Starting a game no longer leaves the big screen or a phone stuck on the lobby when two updates arrive out of order.

## Request

Screens must never fall back to an older game state when two broadcasts arrive out of order (ActionCable delivers each message through a multi-thread worker pool, so a stale ready-vote broadcast can land after the game-start one and leave the big screen and phones on the lobby; reproduced in big_screen_spec.rb:95, CI run 39411616401). Agreed fix: stamp each broadcast target's root element with a version from updated_at (board, announcement, start_button, room_tile: the game's; scoreboard and controller_status: the newer of the game's and the players'/player's), and a global Turbo before-stream-render listener drops a replace whose version is strictly older than the element on the page, letting equal versions through so the time-driven rebroadcasts (UnblockNoSetJob, UnlockBroadcastJob) still render. No migration and no lock_version column. Specs cover older, equal and newer versions and both jobs; SPEC §7 gets a short addition.

Settled in conversation:

Evidence: under CPU stress the example failed 1 in 40. A probe on Turbo::StreamsChannel#transmit showed the big screen's connection receive the second voter's board=playing, then the first voter's board=waiting about 90 ms later: a worker thread picked the stale message up first and was descheduled before writing it. In the test env the second /ready request waits for the first one's broadcast (transactional fixtures pin one locked connection), so only delivery reorders there. In production the emission can reorder too: the first voter's after_commit renders from a waiting in-memory game after the lock is released (inferred from the code, not reproduced).

Equal versions must pass: UnblockNoSetJob and UnlockBroadcastJob rebroadcast because time passed, with no game write. Player-only changes (claim.rb lockout, Player#broadcast_controller_status) do not touch the game, which is why scoreboard and controller_status take the newer of game and player times.

Version source is updated_at, not a counter column: no migration, and SQLite's single writer with Rails 8 immediate transactions keeps it monotonic. A column named lock_version would turn on optimistic locking, so it is ruled out.

big_screen_spec.rb:95 stays as it is: waiting for the first vote to show before the second would hide this bug. realtime_sync_spec and telemetry_spec share the back-to-back vote and the same rare flake until this lands.

## Spec references

- §7 Realtime, "Screens ignore broadcasts older than what they show"
- §7 Realtime, "Hooks that must survive any markup change" (each root carries `data-version`)
- §7 Realtime, "Actions answer 204, broadcasts update the screen" (the bookkeeping paragraph, reworded)
- §12 Background Jobs, `UnblockNoSetJob` (and `UnlockBroadcastJob`, which the code has beside it)

## Scope

Touches:

- A view helper, `stream_version(*records)`, that returns the newest `updated_at` among the records given as integer microseconds since the epoch (`(t.to_r * 1_000_000).to_i`, never a float: 16 digits do not fit a double). Every record passed is already loaded; the helper runs no query of its own.
- The root element of each broadcast partial gains `data-version`: `games/_board` (all three branches), `games/_announcement`, `games/_start_button`, `games/_room_tile` with `stream_version(game)`; `games/_scoreboard` with `stream_version(game, *players)` over the players it already lists; `players/_controller_status` with `stream_version(game, player)`. The same partials render the initial page, so the page starts stamped.
- A small JS module beside `server_clock.js`, pinned in `config/importmap.rb` and imported from `application.js`, that listens for `turbo:before-stream-render` on `document`. For a `replace` whose template root has `data-version` and whose target id is on the page with a `data-version` of its own, it compares the two as numbers and cancels the render (replaces `event.detail.render` with a no-op) when the incoming version is strictly smaller. Everything else, including streams with no version, `targets`, other actions and absent targets, renders as before.
- Specs: a helper spec for `stream_version`; the broadcast examples below in `spec/models/game_spec.rb`, `spec/models/player_spec.rb` and `spec/jobs/` (a new `unlock_broadcast_job_spec.rb` beside `unblock_no_set_job_spec.rb`, using `capture_turbo_stream_broadcasts` as that spec does); one system spec, `spec/system/stale_broadcasts_spec.rb`, for the listener.

Must not touch: the database (no migration, no column), `Game#broadcast_game_state` and `broadcast_lobby_state` beyond what the partials need, which records are written by any action, `Player#seen!`, the jobs' timing, `big_screen_spec.rb` (its back-to-back vote stays), the design system, any copy.

## Acceptance criteria

1. `stream_version(game)` equals the game's `updated_at` in integer microseconds; `stream_version(game, player)` equals the newer of the two; order of arguments does not matter.
2. On the rendered big screen and player screen, `#board`, `#announcement`, `#start_button`, `#room_tile`, `#scoreboard` and `#controller_status` each carry `data-version`, and the game-only ones equal `stream_version(game)`.
3. After `vote_start!` from the last voter starts the game, the `board` broadcast captured on `game:<code>` carries a version equal to the game's new `updated_at`, greater than the one on the `board` broadcast of the earlier vote.
4. After a player's `update!(locked_until: ...)` with no game write, the `controller_status` broadcast on `player:<id>` carries a version newer than the game's `updated_at`; a scoreboard broadcast rendered for that room afterwards carries that same version.
5. `UnblockNoSetJob#perform` and `UnlockBroadcastJob#perform`, run with no write in between, broadcast `board`/`announcement` (unblock) and `scoreboard`/`controller_status` (unlock) whose `data-version` equals the version the same partial renders before the job: equal, so the screen renders them.
6. System spec, big screen subscribed and `#room_tile` present: a hand-made `Turbo::StreamsChannel.broadcast_replace_to("game:<code>", target: "room_tile", html: ...)` whose root carries a version one lower than the page's and a marker text never shows: the spec then sends a second replace to `#announcement` with a version one higher and a sentinel text, waits for the sentinel and asserts the marker is absent. The same replace with an equal version shows its marker; with a higher version shows its marker.
7. A replace whose root has no `data-version` still renders on a stamped target.
8. `spec/system/big_screen_spec.rb` is unchanged and passes, with the two ready votes still back to back.
9. The rest of the suite stays green.

## Verification

Write first: the helper spec, examples 3 to 7, and see 1 to 7 fail on the current code (no attribute, no listener). Then:

```
bundle exec rspec
```

## Out of scope

- A `lock_version` or any counter column, optimistic locking, a migration.
- Versions on anything but the six hook roots in §7 (no versioning of the hidden `game-events` element or the Stimulus controllers).
- Dropping or reordering on the server (no queue, no mutex around the broadcasts, no change to the cable adapter or worker pool).
- Changing what `UnblockNoSetJob`, `UnlockBroadcastJob` or any job renders or when it runs.
- Making `big_screen_spec.rb:95` wait between the two votes.
- Handling `update`, `append`, `prepend`, `remove` or morph streams: the app sends only `replace`.
- Clock skew between servers: one server, one SQLite writer.

## Comments

Decided: the version is integer microseconds since the epoch (`(updated_at.to_r * 1_000_000).to_i`), compared as numbers in JS, because a 16-digit float loses the last digits and a string compare breaks across digit counts, while 1.7e15 microseconds sits well under 2^53. Instead of: `updated_at.to_f` or an ISO string.

Decided: a replace with no version, or one whose target is not on the page, renders as Turbo would, because only the six §7 hooks are stamped and a missing stamp must not hide a region; the check is a guard on the stamped ones, not a contract for every stream. Instead of: dropping unstamped streams or requiring a version on all.

Decided: the listener drops by replacing `event.detail.render` with a no-op rather than `preventDefault`, because the Turbo event is cancelable in some versions and not others, while the render override is the documented hook; the builder may use whichever the installed Turbo honours, with the system spec as the judge. Instead of: fixing the mechanism in the spec.

Decided: the listener is tested through a system spec that broadcasts hand-made streams with older, equal and newer versions and a sentinel on a second region, because the repo has no JS test runner and the sentinel makes the negative assertion deterministic in both directions (without the fix the stale marker shows and stays). Instead of: a `sleep` after the stale broadcast or asserting that the back-to-back vote never flakes.

Decided: the bookkeeping paragraph in §7 keeps its rule and changes its reason, because `seen!` writing without callbacks is still right (a broadcast per heartbeat shows nothing new) but "a stale one can win" is no longer true once stale replaces are dropped, and the spec must not contradict itself. Instead of: leaving the paragraph as it was or dropping it.

Decided: no glossary entry, because the version is a transport detail no player or screen names; the glossary stays the game's language. Instead of: adding "Version" or "Stale broadcast" to GLOSSARY.md.
