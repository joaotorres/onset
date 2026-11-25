# 68: The host adds bots to a waiting room from the big screen

Status: deployed
Kind: visual
Blocked by:
Priority: normal
Feature: AI opponent
Model: fable
Security: yes
Effort:
Changelog: The host can add Easy, Medium and Hard bots to a waiting room from the big screen; they show in the room with a bot mark and count as ready, but do not play yet.

## Request

Split from 47 (AI opponent the host can add from the lobby): bots as players, the host's add from the big screen's waiting state, the ready vote and Start game rules with bots, the bot mark in the waiting room, and the telemetry. The bots do not play yet (69), and the host's player screen control is 70.

## Spec references

- SPEC.md, AI opponent > Adding a bot (all bullets: Who, When, Levels, Accessible names, Name and color, Ready at once, Shown everywhere a player is, Telemetry); How a bot plays > It never votes, It cannot be impersonated
- SPEC.md, Shared: 2. Game Rules > Edge cases (the bot bullet)
- SPEC.md, Shared: 4. Data Model > `Player` (`bot_level`, the bot's `session_token`, The 8-player cap, Methods `active?`, `bot?`)
- SPEC.md, Shared: 5. Routes (`POST /games/:code/bots`, `POST /games/:code/ready`, `POST /games/:code/start`)
- SPEC.md, Shared: 6. Round State Machine > Key invariants (starting acts only from `waiting`, inside the lock)
- SPEC.md, Shared: 7. Realtime > Actions answer 204, Screens ignore broadcasts older than what they show, Hooks that must survive any markup change
- SPEC.md, 8. Big screen (Waiting), 8. Player screen (1. Waiting: "waiting for n more" counting people, bots in the roster)
- SPEC.md, Shared: 17. Telemetry > Custom events (`bot_added`, `bot_count` on `game_started`, `game_restarted`, `game_finished`), Game state events come from one player screen (the reporter is never a bot)
- docs/design-system.md v8: Shared: Rules added in v8; Components > Bot mark (waiting pills and roster sizes), Add-bot control (big screen tile, focus, disabled), `games/_start_button` ("Need a person to play"), `players/controller/_roster`; Screens > Big screen (Bots, the 1280×800 drawing), Player screen, Waiting (other players' screens)
- Boards (canvas in docs/design-handoff.md, row "11 · Bots"): bot-big-waiting8-light, bot-big-botsonly-dark; the roster of bot-waiting-p8-dark, bot-waiting-l7-dark, bot-waiting-c7-light as other players see it (no add-bot row)

## Scope

- **Schema**: one additive migration, `players.bot_level` (integer enum `easy`, `medium`, `hard`, nullable, nil for a person). No other column changes
- **`Player`**: `bot?`; `active?` is false for a bot whatever its `last_seen_at`. A bot gets a random `session_token` like any player, which no cookie ever carries
- **Adding a bot**: `POST /games/:code/bots` with `level`. `403` without the room's `host_game` cookie. Otherwise `204` always, and a bot is added only when the room is waiting (checked inside the game lock), the level is one of the three and a preset color is free. The bot takes the first free preset color and the lowest free name of its level ("Easy bot", "Easy bot 2", ...), matched case-insensitively, skipping names people hold. An add that loses the race for a color at the unique color index (ticket 54), or for a name at the name index once ticket 61 builds it, adds nothing and still answers `204`. The add broadcasts as a join does, so every screen shows the bot at once
- **Ready vote and start**: a bot counts as voted from the moment it joins (its ✓ shows at once). The ready vote starts the room when the room holds 2 or more players, at least one a person, and every person has voted. `POST /start` is ignored, still `204`, while every player is a bot. The big screen's `#start_button` reads "Need a person to play" while every player is a bot (and "Need at least 2 players" under 2 players, as today). "Ready ✓ · waiting for n more" counts people only
- **Votes in play**: a bot is never active, so No Set, There's a Set, End game and Play again count people only, as SPEC 2 Edge cases says. Play again (either route) keeps the bots, scores reset with everyone's
- **The big screen's add-bot tile**: at the top of the rail while waiting, in the room tile's place, gone once play starts, as DESIGN v8 Components > Add-bot control draws it: "ADD A BOT" label and three buttons, Easy, Medium and Hard; each tap posts one add at that level and sends `bot_added` with the level. Shown on every big screen, accepted from the host only. Disabled with "Room full" when every color is taken, tied by `aria-describedby`. Group and button accessible names per SPEC Adding a bot. Its root sits inside a region the waiting broadcast replaces, so it updates (and disables) without a reload
- **The bot mark** (DESIGN v8 Components > Bot mark, `role="img"`, `aria-label="bot"`) after a bot's name on the big screen's waiting pills and in the player screen's waiting roster, before the ✓
- **Telemetry**: `bot_added` (`level`) from the tile's tap; `bot_count` (the bots among `player_count`) on `game_started`, `game_restarted` and `game_finished`; the game events reporter is the first person in `Game#standings`, never a bot. Add `bot_added` to nothing else: no `player_joined` for a bot
- Must not touch: the bots' play (timers, claims, `BotMoveJob`, `BotSubmitJob`: ticket 69), the bot mark in play and game over places (69), the host's player screen control and `host_player_id` (70), removing a bot (48), rate limits on the bots route (62), the rail's 1280×800 clearance (67)

## Acceptance criteria

- With the `host_game` cookie, `POST /games/:code/bots` with `level=easy` in a waiting room answers `204` and the room gains a player named "Easy bot", `bot_level` `easy`, the first free preset color, a random `session_token`, already counted as ready
- A second Easy add gives "Easy bot 2"; with a person named "easy bot" in the room, the first Easy bot is "Easy bot 2"
- Without the cookie (or with another room's) the add answers `403` and adds nothing
- The add is ignored, still `204`, when the room is playing or ended, when `level` is anything but the three, and when all 8 colors are taken
- A bot is never `active?`, even with a recent `last_seen_at`; a request with no player cookie never resolves to a bot
- A room of one person and one bot starts once the person votes ready; a room of two people and a bot does not start until both people vote; the voted line reads "waiting for 1 more" with one person left
- A room of bots only does not start by `POST /start` (still `204`) and its big screen shows Start game disabled with "Need a person to play"
- In play, a No Set call with one person and one bot resolves when the person agrees; the End game vote and the Play again vote end and restart on the people's votes alone; after Play again the bots are still in the room with score 0
- The big screen's waiting state shows the add-bot tile with the three buttons for every viewer and hides it once play starts; a tap adds a bot and the pill with its mark appears without a reload; at 8 players the three buttons are disabled with "Room full" and `aria-describedby` points to it
- The bot mark, with accessible name "bot", follows each bot's name on the big screen's pills and in every player screen's waiting roster, and no non-host player screen shows an add-bot control
- `game_started`, `game_restarted` and `game_finished` carry `bot_count`; with a bot first in join order and tied scores, the reporter is the first person, not the bot; a tile tap sends `bot_added` with its level
- In both themes the tile, the disabled state and the mark take DESIGN v8's values (spot checks: the buttons' raised fill and border, the disabled gray, the mark's secondary color)

## Verification

`bin/test-all && bundle exec standardrb`

Tests first:

- Model specs: `Player#bot?`, `active?` false for a bot, the name and color picks (lowest free name, case-insensitive skip, first free color)
- Request specs for `POST /games/:code/bots`: added, `403`, each ignored case, a lost color race answered `204`
- Model or request specs for the ready vote, `POST /start` with bots only, No Set, End game and Play again counting people only
- A system spec on the big screen: tap Easy, the pill with its mark shows; full room disables the control with "Room full"
- Helper or request specs for `bot_count` and the reporter skipping a bot

## Out of scope

- Bots claiming Sets, their timers and the 2-second submit (69)
- The bot mark on scoreboards, the band, the podium, the standings and the found-set banner (69)
- The host's player screen add-bot control and setting `host_player_id` (70)
- Removing a bot (48), rate limits on adding (62), the 1280×800 rail clearance (67)
- A level picker, or any change to the control while an add is in flight

## Comments

Decided: split from 47 as its first child, with the schema, the add route, the vote and start rules and the telemetry, because every later child builds on bots existing. Instead of: the big screen control in a ticket apart from the route.

Decided: Model fable and Security yes, because it adds a host-only action checked by the `host_game` cookie and a new kind of player whose `session_token` must never be reachable by a request. Instead of: no flags.

Decided: the big screen's add-bot tile renders inside `#room_tile` while waiting, which then carries the room's players' version and is replaced on every join with the waiting `#board` (SPEC §7, Screens ignore broadcasts older than what they show, edited to say so), because the tile sits in the room tile's place and must disable when a join takes the last color. Instead of: a new hook root of its own in the rail.

Decided: a bot's ready vote is computed (`Game#ready?`: a bot, or an id in `start_voters`), never written into `start_voters`, because removing a bot (48) then leaves no stale id behind and Play again's vote, which shares the column, never sees one. Instead of: appending the bot's id to `start_voters` when it is added.

Decided: a No Set call by the only person in a room with bots keeps its 15-second countdown, as a call by the only active player always has, because the caller's call is already their agreement, nobody else is there to agree, and SPEC (AI opponent, How a bot plays) has the call still meet the bot's timer; resolving it at once would also break seven existing specs of the sole caller's countdown and hand a lone player free cards against the bots. The criterion "resolves when the person agrees" is met as: the bot never holds a call up, so it resolves as soon as every other person has agreed. Instead of: resolving the call the moment it is made when the caller is the only active player.

Decided: the bot mark is not added to the big screen's rail scoreboard rows while waiting, though board `bot-big-waiting8-light` draws it there, because Scope gives this ticket the waiting pills and the player screen's waiting roster and leaves both scoreboards to 69. Instead of: marking the rail rows now.

Decided: the system specs' Chrome reset is fixed in `spec/support/system/chrome_driver.rb`, in a commit of its own with no trailer, because Chrome 158 refuses the origin "*" Capybara 3.40 clears storage with after each example, which failed every system spec in the suite before any change of this ticket's. Instead of: leaving the Verification command red.

Security note for the owner: `POST /games/:code/bots` answers `403` unless the browser's encrypted `host_game` cookie names this room, checked before anything is read from the request, as Start game checks it; the level is taken only when it is one of the three strings. A bot gets a random `session_token` from the same generator as a person, set in no cookie, so a request with no player cookie (a nil token) matches no bot. No rate limit yet: that is ticket 62.
