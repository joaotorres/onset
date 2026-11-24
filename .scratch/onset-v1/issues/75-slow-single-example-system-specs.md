# 75: Bring the three slow single-example system specs under 8 s

Status: wontfix
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

Already met. The last two full `bin/test-all` runs at the current spec code (the runtime log written 2026-11-24 01:46 and the run before it, both after 4ef0768) timed the three files at `realtime_sync/claim_spec.rb` 7.5 s then 4.2 s, `realtime_sync/game_over_spec.rb` 7.9 s then 4.8 s, `telemetry_spec.rb` 7.5 s then 3.8 s: under 8 s in two full runs in a row, the request's own proof. The 10 to 28 s figures came from runs before the four splits rebalanced the processes. `telemetry_spec.rb` checks the `player_joined` events, so its joins through the form are what it asserts and could not be cut anyway.

Decided: wontfix as already met, because the request's proof holds and `bin/test-all`'s own rule is to split a file only when its warning names it run after run, which none of the three now is; if one flaps back over in two runs, the warning names it and it is filed then. Instead of: building setup cuts (players created in the database, the encrypted player cookie forged in the browser) for headroom nobody asked for.

Triage could not take a fresh measurement: every system spec now fails in Capybara's session reset, `Selenium::WebDriver::Error::InvalidArgumentError: * is not a valid URL` from `capybara-3.40.0/lib/capybara/selenium/driver_specializations/chrome_driver.rb:54` (`reset!` sends `Storage.clearDataForOrigin` with origin `*`), under Chrome 158.0.8127.88 with selenium-webdriver 4.52.0: 290 of 816 examples failed. A tooling fix outside this ticket, done directly with no trailer (loop-rules section 11, The way in). That failed run also replaced `tmp/parallel_runtime_rspec.log`, so the slow-file warning needs two good full runs after the fix before it compares real times again.
