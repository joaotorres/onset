# 21: Refuse a No Set call once per board

Status: done
Kind: visual
Blocked by:
Model:
Effort:

## Request

Allow any player to refuse once to extend time once up until cards are added, if refused no one is allowed to call "no set" for 15s

## Spec references

- §2 Game Rules, Round flow, rule 5 (No Set on the board, Refusal) and Edge cases, Wrong-claim lockout
- §4 Data Model, `Game`: `no_set_refuser_id`, `no_set_refused_at` and Methods (`no_set_blocked?`, `can_refuse_no_set?`)
- §5 Routes, `POST /games/:code/no_set/refuse`
- §6 Round State Machine: the refused transition, Key invariants, Server-side timers
- §7 Realtime, Hooks that must survive any markup change (`countdown`)
- §8 Views & UX, Big screen, Announcement band, Refused
- §8 Views & UX, Player screen: the pill slot paragraph, 2. Idle, 5. No Set countdown, 6. Locked out
- §12 Background Jobs, `ExpireNoSetJob` and `UnblockNoSetJob`
- docs/design-system.md v4: `games/_announcement` Refused, `players/controller/_secondary_action` v4 variants (refusal pair, blocked No Set), `players/controller/_status_panel` refused, Screens > Player screen, during play > No Set countdown, may refuse and No Set blocked after a refusal; boards PlayPortraitRefusal, play-p8-refuse-locked, play-p8-blocked, play-p8-blocked-self, PlayLandscapeRefusal, play-l-blocked, PlayComputerRefusal, play-c-blocked, BigScreen (canvas in docs/design-handoff.md)

## Scope

Touches:

