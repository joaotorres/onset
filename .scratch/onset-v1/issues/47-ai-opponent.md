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

Decided: held for the next round, over the 6-board round: brief 20261119-42-46 takes 42 and 46 (5 boards) in number order, and this ticket's boards alone (the add-bot control and bot mark on the waiting big screen and the host's player screen in three layouts and both themes, the bot's claim, Start game's "Need a person to play") run well past 6, so it goes in a round of its own, with 48 after it. Instead of: briefing it with 42 and 46 in one oversized round.

Rechecked 2026-11-19, third time: still waiting for the design pass. docs/design-system.md has no changelog entry for this ticket; its v7 entries are tickets 42 (static error pages) and 46 (dark contrast), which design nothing for bots. Brief 20261119-42-46 has returned (its return.md and the v7 entry are in), so the hold is over: the next brief takes this ticket and drops its `Design held:` line, as the brief step does. The spec changes since, triage 42's error page numerals and triage 46's muted token and field borders, do not touch the bot rules. Open tickets: 54, now answered (presets only, a unique index on a room's player colors), is the rule bots already take colors by, as noted above. 58 (§7 Hooks of the settings menu) and 59 (the player screen reads its claim once) touch no bot rule; a bot's claim still shows through `_controller_status`. 60 (a rate limit on the gameplay POSTs) limits a person's requests, and a bot acts through its jobs, not requests, so it is untouched; the add-bot POST is the host's and is not on 60's list. The brief is as described above.

Decided: brief 20261120-47 takes this ticket alone, 10 boards (11 if the add-bot control opens a level picker), over the 6-board round, because a ticket alone over 6 still goes alone and 48's remove control sits on the bot pills and rows these boards draw first. Instead of: 48 in the same round.

Decided: each board in one theme, the new parts (add-bot control, bot mark, "Need a person to play") each shown in both themes across the boards, and the 8-player no-scroll check in portrait with 7 players in landscape and computer so the enabled control shows there (the two-column roster is 4 rows at 7 as at 8), the big screen waiting at 8 players at 1280×800, because a light screen changes colors only (design system, Shared: Rules added in v6) and this keeps the round at 10 boards. Instead of: every board in both themes, about 20 boards.

Decided: the built boards WaitingTh, l-waiting-l-8, l-waiting-c-8, PlayPortraitTh, l-play-p-other, GameOverTh, l-big-waiting4, d-big-waiting1, l-big-claiming and d-big-ended are left as drawn, new boards beside them, because what shipped since them (builds 43 to 45 of those boards, 46's dark muted text and field border, 56's claim reading) does not touch the roster, pills, Start game, scoreboards or announcements this brief extends, and the v7 rules the brief quotes give the dark muted value; the code is the truth for the rest. Instead of: redrawing them from the code first.

Design entry 2026-11-20: docs/design-system.md v8 covers this ticket (Components > Bot mark and Add-bot control, Shared: Rules added in v8, `_start_button`'s "Need a person to play", Screens > Big screen and Player screen Waiting), from return `.scratch/onset-v1/design/20261120-47/return.md` and ten boards in the "11 · Bots" row of the canvas. The canvas matches the return: ten boards added, none moved, resized or changed.

Design proposes: one tap adds one bot. The add-bot control is three buttons, Easy, Medium and Hard, and each tap adds one bot at that level and sends `bot_added`, with no level picker to open or close; three bots take three taps. SPEC AI opponent, Adding a bot says only "picked with each add".

Design proposes: with every color taken the add-bot control is disabled and shows the reason "Room full" beside it (the big screen tile's label row, under "Add a bot" on the host's player screen), tied to the buttons with `aria-describedby`.

Design proposes: the accessible names. The bot mark carries `role="img"` and `aria-label="bot"` everywhere it shows, never `aria-hidden`, so a screen reader hears "Easy bot, bot" in every list, pill, row and announcement. The add-bot control is a `role="group"` named "Add a bot", its buttons named "Add Easy bot", "Add Medium bot" and "Add Hard bot" (the visible level word inside each name).

Decided: the control's look and place (the big screen's waiting rail, in the room tile's place; right under the host's roster, before the invite), the bot mark's glyph, sizes and colors, and the 1280×800 drawing go into design-system v8, while what a tap does, the "Room full" words and the accessible names go to triage as Design proposes, because SPEC holds this app's user-facing words, accessible names (the remove control's "Remove Easy bot") and what an action does. Instead of: committing them all into the design system.

Decided: the rail at 1280×800 with 8 players, which as built may run under the settings button in play as well as waiting, is left to a request of its own, because it predates bots (8 people fill the rail too) and the add-bot tile is 16px shorter than the room tile it stands in for, so this ticket adds no height. Instead of: folding a play-state rail fix into this ticket.

Deferred: On the big screen at 1280×800 with 8 players, keep the Players rail clear of the 56×56 settings button in every state (waiting, playing and ended): the built boards' rail, a 152px room tile and 60px rows with 8px gaps, is about 760px tall and runs under the button. Check what the code renders at 1280 and shrink the rows as the design system's 1280 board draws them (52px rows, padding 8px 16px, 36px scores, 6px gaps) where it does not fit.
