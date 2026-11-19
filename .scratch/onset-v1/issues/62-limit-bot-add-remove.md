# 62: Limit how often the host may add or remove a bot

Status: needs-triage
Kind: behavioural
Blocked by: 47, 48
Priority:
Feature:
Model:
Effort:
Changelog:

## Request

Deferred from 60. Limit how often the host may add or remove a bot in a waiting room (`POST` and `DELETE /games/:code/bots`), 30 a minute keyed by the `host_game` cookie, as Start game and Play again are (SPEC §5 Rate limits), once tickets 47 and 48 are built.

## Comments

Decided: Blocked by 47 and 48, because the bots controller this limits only exists once they are built. Instead of: leaving it unblocked for triage to find.
