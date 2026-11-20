# 48: The host can remove a bot from a waiting room

Status: needs-triage
Kind: visual
Design held: 20261120-47
Blocked by: 68, 70
Priority:
Model:
Effort:
Changelog:

## Request

Deferred from 47. The host can remove a bot from a waiting room, from the big screen and the host's player screen.

## Comments

Decided: Kind visual, because a remove control on a bot's row is a component the design system does not have yet. Instead of: behavioural.

Decided: SPEC AI opponent gains Removing a bot, with §5 Routes (`DELETE /games/:code/bots/:id`), §7 Screens ignore broadcasts older than what they show, §8 Big screen and Player screen Waiting, §17 Custom events and the Bot entry in GLOSSARY, because the removal touches each rule adding a bot does. Instead of: a line in Adding a bot.

Decided: the remove control sits on each bot's pill on the big screen and its row in the host's player screen roster, shown on every big screen and accepted from the `host_game` cookie only, as the add-bot control and Start game are, because removal is the add's mirror and the spec already draws the host line there. Instead of: a single "remove a bot" picker beside the add-bot control.

Decided: one tap removes the bot with no confirmation, because adding it back is one tap and nothing else is lost. Instead of: a confirm step.

Decided: the server deletes the bot's `Player` row and ignores, still `204`, any id that is not a bot of this room or a room that is not waiting, so a person can never be removed and a double tap changes nothing, because a waiting bot has no claims or timers to keep and the request is bots only; no migration. Instead of: soft-removing with `left_at`, or letting the host remove people too.

Decided: the removal also writes the game's `updated_at` in its transaction, because the stream version is the newest `updated_at` of the game and its players, and deleting the newest player would lower it below what screens show, so they would drop the removal's broadcasts. Instead of: relying on the player version alone.

Decided: a new bot takes the lowest free name of its level ("Easy bot" again before "Easy bot 3"), and the freed color goes back to first-free order, because names only need to stay unique and the lowest free one reads most naturally. Instead of: counting up past removed bots.

Decided: telemetry adds `bot_removed` with the removed bot's `level`, because CLAUDE.md asks for an event per new user-facing action. Instead of: no event.

Decided: Blocked by 47, because removing a bot needs bots built; the triage after the design entry replaces 47 with the child of its split that adds bots, since a split parent never reaches done. Instead of: no blocker until 47 splits.

Waiting for the design pass: docs/design-system.md has no changelog entry for this ticket (the latest, v6, is tickets 40 and 41). It is best drawn in the same brief as 47: the remove control on a bot's pill on the big screen's waiting state and on a bot's row in the host's player screen roster, in portrait, landscape and computer, both themes, with 8 players, the add-bot control and no page scroll; the remove control's focus and hover states; and the waiting states after a removal leaves one person ("Need at least 2 players", "Waiting for more players to join…").

Decided: SPEC AI opponent, Removing a bot's When bullet now says the server checks the room is waiting inside the game lock, as ticket 55 made starting do (§6 Key invariants), so a removal racing the last ready vote or Start game either lands first or is ignored, because a check outside the lock could delete a bot from a room that has just started, after its timer was drawn. Instead of: leaving the removal's waiting check unplaced.

Rechecked 2026-11-17: still waiting for the design pass. docs/design-system.md has no changelog entry for this ticket; its one entry since the first triage, ticket 53's records correction, designs nothing for bots, and no brief folder covers it yet. Blocker 47 is still needs-triage and unsplit, so `Blocked by: 47` stands. The spec changes since fit the removal: 55's Start game and Play again act only in their state (the start row now needs a person, and a removal never removes one, so it never leaves a room of bots alone), the race with the start is settled above, and 56's current claim does not reach a waiting room. Open tickets: 54 (parked) would put a unique index on a room's player colors; deleting the bot's row frees its color under that index too, so nothing changes here. 57 is glossary wording on claims and does not touch the Bot entry. 42 and 46 do not touch the waiting room's controls. The brief is as described above, drawn with 47's.

Decided: held for the next round, over the 6-board round: brief 20261119-42-46 takes 42 and 46 in number order, 47 alone runs past 6 boards and goes next, and this ticket's remove control sits on the bot pills and roster rows 47 draws first. Instead of: briefing it now, before the bots it removes are drawn.

Rechecked 2026-11-19, third time: still waiting for the design pass. docs/design-system.md has no changelog entry for this ticket; its v7 entries are tickets 42 (static error pages) and 46 (dark contrast), which design nothing for bots. Brief 20261119-42-46 has returned (its return.md and the v7 entry are in), so that hold is over and the brief step drops the `Design held:` line; this ticket's remove control still sits on the bot pills and roster rows 47 draws, so it goes in 47's round when the boards fit, or the round after it. Blocker 47 is still needs-triage and unsplit, so `Blocked by: 47` stands. The spec changes since, triage 42's error page numerals, triage 46's muted token and field borders and 57's glossary Current claim, do not touch the removal. Open tickets: 54, now answered (presets only, a unique index on a room's player colors), is freed by deleting the bot's row as noted above. 58 (§7 Hooks of the settings menu) and 59 (the player screen reads its claim once) touch no waiting room control. 60 (a rate limit on the gameplay POSTs) lists I'm ready, SET!, picks, Submit, No Set and End game; the host's remove-bot DELETE is not on its list, so nothing conflicts. The brief is as described above, drawn with or after 47's.

Decided: held for brief 20261120-47, over the 6-board round: 47 alone takes 10 boards, and this ticket's remove control sits on the bot pills and roster rows that brief draws, so it is briefed in the next round, from 47's boards. Instead of: briefing it with 47 in one oversized round.
