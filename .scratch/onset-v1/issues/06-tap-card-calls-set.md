# 06: Tapping a card calls SET!

Status: ready-for-agent
Kind: behavioural
Blocked by:
Model:
Effort:

## Request

Player screen: tapping a visible card while idle calls SET! and selects that card

Applies where the player screen shows cards while idle (landscape, a computer). The tap takes the claim and selects that card as the first of three. If someone else holds the claim, the tap does nothing. Portrait shows no cards while idle, so it is unchanged. Accepted risk: an accidental tap starts a 15s claim and can cost −1, the same as an accidental SET! tap.

## Spec references

- SPEC §2 "Round flow" item 3: a card tap in landscape is a way to call SET!
- SPEC §8 "Phone controller": the landscape sentence (board read-only except idle and claiming (mine)), item 2 Idle (tap calls SET! with that card selected, first tap only, lost race does nothing, never carries into a later claim), item 3 Claiming (mine) (opens with the tapped card selected, 1/3)
- SPEC §7 "Hooks that must survive any markup change": the idle landscape board line

## Scope

- The idle branch of the player screen status partial (`players/_controller_status`) and the landscape board strip it renders (`players/controller/_board_strip`). Only the idle state's strip becomes tappable; the strip in locked out, someone else claiming and the No Set countdown stays read-only
- A tap posts the same `POST /games/:code/claims` as SET! (204, the broadcast updates the screen, §7) and remembers the tapped card id client side, so the claiming (mine) view can start with it selected. No new param, column or server state: `Game#try_claim!` and `ClaimsController` stay as they are
- The `card-selection` Stimulus controller: on connect, if a tap is pending and that card id is on the board, select it exactly as a tap would (ring, `aria-pressed`, tray slot, n/3 count = 1), then clear the pending tap. Keep every target, action and data attribute §7 lists
- A pending tap must not survive into a later claim: clear it when the claiming (mine) view consumes it and whenever the idle view connects again (a lost race passes through someone else claiming and back to idle)
- After the first tap, further taps on the idle board are ignored until the screen re-renders, the way SET! uses `turbo_submits_with`
- Tappable cards get `cursor-pointer` and are buttons (keyboard and screen reader reachable); no new hover or pressed style
- If the implementation adds a Stimulus controller, list its identifier, targets and actions on the §7 idle landscape board line
- Must not touch: portrait idle (shows no cards), the big screen, `Game`, `Claim`, `ClaimsController`, the auto-submit timing (§11), the No Set countdown branch (ticket 05 rebuilds it)

## Acceptance criteria

1. Idle, the landscape board renders each card as a button carrying `data-card-id`, inside or wired to a form that posts to `game_claims_path`
2. Locked out, someone else claiming and the No Set countdown render the board strip with no card buttons and no claim form around the cards
3. In a landscape browser, tapping a card while idle creates a pending claim for that player, and the claiming (mine) view opens with that card selected: it has the selection ring, `aria-pressed="true"` and the count reads 1/3
4. Tapping two more cards after that submits the three cards and scores the claim as usual (correct: +1; wrong: −1 and lockout)
5. Tapping the pre-selected card again deselects it (count 0/3)
6. When another player already holds the claim, a card tap creates no claim and the screen shows the someone else claiming state
7. A tap that did not win the claim does not pre-select any card in that player's next claim started with SET!
8. Idle portrait renders exactly as before (existing specs stay green)

## Verification

```
bundle exec rspec spec/requests/players_spec.rb spec/requests/claims_spec.rb spec/system
```

Tests first: in `spec/requests/players_spec.rb` under `GET /games/:code/controller`, examples for criteria 1 and 2 (Nokogiri on the body: buttons with `data-card-id` in the idle board strip, none in the other three states). A new system spec (`spec/system/tap_card_claim_spec.rb`, headless Chrome as in `stimulus_polish_spec.rb`, window resized to a landscape size such as 1280x720) for criteria 3 to 7; criterion 6 sets the other player's claim in the database before the tap, criterion 7 makes a tap lose the race, releases that claim and then claims with SET!. Then `bundle exec standardrb --fix`.

## Out of scope

- Tapping a card during the No Set countdown (SET! cancels the call there, but the request only covers idle)
- Showing the board in portrait idle, or a computer layout (ticket 09)
- Keyboard shortcuts (deferred in ticket 09)
- Changing the big screen's "Spot a Set? Hit SET! on your phone." line
- Sending the tapped card to the server or storing it on the claim
- A confirm step or undo for an accidental tap

## Comments

Decided: the tapped card travels client side (remembered at tap, consumed by `card-selection` on connect), because §7 has every action answer 204 with the broadcast drawing the claim view, and storing it on `Claim#card_ids` would make an expired claim look like a submission. Instead of: a `card_id` param stored on the pending claim.

Decided: only idle's board is tappable, not the No Set countdown's, because the request says idle. Instead of: also letting a card tap cancel a No Set call.

Decided: first tap wins until the screen changes, and a lost or stale tap never pre-selects a card later, because a second tap or an old pending id would select a card the player did not just choose. Instead of: the last tap wins.

Decided: a tapped card no longer on the board is dropped and the claim opens at 0/3, because the cards can change between tap and claim only through a deal. Instead of: failing the claim.

Decided: no new hover or pressed style, only `cursor-pointer` and buttons, so the ticket stays behavioural with the design system's existing card. Instead of: a hover lift that would need a design pass.

Decided: the big screen's "Hit SET! on your phone" line stays, because the phone SET! still works and ticket 12 owns player-facing wording for devices-first. Instead of: rewording it here.
