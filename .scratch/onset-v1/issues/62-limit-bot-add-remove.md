# 62: Limit how often the host may add or remove a bot

Status: ready-for-agent
Kind: behavioural
Blocked by: 47, 48, 60
Priority: normal
Feature: Rate limits
Model:
Security: yes
Effort:
Changelog:

## Request

Deferred from 60. Limit how often the host may add or remove a bot in a waiting room (`POST` and `DELETE /games/:code/bots`), 30 a minute keyed by the `host_game` cookie, as Start game and Play again are (SPEC §5 Rate limits), once tickets 47 and 48 are built.

## Spec references

- Shared: 5. Routes, Rate limits (the host's bot controls, new)
- AI opponent, Adding a bot and Removing a bot (the two actions limited)
- Shared: 7. Realtime, Actions answer 204, broadcasts update the screen (the `429` is the one new answer)

## Scope

- Rails' `rate_limit` on the bots controller that tickets 47 and 48 build, `create` and `destroy` under one count: 30 a minute, with a `name:` of its own, so it is a count apart from the host's Start game and Play again count that ticket 60 adds
- Keyed exactly as ticket 60 keys the host's Start game and Play again: by the room the `host_game` cookie names, by `request.remote_ip` when the request has no such cookie. Reuse the key ticket 60 writes rather than a second copy of it; if 60 wrote it inline in `GamesController`, move it where both controllers reach it (a concern or `ApplicationController` private method), with 60's specs still green
- Over the limit: `head :too_many_requests`, nothing else. No bot created or deleted, no broadcast, no game write
- The default store (the app's cache store), as the other limits use
- Request specs for the limit, using the same seam as the existing limit specs (a `MemoryStore` standing in for the controller's `cache_store` increments, since the test environment's store is `:null_store`)
- Must not touch: the room-creation, join, in-game and host room-action limits or their numbers, the big screen's and player screen's JavaScript and views (a `429` with an empty body already leaves the screen as it is, as for ticket 60's host limit), the models, the schema

## Acceptance criteria

- The host's 30 add and remove requests in one minute, any mix, are each answered as today. The 31st answers `429`: an add creates no bot, a removal leaves the bot in the room, and the room's players and `updated_at` are unchanged
- Adds and removes share one count: 15 adds and 15 removes in a minute bring the host to the limit
- The count is the host's own and apart from Start game and Play again: a host at the bots limit still has Start game answered as today, and a host at the Start game and Play again limit can still add and remove bots
- A request without the host cookie does not count against the host's limit: 30 `403`s from a stranger at another IP leave the host's next add answered as today
- Once the minute's window has passed, a host who hit the limit is answered as today again
- A refused request answers with an empty body and broadcasts nothing
- The room-creation, join, in-game and host room-action limits behave as before

## Verification

`bin/test-all && bundle exec standardrb`

Write first: the request specs for the bots limit (the 31st request refused and changing nothing for both an add and a removal, adds and removes counted together, the count apart from Start game, a stranger's 403s not counting against the host, the window resetting). Show them failing before the code. Keep the spec file under 8 s: setting the store's count close to the limit before the last requests is fine, as long as one spec shows that an add and a removal add to the same count.

## Out of scope

- A message on the big screen or the player screen when a request is refused
- Any limit on the bots' own play: a bot acts through its jobs, never through requests
- Changing any other limit, a different store for the counts, or sliding windows
- Rate limits on GETs

## Comments

Decided: Blocked by 47 and 48, because the bots controller this limits only exists once they are built. Instead of: leaving it unblocked for triage to find.

Decided: also blocked by 60, because the host key this limit uses (the room the `host_game` cookie names, IP without it) is written by 60 for Start game and Play again, and building after it reuses that key instead of writing it twice. Instead of: two copies of the host key.

Decided: SPEC §5 Rate limits gains a bullet for the host's bot controls, adding and removing under one count of 30 a minute, because they are one control set on one waiting room, so a host's add and remove taps are one pace. Instead of: 30 each, which doubles what a script may send.

Decided: the bots count is apart from Start game and Play again's, because a host trying bot mixes before a game should never find Start game refused. Instead of: one host count across all four actions, as "as Start game and Play again are" could also be read.

Decided: a refused add or removal answers `429` with no body and the screen shows nothing, because the limit sits far above a person's pace, as for every other in-game limit (§5). Instead of: a message on the big screen.

Decided: no schema change. Instead of: a counter column.

Decided: Security: yes, and decided rather than parked, because the limit changes no auth, token, credential, permission or privacy rule, it only refuses a pace no person reaches, and the flag holds the build for the owner's review, as for ticket 60. Instead of: parking it as needs-info.

Decided: Priority normal, as ticket 60's, because it closes the last unlimited POST once bots exist. Instead of: low.
