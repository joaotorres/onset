# 05: SET! stays on top in every state

Status: ready-for-agent
Kind: behavioural
Blocked by:
Model:
Effort:

## Request

Player screen: keep SET! on top and the purple button below in every state, No Set countdown included

During the No Set countdown the phone puts "I agree, no Set" above SET!, swapping the usual order. SET! keeps its top slot in every state; the purple button always sits in the slot below.

## Spec references

- SPEC §8 "Phone controller": the fixed-slot paragraph (SET! keeps its slot in the No Set countdown, the pill slot under it) and item 5 (No Set countdown)

## Scope

- `app/views/players/_controller_status.html.erb`, the `game.no_set_active?` branch only: rebuild it on the idle layout. Purple status panel on top, then the round SET! in the idle slot (`set_round`, the `portrait:size-76` / `landscape:w-full landscape:flex-1` wrapper), then the pill slot
- The pill slot holds **I agree, no Set** as a pill in the `_secondary_action` pill shape, filled purple (`bg-purple-600`), or the waiting text ("You called No Set · waiting for n more" for the caller, "You agreed · waiting for n more" after agreeing) as an outlined purple pill, the way "Voted to end" is an outlined orange one. It may live in `players/controller/_secondary_action` as a No Set countdown branch; if so, update that component's line in `docs/design-system.md`
- Locked out during the countdown: SET! in the same round slot, disabled, as in the someone-else-claiming state, without the seconds
- Portrait and landscape both. Landscape keeps the 9rem action column: compact panel, SET! filling the column (`flex-1`), pill at the bottom
- Must not touch: the other controller states, the big screen announcement, `NoSetsController`, `ClaimsController`, `Game`

## Acceptance criteria

1. During a No Set countdown, a player who has not agreed sees the SET! button before the **I agree, no Set** button in document order, and the No Set status panel before both
2. SET! there is the round idle button: the same `set_round` classes as idle SET!, posting to `game_claims_path`
3. The caller sees SET! before "You called No Set · waiting for n more"; a player who agreed sees SET! before "You agreed · waiting for n more"
4. A locked-out player during the countdown sees a disabled SET! before the agree pill
5. "Spotted one after all?" no longer renders
6. Idle, locked out and someone-else-claiming render as before (their existing specs stay green)

## Verification

```
bundle exec rspec spec/requests/players_spec.rb spec/requests/no_sets_spec.rb spec/system
```

Tests first: in `spec/requests/players_spec.rb` under `GET /games/:code/controller`, a context for an active No Set countdown with three players (caller, one who agreed, one who has not), one locked. Parse the body with Nokogiri and compare document positions of the SET! form or button and the agree button or waiting text, one example per criterion 1 to 5. Then `bundle exec standardrb --fix`.

## Out of scope

- The n/m agreed count in landscape (stays hidden there)
- Changing the caller's waiting text to match the spec's "You agreed" wording
- A lockout countdown on SET! during the No Set countdown
- Any change to the claim or No Set rules, or to the big screen

## Comments

Decided: SET! in the countdown is the round idle button with its halo in the idle slot, because the spec's fixed-slot rule now covers this state and the round button already exists. Instead of: keeping the h-16 rectangle and only swapping it above the agree button.

Decided: the status panel stays above SET!, because the someone-else-claiming state already puts its status above SET! and the request only orders SET! and the purple button. Instead of: moving the panel below the pill.

Decided: I agree, no Set becomes a pill in the No Set pill shape, filled purple, because the request puts it in the slot below SET!, which holds a pill in every other state. Instead of: the h-20 full-width purple button.

Decided: dropped "Spotted one after all?", because SET! is back in its usual slot and needs no lead-in. Instead of: a caption between the panel and SET!.

Decided: a locked-out player sees a disabled round SET! with no seconds, as today's disabled rectangle shows none. Instead of: the 5-second lockout countdown inside SET!.

Decided: Kind stays behavioural, because the round SET!, the pill and the outlined waiting pill all exist in the design system. Instead of: visual and a design pass.
