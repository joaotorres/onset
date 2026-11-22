# Future direction

This document exists to constrain what is built now, not to describe a roadmap.
Each item says what we intend to build later and what the app must or must not
do until then. Do not build anything in this file. Do not add abstractions,
interfaces or config in anticipation of it beyond what each "So until then" line
states.

Items are marked **certain** (a decision about direction) or **parked** (may
never happen, do not design for it).

Source: `SPEC.md` §1 Non-goals and §14 Future Work. §14 holds the detail; this
file says what each item constrains now.

---

## Accounts (certain, v1.5)

Optional persistent identity behind the in-game `Player`: Rails 8's built-in
authentication with magic links, a "Claim profile" flow, and stats views over
the `Claim` table (§14 Accounts).

So until then:
- Guests only. `Player.user_id` stays nullable and unused; it is designed in now
- No Devise or any other auth gem
- `Player` stays the in-game identity, so the game logic does not change when
  `User` arrives

## AI opponent (certain, v2)

Taken by ticket 47 and specified in SPEC AI opponent: bots the host adds to a
waiting room, at Easy, Medium or Hard, each a delay range before it claims a
random Set.

## Claim fairness (parked)

Once enough games have been played, read the `near_tie` lines and decide whether
the claim race needs changing. §14 Claim fairness lists the options and their
trade-offs: claim on pointerdown, claims over the WebSocket, lag compensation.

So until then:
- The rule stays "first to reach the server"
- Keep logging lost races as `near_tie` lines (§6 Lost races are logged)
- No custom Action Cable channel (§9)

## Per-address ceiling on in-game actions (parked)

Ticket 60 limits each player's in-game actions on their own (SPEC §5 Rate
limits), and one address may join 20 times a minute, each join with a full
allowance. A script that keeps joining can therefore multiply the limits.
Decided 2026-11-22 (review 20261120-094918): leave it, not a concern now.
Revisit if load from one address becomes a problem. The fix then: a loose
per-address ceiling of about 2,500 in-game actions a minute, above a full table
of 8 at the per-player limits (2,160), since a table shares one Wi-Fi address.

So until then:
- In-game limits stay per player, by `player_token`, never by IP

## Solo/practice mode (parked)

Same UI, no claim phase, infinite deck shuffle. A v1 non-goal.

So until then:
- Nothing

## Replays (parked)

A scrubber UI over the `Claim` records, which already form the game's timeline.

So until then:
- Nothing

## Spectator mode (parked)

A join URL with `?spectate=1` that skips the name form.

So until then:
- Nothing

## Out of scope

Cross-room matchmaking and native apps (§1 Non-goals). No section above covers
them and nothing is planned for them.
