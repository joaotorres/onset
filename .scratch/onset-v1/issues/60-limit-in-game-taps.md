# 60: Limit how often one player may send in-game actions

Status: done
Kind: behavioural
Blocked by:
Priority: normal
Feature: Rate limits
Model:
Security: yes
Effort:
Changelog: A player sending game actions far faster than anyone can tap is now refused for the rest of the minute, without slowing the table.

## Request

Limit how often one player may send in-game actions (I'm ready, SET!, card picks, Submit, No Set, End game) with a rate_limit on the gameplay POSTs, set so a player picking cards fast is never refused mid-claim.

Deferred from 54: the security review (.scratch/onset-v1/reviews/security-20261115.md, F1) suggested it, and the owner chose on 2026-11-19 to file it as a ticket of its own rather than fold it into 54. With 54's 8-player cap each tap's cost is already bounded, so this only guards against one player hammering the server. Touches security.

## Spec references

- Shared: 5. Routes, Rate limits (new)
- 11. Selection submission UX (decision) (picks are sent one at a time, which sizes the claims limit)
- Shared: 7. Realtime, Actions answer 204, broadcasts update the screen (the `429` is the one new answer)

## Scope

- Rails' `rate_limit` on the in-game controllers, with the numbers, keys and grouping SPEC §5 Rate limits gives:
  - `ClaimsController`, `create`, `update` and `submit`, one count: 180 a minute per player
  - `GamesController#ready`: 30 a minute per player
  - `NoSetsController`, `create`, `destroy` and `refuse`, one count: 30 a minute per player
  - `EndGamesController#create`: 30 a minute per player
  - `GamesController#start` and `#restart`, one count: 30 a minute per host, keyed by the `host_game` cookie's value, by IP without it. Two `rate_limit` calls in `GamesController` beside the existing `create` limit need distinct `name:`s
- Per player means keyed by the encrypted `player_token` cookie, falling back to `request.remote_ip` when the request has none. Never by IP for a request that carries the cookie
- Over the limit: `head :too_many_requests`, nothing else. No flash, no page, no body, no broadcast, no model call
- The default store (the app's cache store), as the room-creation and join limits use
- `ClaimsController`'s `stamp_arrival` stays the first before-action, ahead of the claims limit, so the near-tie `late_ms` (§6) does not take in the limit's cache write
- Request specs for each limit, using the same seam as the join and room-creation limit specs (a `MemoryStore` standing in for the controller's `cache_store` increments, since the test environment's store is `:null_store`)
- Must not touch: the room-creation and join limits, the player screen's JavaScript (a `429` already leaves the screen as it is: the pick `fetch` ignores the response and Submit's freeze stays until the broadcast or the timer, §11), any view, the models, the schema

## Acceptance criteria

- A player's 180 claim requests in one minute, any mix of SET!, picks and Submit, are each answered as today. The 181st answers `429`: no claim is taken (SET!), the claim's stored picks are unchanged (pick), the claim stays pending (Submit)
- Ready, No Set (call, agree, withdraw and There's a Set together) and End game each answer as today up to 30 requests a minute from one player and `429` on the 31st, with no vote counted, no call started, joined or refused
- The host's Start game and Play again together answer as today up to 30 a minute and `429` on the 31st, and the room's status does not change on a refused one
- The counts are per player: two players of one room, sending from the same IP, each get their full count; one at the limit does not refuse the other's claims or votes
- A request without the host cookie does not count against the host's limit: 30 `403`s from a stranger at another IP leave the host's next Start game answered as today
- Once the minute's window has passed, a player who hit a limit is answered as today again
- Each limit is its own count: a player at the claims limit still has their ready, No Set and End game requests answered, and a player at the No Set limit can still claim
- The room-creation (10 a minute per IP) and join (20 a minute per IP) limits behave as before
- A refused request answers with an empty body and broadcasts nothing

## Verification

`bin/test-all && bundle exec standardrb`

Write first: the request specs for each controller's limit (the 181st claim request refused and changing nothing, the 31st ready, No Set, End game and host request refused, two players at one IP counted apart, a stranger's 403s not counting against the host, the window resetting). Show them failing before the code. Keep each spec file under 8 s: setting the store's count close to the limit before the last requests, rather than sending all 180, is fine, as long as one spec shows that requests from the actions of one group add to the same count.

## Out of scope

- Limits on adding or removing a bot (tickets 47, 48 not built: a follow-up below)
- Rate limits on GETs: the player screen, the big screen, `/join?code=`, the join page, `/clock` (the review's F3 is a finding of its own)
- A message on the player screen or the big screen when a request is refused
- Changing the room-creation or join limits, or their messages
- A different store for the counts, or sliding windows

## Comments

Decided: filed apart from 54, overlapping its review finding, because the owner chose option 3 on 54 (a ticket of its own). Instead of: merging it into 54.

Decided: a player's in-game requests are counted by the `player_token` cookie, by IP only without one, because the players at one table share one Wi-Fi address and a count by IP would refuse the whole table for one fast player. Instead of: Rails' default key, the IP.

Decided: SET!, picks and Submit share one count of 180 a minute, because picks go one at a time (§11), so even 8 taps a second through a whole 15-second claim sends 120, normal play is about 5 a claim, and a refused pick would leave the server judging older picks. Instead of: a tighter 60 a minute, which a frantic claim after a few earlier ones could reach.

Decided: Ready, No Set and End game get 30 a minute each, because a person taps each a few times a game and every tap after the first is already a no-op on the server. Instead of: folding them into the claims count, where a burst of picks would block a vote.

Decided: There's a Set and the withdraw DELETE count with No Set, because they are the same `no_set` resource and the same kind of path the request names. Instead of: leaving them unlimited.

Decided: the host's Start game and Play again are limited too, 30 a minute keyed by the host cookie, because a fix covers every path of the same kind (loop-rules section 11) and they are the other in-game POSTs that take the game lock. Instead of: only the six player actions the request lists.

Decided: a refused request answers `429` with no body and the screen shows nothing, because the limits sit far above any person's pace, so only a script meets them, and a message would be a new screen state for the design pass. Instead of: a toast on the player screen.

Decided: fixed one-minute windows in the app's cache store, because that is what Rails' `rate_limit` and the existing room-creation and join limits use. Instead of: a sliding window or a store of its own.

Decided: no schema change. Instead of: a counter column.

Decided: Security: yes, and decided rather than parked, because the limits change no auth, token, credential, permission or privacy rule, they only refuse a pace no person reaches, and the flag holds the build for the owner's review. Instead of: parking it as needs-info.

Decided: adding and removing a bot are left for a follow-up, because their controller does not exist until tickets 47 and 48 are built. Instead of: holding this ticket on them.

Deferred: Limit how often the host may add or remove a bot in a waiting room (`POST` and `DELETE /games/:code/bots`), 30 a minute keyed by the `host_game` cookie, as Start game and Play again are (SPEC §5 Rate limits), once tickets 47 and 48 are built. Filed as 62.

Decided: deep review 20261119-233807 leaves the stale "one exception" sentence in SPEC §5's URL surface for a follow-up, because a review edits no spec and the fix is wording only. Instead of: a pending decision.

Deferred: Behind the scenes: SPEC §5's URL surface paragraph says every POST answers `204 No Content` and "the one exception" is a pick or submit without the claim, `403`; since the Rate limits block (tickets 60 and 62) a request over its limit answers `429`. Reword that paragraph so it names every answer other than `204` (the `403` claim case, the `429` over a limit) and points to Rate limits, and check tickets 60 and 62's own "the one new answer" wording against it. Filed as 66.
