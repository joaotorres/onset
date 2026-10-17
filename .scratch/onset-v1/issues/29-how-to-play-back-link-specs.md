# 29: How to play Back link: specs and a clearer name

Status: needs-triage
Kind: behavioural
Blocked by:
Model:
Effort:
Changelog:

## Request

How to play Back link: add request specs that ← Back goes to the player screen with a valid ?game= room code and to / with no game param, and rename @return_to in LobbiesController#how_to_play and its view to @game_path; no behaviour change

From review 20261017-005226 (Spec test gap, Standards smell 1). `spec/requests/lobbies_spec.rb` checks a valid code only through the closing **Back to the game** button, never the top **← Back** link, and has no case for a missing `game` param. `@return_to` names the old `return_to` param removed in 94839cd; it now holds the player screen path. SPEC §5's `GET /how-to-play?game=` row (ticket 28) already describes the behaviour, so no spec change. Players notice nothing.

## Comments