- One migration: `no_set_refuser_id` (bigint, nullable) and `no_set_refused_at` (datetime, nullable) on `games`.
- `Game`: `NO_SET_TIMEOUT = 15`; a `no_set_refuser` association; `no_set_blocked?` (refused less than `NO_SET_TIMEOUT` ago); `can_refuse_no_set?(player)`; `refuse_no_set!(player)` under `with_lock`, which cancels the call, sets both columns and enqueues `UnblockNoSetJob`; `call_no_set!` refuses while blocked and schedules `ExpireNoSetJob` with the constant; both columns cleared wherever the board changes (`start!`, `restart!`, `resolve_no_set!`) and a public way to rebroadcast the game state for the job.
- `Claim#resolve_correct!`: clears both columns with the board.
- `UnblockNoSetJob`: reloads the game and rebroadcasts its state (the big screen band and every player's `controller_status`), so screens leave the blocked state when the job fires.
- `config/routes.rb`: `post :refuse` inside `resource :no_set`.
- `NoSetsController#refuse`: `refuse_no_set!` then `head :no_content`, whatever the outcome.
- `games/_announcement`: the Refused panel, and the No Set ring's duration from the constant.
- `players/controller/_status_panel`: the `:refused` variant, and the No Set ring's duration from the constant.
- `players/controller/_secondary_action`: the refusal pair and the blocked No Set pill.
- `players/_controller_status`: idle and locked out render the refused panel and the blocked pill during the block; the No Set countdown state shows the lockout ring on SET! when locked out.
- Specs: `spec/models/game_spec.rb`, `spec/models/claim_spec.rb`, `spec/jobs/unblock_no_set_job_spec.rb` (new), `spec/jobs/expire_no_set_job_spec.rb`, `spec/requests/no_sets_spec.rb`, `spec/requests/games_spec.rb`, `spec/requests/players_spec.rb`, `spec/system/player_screen_portrait_spec.rb`, `spec/system/player_screen_landscape_spec.rb`, `spec/system/player_screen_computer_spec.rb`.

Must not touch: how a No Set call starts, is joined or resolves; the claim flow and `Game::CLAIM_TIMEOUT`; the lockout rule; the found-set banner; the scoreboards; the waiting and game over states; the big screen No Set and Claiming panels beyond the constant; the How to play page; `docs/design-system.md` (the build implements v4 and changes no rule); the canvas.

## Acceptance criteria

1. `Game::NO_SET_TIMEOUT` is 15. `call_no_set!` enqueues `ExpireNoSetJob` with that wait, and the No Set ring on the big screen and the No Set panel on the player screen read it as their `data-countdown-duration-value`; no literal 15 for the No Set countdown remains in the model or the views.
2. `refuse_no_set!(player)` during an active call, by a player who is active, not the caller and has not agreed, with `no_set_refused_at` nil: clears `no_set_caller_id`, `no_set_started_at` and `no_set_voters`, sets `no_set_refuser_id` to the player and `no_set_refused_at` to now, enqueues `UnblockNoSetJob` with `wait: Game::NO_SET_TIMEOUT.seconds`, leaves every score as it was and returns the game. A locked-out player may refuse.
3. `refuse_no_set!` returns nil and changes nothing when no call is active, when the player is the caller, when the player has agreed, or when `no_set_refused_at` is already set (a second call on the same board). `can_refuse_no_set?` answers the same cases.
4. `call_no_set!` returns nil and changes nothing while `no_set_blocked?`; once `no_set_refused_at` is `NO_SET_TIMEOUT` or more ago it works again, and that call cannot be refused.
5. `try_claim!` succeeds during the block: SET! stays open.
6. Both columns are nil again after a correct claim resolves, after a No Set call resolves, after `start!` and after `restart!`, and a refusal is accepted again on the new board.
7. `POST /games/:code/no_set/refuse` by a signed-in player answers 204 and performs 2; in the cases of 3 it answers 204 and changes nothing.
8. `UnblockNoSetJob#perform` broadcasts the `announcement` to `game:CODE` and `controller_status` to each `player:ID`.
9. Big screen, during the block with no claim active: one purple panel in `#announcement` with the ring (`stroke-purple-400`, digits `text-purple-300`) counting from `no_set_refused_at` over `NO_SET_TIMEOUT`, the headline "<name> says there's a Set" with the name in `text-purple-400` and truncated with an ellipsis (`truncate`), and "No Set is back when the ring runs out"; nothing on the right. While a claim runs during the block the Claiming panel shows instead. With `no_set_refused_at` older than `NO_SET_TIMEOUT`, the band shows "Spot a Set? Hit SET! on your screen."
10. Player screen, No Set countdown, a player who may refuse: the pill slot holds two buttons side by side, "There's a Set" on the left (a POST to the refuse path, `border-purple-400`, no fill, white bold text) and "I agree, no Set" on the right (`bg-purple-700`, white text), sized per v4 (portrait as wide as the status slot, landscape two pills in the 9rem column with labels on two lines, computer two 120px pills); the SET! slot is unchanged. The caller and a player who agreed see the waiting text as today, with no refusal. Once this board's refusal is used, the lone "I agree, no Set" shows as today.
11. Player screen, No Set countdown, locked out: the No Set panel keeps the status slot, SET! shows the lockout countdown (red ring, seconds, "Locked", `data-countdown-*` from `locked_until` as in Locked out) and the pill slot holds the refusal pair when the player may refuse.
12. Player screen, idle during the block: the status slot holds the refused panel (`bg-gray-900`, `border-purple-500`, no ring) with the refuser's dot, their name in bold and "says there's a Set", or their own dot and "You say there's a Set" on the refuser's screen; the pill slot holds a disabled No Set pill (`bg-purple-700`, `opacity-35`, `text-purple-200`) reading "No Set in N s", N a `countdown` display target from `no_set_refused_at` over `NO_SET_TIMEOUT`; SET! is the round blue button, enabled. Deck empty: the End game vote shows instead of the pill, the panel stays.
13. Player screen, locked out during the block: the refused panel in the status slot, the lockout countdown on SET!, the blocked pill.
14. After the block, with the refusal used: the player screen is plain idle with No Set enabled.
15. The three layout system specs keep no page scroll at 375×667, 667×375 and 1024×640 with 8 players and 18 cards in the states "No Set countdown" (the viewer may refuse, so the pair shows), "No Set countdown, locked out" and "No Set blocked".

## Verification

Write first: the model specs for criteria 1 to 6, the job spec for 8, the request specs for 7 and 9 to 14, the system spec states for 15. Then:

```
bundle exec rspec
```

## Out of scope

- Truncating the name in the big screen No Set and Claiming headlines: a request of its own (docs/design-system.md open question).
- A How to play line about refusing.
- Redrawing the Locked out boards' 5 s ring on the canvas.
- A penalty for refusing, more than one refusal per board, a refusal by the caller or a player who agreed, or extending the running countdown instead of cancelling it.
- Any change to `docs/design-system.md` or the canvas boards.
- `PATCH` or `DELETE /games/:code/no_set`.
- Updating the §15 implementation plan: it is history.

## Comments

Decided: visual, because a refuse action during the No Set countdown and a blocked No Set state are not in docs/design-system.md. Instead of: behavioural.

Design gap: SPEC §2 has no refusal of a No Set call. (1) Who refuses and when: any active player during the 15-second No Set countdown, including the caller and players who already agreed? (2) What a refusal does to the running call: cancels it at once, or extends its countdown ("extend time")? (3) "Once up until cards are added": one refusal per player, or one per room, until the next cards are dealt (a Set found or a No Set resolved)? (4) The 15-second block: does it stop everyone calling No Set, the refuser included, and does SET! stay open during it? (5) Is there a penalty for refusing, as for a wrong SET!? (6) What the big screen and every player screen show for a refusal and during the block (who refused, a countdown, the No Set pill disabled)?

Decided: a refusal cancels the No Set call at once and blocks No Set for everyone, the refuser included, for 15 s (`Game::NO_SET_TIMEOUT`, the countdown's own length) while SET! stays open, because the request's "extend time" is time to find the Set the refuser says is there. Instead of: extending the running countdown by 15 s and keeping the call.

Decided: any active player who is not the caller and has not agreed may refuse, locked-out players included, because agreeing and refusing are opposite answers to the same call and the lockout only blocks SET!. Instead of: letting the caller or a player who agreed refuse.

Decided: one refusal per board: the next No Set call on the same board cannot be refused, and the refusal comes back when the board changes (a Set removed or cards dealt), because the request says once until cards are added and a found Set changes the board as much as a deal does. Instead of: resetting only on a No Set deal, or once per player.

Decided: no penalty for refusing, because the request names none and once per board already stops stalling. Instead of: -1 as for a wrong claim.

Decided: the refusal is two nullable columns on Game, `no_set_refuser_id` and `no_set_refused_at`, cleared when the board changes, because the block and the once-per-board rule need server state nothing holds and one timestamp carries both, as `no_set_started_at` does for the countdown. Instead of: a blocked-until column plus a boolean, or no refuser name on the screens.

Decided: the refusal is `POST /games/:code/no_set/refuse`, because the no_set resource already groups the call's actions and its unused PATCH would not say what it does. Instead of: PATCH /games/:code/no_set.

Decided: the pill reads "There's a Set" beside I agree, no Set; the big screen band shows a purple Refused panel with the block's ring, "Alex says there's a Set" and "No Set is back when the ring runs out"; player screens return to idle with No Set disabled and counting down ("No Set in 12 s") and "Alex says there's a Set" in the status slot, because every player should see why No Set is off and for how long; how the two pills share the slot is the design pass's. Instead of: a silently disabled pill.

Decided: the brief leaves every play board as it is and adds the refusal states beside the No Set and idle boards, plus a first big screen board, because tickets 19 (claim picks, no dimming) and 22 (computer footer under the deck line) changed only parts the refusal does not touch. Instead of: redrawing the play boards from the code, which are marked exploring.

Design proposes: the refuser's own screen reads "You say there's a Set" in the status slot, with their own dot, as "You agreed" and "You called No Set" do. SPEC §8 Player screen > 2. Idle names only "Alex says there's a Set".

Design question: a 20-character name at 1280px wide pushes the big screen's Refused headline to three lines and out of the 9rem band, as it would the No Set and claiming headlines. The design tool recommends truncating the name with an ellipsis so the headline stays within two lines.

Design question: the canvas's Locked out boards still draw the 5-second ring, though lockout is 15 s since ticket 20. The design tool recommends redrawing them in the next brief that touches lockout; no code change.

Decided: design-system v4 takes the lockout ring on SET! during a No Set countdown (seconds and "Locked", as in Locked out) where the code shows a plain disabled SET!, because the brief asked for SET! "disabled as the lockout countdown" there. Instead of: keeping the plain disabled SET!.

Decided: design-system v4 adds variants and changes no existing rule: the refusal pair and blocked No Set in `_secondary_action`, the refused `_status_panel`, the Refused `_announcement` panel; in portrait the pill slot widens to the status slot's width while the pair shows. Instead of: stacking the two pills, which would move SET!.

Decided: the design proposal is accepted: the refuser's own screen reads "You say there's a Set" with their own dot, written into SPEC §8 Player screen > 2. Idle, because "You agreed" and "You called No Set" already address the player that way. Instead of: "Alex says there's a Set" on every screen.

Decided: the Refused headline on the big screen truncates the name with an ellipsis so it stays within two lines at 1280px, written into SPEC §8 Big screen, and the No Set and Claiming headlines stay as they are, because the request covers the refusal alone and fixing the other two adds scope; docs/design-system.md keeps the open question for them. Instead of: truncating all three headlines in this ticket, or letting a long name push the Refused headline out of the band.

Decided: the Locked out boards' 5 s ring stays an open question in docs/design-system.md and changes nothing here, because the code already counts 15 s and this ticket does not touch the lockout. Instead of: a canvas redraw in this ticket.

Decided: the v4 entry is accepted as 21's design, and SPEC §8 Player screen > 5 now says a locked-out player sees the lockout countdown on SET! (ring, seconds, Locked) under the No Set panel, because v4 drew it so and a plain disabled SET! said nothing about when it comes back. Instead of: keeping "SET! shows disabled".

Decided: locked out during the block, the status slot shows the refused panel and SET! the lockout ring, written into SPEC §8 Player screen > 6, because v4 gives the room's event the slot when a lockout overlaps a No Set call and the ring already says Locked. Instead of: the red Wrong or Time's up panel.

Decided: the build introduces `Game::NO_SET_TIMEOUT = 15` and replaces the literal 15 s for the No Set countdown in the model, the big screen ring and the player screen panel, because SPEC §2, §6 and §12 name the constant and the block must equal the countdown. Instead of: a literal 15 for the block as well.

Decided: one ticket, no split, because the refusal is one vertical slice (two columns, one action, one job, one panel per screen) in partials that already carry each layout's variants, smaller than ticket 14. Instead of: splitting by screen or layout.

Decided: on the refuser's own screen the refused panel bolds "You" where others see the bold name, then "say there's a Set", because it keeps the panel's layout identical for everyone. Instead of: one unbolded line.
