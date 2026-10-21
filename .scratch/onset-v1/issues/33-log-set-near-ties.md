# 33: Log SET! near-ties

Status: deployed
Kind: behavioural
Blocked by:
Model:
Effort:
Changelog: Behind the scenes: the server logs how late a SET! call arrived when it loses the race to another player's claim.

## Request

Log SET! near-ties: when a SET! call loses the race because another claim is already running, log how many ms after that claim started the losing call arrived (not for players locked out or calls rejected for other reasons). Add a note under §14 Future Work to evaluate those logs once enough games have been played, and from them decide whether to claim on pointerdown instead of click, send claims over the WebSocket or add lag compensation (tap timestamps plus a short collection window), with the trade-offs of each.

Settled in conversation: the server already judges claims in arrival order (`Game#try_claim!` under `with_lock`). The unfairness, if any, comes before the server: network differences between phones, `click` firing on finger release, an occasional cold connection. The log measures arrival gaps, not tap gaps, which is the right signal for "could the order have flipped". No change to who wins a claim in this ticket.

Trade-offs to record in the §14 note:

- **Claim on pointerdown**: removes the release delay that varies per player, but fires on a scroll start or a brush (stray claims cost −1), loses slide-off-to-cancel, risks a card being picked twice when the click lands on the redrawn screen (§8 "only the first tap counts"), and needs `click` kept for the keyboard. If done, SET! button only.
- **Claims over the WebSocket**: skips a possible handshake and HTTP overhead, but the gain is unmeasured, mobile browsers drop the socket on suspended tabs so HTTP stays as a fallback (two claim paths), and it needs the custom channel §9 says to avoid.
- **Lag compensation**: the only option that cancels network differences, but every claim starts about 150 ms later, it trusts device-reported tap times (needs clock sync for correctness and a clamp against faked early stamps), still misses device input speed and is harder to test.
- Also worth weighing then: players see a new board at different moments, a head start none of these fix; and "first to reach the server" is a defensible rule for a casual party game.

## Spec references

- §6 Round State Machine, Key invariants, "Lost races are logged"
- §5 Routes, `POST /games/:code/claims`
- §14 Future Work, Claim fairness

## Scope

Touches:

- `Game#try_claim!`: takes the call's arrival time (`arrived_at:`, defaulting to `Time.current` on entry). When the game is playing, the player is not locked out and a claim is already active, it logs one `info` line through `Rails.logger`, `near_tie game=<code> winner=<claim_player_id> loser=<player id> late_ms=<n>`, with `late_ms = ((arrived_at - claim_started_at) * 1000).round`, which may be negative. It still returns nil and changes nothing. A call refused for any other reason (not playing, locked out, with or without a running claim) logs nothing. The check order inside the lock may change to tell the reasons apart; the outcome of every call stays the same.
- `ClaimsController#create`: stamps the arrival as its first `before_action`, before the game and player lookups, and passes it to `try_claim!`.
- `spec/models/game_spec.rb` and `spec/requests/claims_spec.rb`: the examples below. The seam is `Rails.logger`: `allow(Rails.logger).to receive(:info)` and assert on the lines it received.

Must not touch: who wins a claim or when it is judged, `Claim` and its columns, the jobs, the views, the Stimulus controllers, the design system, any copy.

## Acceptance criteria

1. On a playing game with Alice's claim running (`claim_started_at` set), `try_claim!(bob, arrived_at: game.claim_started_at + 0.183)` returns nil and `Rails.logger` receives one `info` line matching `near_tie game=<game.code> winner=<alice.id> loser=<bob.id> late_ms=183`.
2. The same with `arrived_at: game.claim_started_at - 0.02` logs `late_ms=-20`.
3. No `near_tie` line when: the call wins (no claim running); Bob is locked out while Alice's claim runs; the game is not playing; Bob is locked out and no claim runs.
4. `POST /games/:code/claims` while another player's claim runs answers 204, creates no `Claim` and logs one `near_tie` line whose `late_ms` is an integer; the same POST from a locked-out player logs none.
5. Every existing `try_claim!` and claims request example holds unchanged.
6. The rest of the suite stays green.

## Verification

Write first: examples 1 to 4, and see 1, 2 and 4 fail on the current code (no line is logged). Then:

```
bundle exec rspec
```

## Out of scope

- Any change to who wins the race, the lock, the claim window or the lockout.
- A threshold: every lost race is logged, "near" is judged when the logs are read.
- Storing the gap on `Claim` or anywhere in the database (no migration).
- A PostHog event (§17 keeps server actions out of PostHog) or a Sentry message.
- Logging the winner's own call, a player's name, or any other refusal.
- Claim on pointerdown, claims over the WebSocket, lag compensation: §14 Claim fairness records them for after the logs are read.

## Comments

Decided: arrival is stamped when the request reaches the controller, before the lookups and the lock, and the gap is measured against the game's `claim_started_at`, because a wait for the winner's transaction would otherwise be added to every gap, and a negative value then says the lock order decided. Instead of: stamping inside the lock.

Decided: every lost race is logged with no threshold, because "near" is decided when the lines are read and a call that arrives seconds late (a stale screen) is worth seeing too. Instead of: logging only gaps under a cutoff.

Decided: a Rails log line carrying ids, not a PostHog event or a column on `Claim`, because §17 keeps server actions out of PostHog and a column would be a schema change for a question answered once. Instead of: a `claim_lost` event or `Claim#late_ms`.

Decided: no glossary entry, because a lost race is a server mechanism, not a term players or the game language use. Instead of: adding "Near-tie" to GLOSSARY.md.
