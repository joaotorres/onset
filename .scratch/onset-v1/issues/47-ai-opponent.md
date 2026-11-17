# 47: AI opponent the host can add from the lobby

Status: needs-triage
Kind: visual
Blocked by: 44, 45
Priority:
Model:
Effort:
Changelog:

## Request

AI opponent: a bot Player (no session_token, no User) the host can add from the lobby, driven by a background job that claims a random valid Set after a delay, reusing Card.any_set_on?. Difficulty is the delay distribution (spec §14 AI opponent); start with a small set of named levels. It plays by the same claim rules as a person: first to reach the server wins. From docs/future-direction.md AI opponent (certain, v2); handoff aae500.

## Comments

Decided: Kind visual, because adding a bot and picking its level is a lobby control the design system does not have yet, and a bot's row in the player list may need its own look. Instead of: behavioural.

Decided: SPEC gains a feature section, AI opponent (Adding a bot, How a bot plays), with the shared rules it touches in SPEC 1, 2 Edge cases, 4 Player and Game, 5 Routes, 12 Background Jobs, 17 Custom events and 8 Big screen, Join page and Player screen Waiting; GLOSSARY gains Bot, because a feature gets its own section and the rest of the spec says how bots fit each shared rule. Instead of: only expanding SPEC 14.

Decided: additive migration, one new column `players.bot_level` (integer enum `easy`, `medium`, `hard`, nullable, nil for a person); no other table or column changes, and `host_player_id` already exists, because a bot needs only its level stored. Instead of: a separate bots table.

Decided: a bot keeps a random `session_token` no browser holds, against the request's "no session_token", because every action finds its player by `find_by(session_token: cookie)`, and a nil token would let any request with no player cookie act as the bot; this keeps the existing auth path unchanged and needs no change to the column's NOT NULL. Instead of: a nil token, which would also mean relaxing NOT NULL on an existing column.

Decided: the host adds bots from the big screen's waiting state (accepted from the host cookie only, as Start game is) and from the host's own player screen while waiting, because SPEC 1 says the player screen stands alone, so a person alone must be able to add a bot without a big screen. Instead of: the big screen only.

Decided: the host's player screen is found through `Game#host_player_id`, set when the host browser joins, which only decides where the control shows while the POST still checks the `host_game` cookie, because `#controller_status` is rendered for broadcasts with no cookie to read. Instead of: leaving `host_player_id` unused and rendering the control from the cookie outside the stream targets.

Decided: three levels, Easy (30 to 50 s), Medium (15 to 30 s) and Hard (6 to 15 s), each a uniform delay drawn whenever the room starts or restarts, the board changes or a claim resolves, the newest draw replacing the bot's earlier timer, because the request asks for a small set of named levels and these span a casual player to a quick one; the numbers are easy to retune. Instead of: a continuous difficulty slider, or a timer that keeps running across claims.

Decided: a bot claims through the same lock as a person, holds its claim 2 seconds so every screen shows "Easy bot is calling SET!", then submits a correct Set, so it is never wrong and never locked out, because the request makes difficulty the delay alone and the room should see the bot call SET! as it would a person. Instead of: claiming and resolving in one step, invisible to the room, or deliberate wrong claims on easy levels.

Decided: a bot never votes (No Set, agree, refuse, End game, Play again) and is never active, so those votes count people only, while the ready vote to start counts it as voted from the moment it joins, because a bot has no screen and SPEC 2 counts active players; a bot still claims a Set during a No Set call when its timer runs out. Instead of: bots that agree to No Set or vote.

Decided: a room starts with 2+ players, bots included, and at least one person; Start game reads "Need a person to play" while every player is a bot, because a room of bots alone could never call No Set or vote to end and would stall. Instead of: letting bots play each other.

Decided: bots are named "Easy bot", "Medium bot", "Hard bot" ("Easy bot 2" for a second of a level) and take the first free preset color, several allowed up to the room's eight colors, and stay through Play again with their scores reset, because names and colors must stay unique (SPEC 4) and a host may want a bot per level. Instead of: one bot per room, or bots that leave at the end.

Decided: telemetry adds `bot_added` with `level`, and `bot_count` on `game_started`, `game_restarted` and `game_finished`; the game events reporter is the top person in the standings, not a bot, because CLAUDE.md asks for an event per new user-facing action, `player_count` alone no longer says who played, and a bot at the top has no screen to report from. Instead of: no new event, and a reporter that can be a bot.

Decided: Blocked by 44 and 45, because the add-bot control and the bot mark go on the player screen and big screen those tickets give their light theme. Instead of: building on the dark screens and redoing it.

Decided: the split waits for the triage after the design entry, as ticket 40's did, because a child briefed now would be ready before its screens are drawn and gate 2 would fail it. Expect a split into bots in play (column, endpoint, timers, the rule changes, telemetry, the big screen control) and the host's player screen control. Instead of: splitting now with no design.

Deferred: The host can remove a bot from a waiting room, from the big screen and the host's player screen. Filed as 48.

Decided: removing a bot is left to a request of its own, because the request asks only to add one and a room can be made again. Instead of: adding a remove control here.

Waiting for the design pass: docs/design-system.md has no changelog entry for this ticket (the latest, v6, is tickets 40 and 41, plus ticket 49's records correction, which designs nothing for bots). Blockers 44 and 45 are deployed, so the brief can be written now, with 48's. Rechecked 2026-11-17 against open tickets 50 to 55: no conflict, since 54's free-preset rule is the one bots already take colors by and 55's ignored-outside-its-state routes match the bot routes. The brief draws the add-bot control with its three levels on the big screen's waiting state and the host's player screen Waiting in portrait, landscape and computer, both themes, with 8 players and no page scroll; the bot mark in the rosters, pills, both scoreboards, standings and podium; a bot's claim in the announcement band and the player screen; and the disabled control and Start game's "Need a person to play".

Decided: SPEC §5's `POST /games/:code/start` row, reworded by ticket 55 to "ignored unless the room is waiting and holds 2 or more players", now adds "at least one a person (AI opponent)", because AI opponent, Adding a bot already disables Start game while every player is a bot and the server must ignore that tap too, as the ready row says. Instead of: leaving the route row silent on bots, so a stale or scripted Start could begin a room of bots alone.

Rechecked 2026-11-17, second time: still waiting for the design pass. docs/design-system.md has no changelog entry for this ticket; its one entry since, ticket 53's records correction, designs nothing for bots, and no brief folder covers it yet. The spec changes since fit the bot rules: 55's Start game and Play again act only in their state (the start row now names the person rule, above), and 56's current claim already covers `BotSubmitJob`, while its ignored End game vote during a claim leaves bots, which never vote, untouched. Open tickets: 54 (parked, the server-side player cap) would put a unique index on a room's player colors; if it is built first, the bots child's add takes the same index, and an add that loses the race for a color is ignored, still `204`, as an add with no color free. 57 is glossary wording on claims and does not touch the Bot entry. 48 (removing a bot) shares this brief. The brief is as described above.
