# 48: The host can remove a bot from a waiting room

Status: needs-triage
Kind: visual
Blocked by: 47
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
