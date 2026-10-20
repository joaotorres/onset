# 32: Countdown rings follow the server's clock

Status: needs-triage
Kind: behavioural
Blocked by:
Model:
Effort:
Changelog:

## Request

Countdown rings follow the server's clock: each screen corrects its countdowns for how far its device clock is off from the server's, so the rings on every screen show the same time left. Display only: the server still judges every deadline (§6 Server-side timers).

Settled in conversation: `countdown_controller.js` compares `Date.now()` with the server's `started_at`, so a device clock that is off by n seconds shows every ring off by n seconds. The fix is an offset measured against the server's time (for example the server's current time rendered beside `started-at`, or an NTP-style ping: `offset = server_time - (sent + received) / 2`), worked out once and applied as `Date.now() + offset`. Expect tens of ms of residual error from asymmetric network paths; that is fine, the rings are display only.

Origin: a look at timing fairness. The claim race and deadlines stay judged on the server; this only aligns what screens show.

## Comments
