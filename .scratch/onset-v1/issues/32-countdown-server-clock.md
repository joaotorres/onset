# 32: Countdown rings follow the server's clock

Status: ready-for-agent
Kind: behavioural
Blocked by:
Model:
Effort:
Changelog:

## Request

Countdown rings follow the server's clock: each screen corrects its countdowns for how far its device clock is off from the server's, so the rings on every screen show the same time left. Display only: the server still judges every deadline (§6 Server-side timers).

Settled in conversation: `countdown_controller.js` compares `Date.now()` with the server's `started_at`, so a device clock that is off by n seconds shows every ring off by n seconds. The fix is an offset measured against the server's time (for example the server's current time rendered beside `started-at`, or an NTP-style ping: `offset = server_time - (sent + received) / 2`), worked out once and applied as `Date.now() + offset`. Expect tens of ms of residual error from asymmetric network paths; that is fine, the rings are display only.

Origin: a look at timing fairness. The claim race and deadlines stay judged on the server; this only aligns what screens show.

## Spec references

- §6 Round State Machine, Server-side timers, "Countdowns follow the server's clock"
- §5 Routes, `GET /clock`
- §7 Hooks that must survive any markup change, `countdown`

## Scope

Touches:

- `config/routes.rb` and a new `ClocksController#show`: `GET /clock` answers JSON `{"now": <ms since the epoch>}` from `Time.current`, with `Cache-Control: no-store` so no proxy or browser cache serves a stale time. No view, no session, no CSRF concern (a GET).
- `app/javascript/controllers/countdown_controller.js`: elapsed time becomes `(Date.now() + offset - startedAt) / 1000`. The offset lives in module state outside the controller instance (one per page load, kept across the Turbo Stream redraws that replace rings). It is measured once per page load, NTP-style: fetch `/clock` three times in sequence, for each sample `sent` and `received` from `Date.now()`, keep the sample with the shortest round trip, `offset = now - (sent + received) / 2`. The measurement starts when the module loads, not when a ring connects, so the first ring usually finds it ready; until it lands the offset is 0 and the rings correct on their own once it does. A failed fetch leaves the offset at 0. Expose the measurement as a small clock module (for example `app/javascript/server_clock.js` pinned in the importmap, or an export of the controller module) with a `sync()` that returns a promise resolving to the offset, so the system spec can skew the clock and ask for a fresh measurement.
- `spec/requests/clocks_spec.rb` and `spec/system/countdown_clock_spec.rb`: the examples below.

Must not touch: what the server judges or when (`Game`, the expire jobs, `Claim`), the ring markup and its hooks (`r="45"`, `stroke-dasharray="282.74"`, the `started-at` and `duration` values, the `ring` and `display` targets), the views, the design system, any copy.

## Acceptance criteria

1. `GET /clock` answers 200 with JSON whose `now` is within 1 s of the server's `Time.current` in ms, and a `Cache-Control` header that forbids caching (`no-store`).
2. On a page with an active claim, after the page loads skew the device clock with `execute_script` so `Date.now()` reads 60 s ahead of the real time, then call the clock module's `sync()` and wait for it. The claim's seconds display then reads a number between 1 and `Game::CLAIM_TIMEOUT` (the true time left), not 0.
3. The same with `Date.now()` reading 60 s behind: the display reads at most `Game::CLAIM_TIMEOUT`, not a number above it.
4. The offset survives a redraw: after example 2, redraw `#controller_status` (for example `game.update!(flash_claim_id: nil)`) and the redrawn ring's display still reads the true time left, not 0.
5. With the device clock untouched, every existing countdown example holds (the ring and display targets, the seconds counting down from `Game::CLAIM_TIMEOUT`).
6. The rest of the suite stays green.

## Verification

Write first: examples 1 to 4, and see 2 to 4 fail on the current controller (example 1 fails on the missing route). Then:

```
bundle exec rspec
```

## Out of scope

- Re-measuring the offset on a schedule, on each stream redraw or when the tab wakes: once per page load, plus whatever a test asks for through `sync()`.
- Rendering the server's time in the page markup as a second source of offset.
- Any change to the claim race, the deadlines, lag compensation or claim timestamps (ticket 33 covers logging near-ties).
- A `jtTrack` event: nothing user-initiated happens here.
- Sending the offset to the server, or storing it anywhere beyond the page's memory.

## Comments

Decided: the offset is measured NTP-style against a new `GET /clock` endpoint, three round trips once per page load keeping the shortest, because it is the only method that reaches the tens-of-ms residual the request expects and it needs no change to the ring markup. Instead of: rendering the server's time beside `started-at`, which would carry the one-way delivery delay plus render-to-script time as a one-directional bias of roughly 100 to 300 ms on every redraw.

Decided: until the first sample lands the rings use the device clock as is and then correct, because a ring that waits for the measurement would flash empty or stuck for a round trip, and a device whose clock is already right would see nothing either way. Instead of: holding the ring until the offset is known.

Decided: no glossary entry, because the clock offset is a mechanism, not a term players or the game language use. Instead of: adding "Clock offset" to GLOSSARY.md.
