# 11: Play again as a vote on player screens

Status: ready-for-agent
Kind: behavioural
Blocked by:
Model:
Effort:

## Request

Devices-first: Play again as a ready vote on player screens; big screen keeps its button

Replaces "Play again from the big screen" on the player screen's game over. "Play again" works like "I'm ready": the room restarts once every active player has voted. The big screen keeps its own Play again button.

## Spec references

- §8 Views & UX > Player screen (`/games/:code/controller`) > 8. Game over (Play again vote, waiting line, restart rule, accepted risk)
- §2 Game Rules > Round flow > 6. Game end (big screen restarts at once, player screens vote)
- §5 Routes (`POST /games/:code/ready` once ended, `POST /games/:code/restart`)
- §4 Data Model > `Game` > `start_voters`
- §8 Views & UX > Big screen (`/games/:code`) > Ended (big screen Play again restarts at once)

## Scope

Confirmed by code path: the player screen's ended branch in the `players/controller_status` partial ends with the line "Play again from the big screen". `GamesController#ready` calls `Game#vote_start!`, which returns nil unless the game is waiting. `GamesController#restart` is guarded by the `host_game` cookie and calls `Game#restart!`, which already clears `start_voters` and resets scores, deck, board and the claim, No Set and end-game state. `GamesController#ready` does not call `Player#seen!`.

Touches `Game` (a play-again vote over `start_voters` while ended, restarting through `restart!` when every active player has voted, the same active rule as `vote_end_game!`), `GamesController#ready` (route the vote by status, call `seen!` on the voter before voting) and the ended branch of the `players/controller_status` partial (Play again button, styled like I'm ready, and the waiting line). Must not touch the big screen views, the host guard on `restart`, `restart!` itself, the start vote's rule (every player, 2+), the schema, routes or any broadcast partial other than the player screen's ended branch.

## Acceptance criteria

- While ended, `POST /games/:code/ready` from a player adds their id to `start_voters` and answers 204; a repeat vote changes nothing
- While ended, once every active player (last seen within 30s, the voter included) has voted, the room is `playing` with a fresh 12-card board and 69-card deck, every score 0, `start_voters` empty and the same `mode`
- While ended, with an active player who has not voted, the vote does not restart the room
- A player who is not active does not block the restart
- The vote marks the voter seen, so a voter whose last request was over 30s ago still counts as active for their own vote
- `POST /games/:code/ready` while playing changes nothing and answers 204; while waiting the start vote behaves as today
- The ended player screen shows a "Play again" button posting to `POST /games/:code/ready` and no "Play again from the big screen" text
- After voting, the ended player screen shows "Ready ✓ · waiting for n more", n being the active players who have not voted, and no Play again button
- The big screen's Play again (host cookie) still restarts the room at once with votes pending, clears `start_voters`, and still answers 403 without the host cookie

## Verification

`bundle exec rspec`

Write first: model specs in `spec/models/game_spec.rb` for the play-again vote (restarts when every active player voted, waits on an active non-voter, ignores inactive players, same mode, votes cleared after restart), request specs in `spec/requests/games_spec.rb` for `POST /games/:code/ready` while ended, playing and waiting, the voter marked seen, the ended controller page's button and waiting line, and `restart` clearing pending votes.

## Out of scope

- A heartbeat or ping refreshing `last_seen_at` (the stale-activity risk is accepted in §8)
- Showing the vote count, ready marks or a roster on the big screen or the player screen's game over
- Changing the big screen's Play again, its host guard, or who the host is (ticket 08)
- The standings list on the player screen's game over (ticket 07)
- A new column, route or endpoint for the vote
- Returning to the waiting room instead of straight into play
- Renaming "board" and "phone" in the spec (ticket 12)

## Comments

Decided: overlaps 07 on the same game-over screen; filed as its own ticket since one is a vote and the other a list. Instead of: merging into 07.

Decided: the play-again vote counts every active player, the voter included, with no heartbeat, because the user chose it (QUESTIONS 11, option b): nobody can block it, and the first tap after 30s idle may restart alone, recorded in §8 as an accepted risk. Instead of: every player like the start vote, or a heartbeat.

Decided: the vote reuses `start_voters` and `POST /games/:code/ready` while ended, because GLOSSARY.md defines one Ready vote for starting and playing again and `restart!` already clears `start_voters`. Instead of: a new `restart_voters` column and route (a migration).

Decided: `GamesController#ready` calls `seen!` on the voter, as the other player actions do, because otherwise a voter idle for 30s would not count as active for their own vote. Instead of: leaving `ready` without it.

Decided: a vote restart goes straight into play with the same mode, as `restart!` does today. Instead of: back to the waiting room.

Decided: the big screen's Play again stays host-only and restarts at once whatever the votes, clearing them, because the request keeps it as is. Instead of: making it count as a vote.

Decided: the button and waiting line reuse the I'm ready button and status box, so Kind stays behavioural. Instead of: a design pass.
