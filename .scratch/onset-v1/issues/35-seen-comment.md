# 35: Player#seen! comment gives the spec's reason

Status: ready-for-agent
Kind: behavioural
Blocked by:
Model:
Effort:
Changelog:

## Request

Behind the scenes: the comment on Player#seen! gives SPEC §7's reason for skipping callbacks (a heartbeat broadcast shows nothing new) instead of the stale-message reason the spec retired

From review 20261022-163847, pending decision 2. The comment is at `app/models/player.rb:17-18` and still says the method skips callbacks "so it doesn't broadcast a stale controller_status that can land after the real update". Ticket 34 reworded the SPEC §7 bookkeeping paragraph: the version check now guards against stale broadcasts, and the heartbeat skips its broadcast because it would show nothing new. Comment only: the method and its behaviour stay as they are.

## Spec references

No spec change. §7 Realtime, "Actions answer 204, broadcasts update the screen", last paragraph, already states the reason the comment must give: a broadcast per heartbeat is traffic with nothing new to show, and the guard against a stale message is the version check under "Screens ignore broadcasts older than what they show", not the bookkeeping.

## Scope

Touches: the comment above `Player#seen!` in the `Player` model, and nothing else.

Must not touch: the method body (`update_column(:last_seen_at, Time.current)`), its callers, any other comment, any spec, `SPEC.md`, the glossary.

## Acceptance criteria

1. The comment above `Player#seen!` says the method skips callbacks because a heartbeat broadcast would show nothing new, in one or two lines, and points at SPEC §7 for the reason.
2. The comment no longer mentions a stale `controller_status`, or a message landing after the real update: that guard is the version check, not this method.
3. `Player#seen!` still writes `last_seen_at` without running callbacks and without broadcasting (the existing `#seen!` examples in the model spec pass unchanged).
4. Nothing else in the diff: one file, comment lines only.

## Verification

No test to write first: a comment has no behaviour. The build makes the edit, then runs

```
! grep -n "stale controller_status" app/models/player.rb && bundle exec rspec spec/models/player_spec.rb
```

which proves the retired reason is gone and the method's behaviour is unchanged.

## Out of scope

- Rewording the "Resolved issue" paragraph under Step 9 in SPEC.md's build log: it records what was found at the time and stays as history.
- Any change to `Player#seen!`, `active?`, the 30-second window or the controllers that call `seen!`.
- Running `standardrb` over anything but the one file touched.
- The `last_seen_at` row in §7's data model table, which already says the method skips callbacks so it never broadcasts.

## Comments

Decided: no spec change, because §7 "Actions answer 204, broadcasts update the screen" already gives the reason the comment must carry after ticket 34, so the ticket only brings the code's comment in line with it. Instead of: adding a sentence to the spec about the comment itself.

Decided: the Step 9 "Resolved issue" paragraph in the spec's build log keeps its stale-message wording, because it records what was diagnosed at the time, not the current rationale, and §7 is the paragraph that states the rule. Instead of: rewording history to match §7.

Decided: no test is written first and Verification is a grep for the retired wording plus the model spec, because a comment has no behaviour a test can observe and the model spec proves `seen!` still skips callbacks. Instead of: a spec that reads the source file, or skipping Verification.
