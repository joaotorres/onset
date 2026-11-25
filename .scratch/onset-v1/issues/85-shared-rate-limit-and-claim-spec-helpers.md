# 85: Behind the scenes: one home for the rate limit stub and the stale claim helpers

Status: deployed
Kind: behavioural
Blocked by:
Priority: low
Feature: Themes
Model:
Effort:
Changelog: Behind the scenes: the rate limit and stale claim spec helpers each live in one place.

## Request

Split from 81 (one home for the repeated spec helpers): the rate limit and claim parts. Rate limits: the `cache_store` stub is copied in `spec/requests/{in_game_rate_limits,players/create,games/create}_spec.rb`. Claims: `state`, `restart_with_known_board` and their contexts are the same in `spec/models/claim_spec.rb`, `spec/jobs/expire_claim_job_spec.rb` and `spec/requests/claims_spec.rb`. No example's assertions change. The theme helpers are 84, the player helper 86.

## Spec references

No spec change: specs and spec support only, nothing a user would notice. The helpers check what these already decide:

- SPEC.md, Shared: 5. Routes (the rate limits and their 429)
- SPEC.md, Shared: 6. Round State Machine > Key invariants (a claim is acted on only while it is the room's current claim)
- CLAUDE.md, Testing

## Scope

Spec support, request, model and job specs only.

1. **Rate limits.** One shared context in `spec/support/` gives a `store` (an `ActiveSupport::Cache::MemoryStore`) and makes the controllers' rate limit counting go to it, since the test environment's cache store is `:null_store`. Every spec that stubs a controller's `cache_store` uses it instead: the in-game limits, players create and games create specs today, and any other copy under `spec/` at build time (tickets 62 and 79 add limit specs with the same seam)
2. **Stale claims.** One shared context in `spec/support/` for "a claim that is not the room's current one" holds `state` (the claim's attributes, the player's score and lockout, the game's status, board, deck, discard and current claim player), `restart_with_known_board` (end, restart, board 0..11 and deck 12..80) and the three situations, each running the shared examples the including spec names: in an ended room, left from an earlier game, and superseded by its player's newer claim (with `newer`). The claim model spec and the expire claim job spec use it with their own shared examples ("an ignored claim", "an ignored expiry") and keep their own extra examples (still judges the newer claim, still expires the newer claim)
3. **The claims request spec's leftover** is built with the shared `restart_with_known_board`. It keeps its own `state`, which leaves out the game's current claim player: the shared one would widen what its examples assert

Must not touch: anything under `app/` or `config/`; what any example asserts; the theme helpers (84); player colors (86).

## Acceptance criteria

- `cache_store` appears once under `spec/`, in the shared rate limit context, and every limit example still passes against a real count (a 429 after the limit)
- `restart_with_known_board` is defined once under `spec/`, and the "ended room", "left from an earlier game" and "superseded" setups exist once, in the shared stale claim context
- `def state` that reads the claim, player and game is defined once in support, plus the claims request spec's narrower one
- The suite runs as many examples as before the change, and they pass
- No file outside `spec/` changes, and no spec file runs over 8 s

## Verification

`bin/test-all && bundle exec standardrb`

Tests first: a refactor with no new example. Run `bin/test-all` before any change and note the example count. Move the stub and run `bundle exec rspec spec/requests`; break the shared context's stub on purpose once (count in the null store) to see the limit examples go red, then restore it. Move the claim helpers and run `bundle exec rspec spec/models/claim_spec.rb spec/jobs/expire_claim_job_spec.rb spec/requests/claims_spec.rb`. Finish with the Verification command and the same example count.

## Out of scope

- A new limit example, or changing a limit's number or window
- Sharing the claim spec's other helpers (`find_set_on_board`, `valid_set_ids`) beyond where they already live
- The theme helpers (84) and the player helper (86)

## Comments

Decided: the claims request spec keeps its own `state` and takes only `restart_with_known_board`, because the shared `state` adds the game's current claim player and the request is that no example's assertions change. Instead of: the shared `state`, a stronger check.

Decided: the stale claim context runs a shared examples group the including spec names, because the model and the job check different actions (submit and pick, expiry) against the same three situations. Instead of: one shared examples group for both.

Decided: the rate limit context covers every copy of the stub at build time, tickets 62's and 79's included, because both are filed to reuse the same seam and the fix covers the whole flaw. Instead of: only the three files the request names.

Decided: the rate limit context stubs `ActionController::Base.cache_store`, the one store object every controller shares (breaking it turned all 25 limit examples red, players create included), and the superseded situation also runs "<examples> when superseded" for each spec's extra example, because that keeps one stub and one setup per situation. Instead of: a stub per controller, or the extra examples in a second superseded context.
