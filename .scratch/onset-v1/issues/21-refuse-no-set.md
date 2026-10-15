# 21: Refuse a No Set call once per board

Status: needs-triage
Kind: visual
Blocked by:
Model:
Effort:

## Request

Allow any player to refuse once to extend time once up until cards are added, if refused no one is allowed to call "no set" for 15s

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
