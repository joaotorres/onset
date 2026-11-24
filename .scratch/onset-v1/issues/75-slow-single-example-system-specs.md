# 75: Bring the three slow single-example system specs under 8 s

Status: needs-triage
Kind: behavioural
Blocked by:
Priority:
Feature:
Model:
Effort:
Changelog:

## Request

Behind the scenes: `bin/test-all` named seven system spec files over CLAUDE.md's 8 s limit. Commit 4ef0768 already split four of them by their groups, as media-shelf 165 split its slow files (the shared setup and helpers in a shared context under `spec/support/system/`, one file per group): `big_screen/realtime_spec.rb`, `big_screen_fit/ended_spec.rb`, `big_screen_fit/waiting_spec.rb` and `big_screen_theme/rail_fit_spec.rb`. The run after it named only `waiting_spec.rb`, which was then split by window height and runs in 7.7 s.

Three remain, each a single example, so there is no group to split: `spec/system/realtime_sync/claim_spec.rb` (about 23 to 28 s), `spec/system/realtime_sync/game_over_spec.rb` (about 13 to 15 s) and `spec/system/telemetry_spec.rb` (about 10 s). Bring each under 8 s in a full `bin/test-all` run without changing what it asserts: find where the time goes first (likely the `"realtime sync"` shared context's phones joining through the UI in `spec/support/system/realtime_sync.rb`, and telemetry's joins), then cut setup, such as creating players in the database instead of through the join form where joining is not what the example checks. Two full runs in a row naming no file over 8 s is the proof.

## Comments
