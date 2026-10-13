# 20: Wrong claim lockout as long as the claim time

Status: ready-for-agent
Kind: behavioural
Blocked by: 19
Model:
Effort:

## Request

Blocked time after a wrong set should be the same as the time to pick a set

## Spec references

- §2 Game Rules, Round flow, rule 4 (Wrong Set, Time's up) and Edge cases, Wrong-claim lockout
- §4 Data Model, `Player`, `locked_until`
- §6 Round State Machine, Server-side timers
- §8 Views & UX, Big screen, Announcement, Wrong / Time's up
- §8 Views & UX, Player screen, 6. Locked out

## Scope

Touches:

- `app/models/claim.rb`: the two places that set `locked_until` and schedule `UnlockBroadcastJob` (wrong and expired) use `Game::CLAIM_TIMEOUT.seconds` instead of `5.seconds`.
- `app/views/players/_controller_status.html.erb`, locked-out state: the countdown's started-at value, duration value and the starting digits read `Game::CLAIM_TIMEOUT` instead of the literal 5.
- `app/views/games/_announcement.html.erb`: the two "locked out for 5 seconds" lines render `Game::CLAIM_TIMEOUT`.
- `app/views/lobbies/how_to_play.html.erb`: the "locked out for 5 seconds" sentence renders `Game::CLAIM_TIMEOUT`.
- Specs: `spec/models/claim_spec.rb`, `spec/requests/games_spec.rb` (player screen locked-out state), `spec/requests/players_spec.rb` where a test asserts the countdown values.

Must not touch: the claim window itself (`Game::CLAIM_TIMEOUT` stays 15), the No Set countdown, the lockout's look (ring, red tint, shake, "Locked" label, "Wrong! −1" and "Time's up! −1" copy), what the lockout blocks (SET! only), the score rule, `UnlockBroadcastJob` itself, the §15 implementation plan.

## Acceptance criteria

1. After a wrong claim is judged, the player's `locked_until` is `Game::CLAIM_TIMEOUT` seconds (15) after the resolution, and `UnlockBroadcastJob` is enqueued with that same wait.
2. After a time's up claim is judged, the same: `locked_until` 15 s ahead, `UnlockBroadcastJob` enqueued with a 15 s wait.
3. A locked-out player's own screen renders the SET! slot countdown with `data-countdown-duration-value` equal to `Game::CLAIM_TIMEOUT`, `data-countdown-started-at-value` equal to `locked_until` minus `Game::CLAIM_TIMEOUT` seconds, and the display digits starting at `Game::CLAIM_TIMEOUT`.
4. The big screen announcement for a wrong claim and for a time's up names the lockout length from `Game::CLAIM_TIMEOUT` ("locked out for 15 seconds"); no view or model carries a literal 5 for the lockout any more.
5. The How to play page says the lockout lasts `Game::CLAIM_TIMEOUT` seconds.
6. A player whose `locked_until` is still ahead cannot acquire a claim, as today; one whose `locked_until` has passed can.

## Verification

Write first: the model specs for criteria 1 and 2, the request specs for 3 to 5. Then:

```
bundle exec rspec
```

## Out of scope

- A separate lockout constant or setting. The lockout reads `Game::CLAIM_TIMEOUT` so the two lengths never drift.
- Changing the claim window, the No Set countdown or the flash durations.
- Any change to what the locked-out screen looks like or says beyond the number: that would be a visual change needing the design pass.
- Lockout for the No Set flow (ticket 21).
- Updating the §15 implementation plan: it is history.

## Comments

Decided: the lockout reads `Game::CLAIM_TIMEOUT` rather than a second constant set to 15, because the request ties the two lengths together and one constant keeps them so. Instead of: a `Game::LOCKOUT` constant that could later drift from the claim window.

Decided: Blocked by 19, because 19 rewrites the same claim resolution methods and its brief pins the lockout at 5 s until this ticket changes it. Instead of: leaving the order to ticket numbers alone.

Decided: Kind stays behavioural, because the locked-out ring, copy and announcement already exist and only the number changes. Instead of: a visual ticket waiting on a design pass.
