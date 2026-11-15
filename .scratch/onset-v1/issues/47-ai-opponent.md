# 47: AI opponent the host can add from the lobby

Status: needs-triage
Kind: visual
Blocked by:
Priority:
Model:
Effort:
Changelog:

## Request

AI opponent: a bot Player (no session_token, no User) the host can add from the lobby, driven by a background job that claims a random valid Set after a delay, reusing Card.any_set_on?. Difficulty is the delay distribution (spec §14 AI opponent); start with a small set of named levels. It plays by the same claim rules as a person: first to reach the server wins. From docs/future-direction.md AI opponent (certain, v2); handoff aae500.

## Comments

Decided: Kind visual, because adding a bot and picking its level is a lobby control the design system does not have yet, and a bot's row in the player list may need its own look. Instead of: behavioural.
