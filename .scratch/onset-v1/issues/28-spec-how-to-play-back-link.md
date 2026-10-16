# 28: SPEC: How to play Back link takes a room code

Status: done
Kind: behavioural
Blocked by:
Model:
Effort:
Changelog: Behind the scenes: the spec now describes the How to play page's Back link, nothing changes for players.

## Request

SPEC §5: add a GET /how-to-play row: with ?game=<room code> matching the code format, Back returns to that room's player screen; anything else goes Back to /. Never a path or URL. Documents 94839cd, docs only

From review 20261017-004042, pending decision 1. 94839cd already built this: `LobbiesController#how_to_play` checks `params[:game]` against `Game::CODE_FORMAT` and builds `game_controller_path` itself; the player screen links `how_to_play_path(game: game.code)`. It replaced a `return_to` path param that let a crafted `/\host` link send Back off the site. SPEC has no How to play route or Back link line today, so this documents the code; no code or test change. Players notice nothing.

## Spec references

- §5 Routes, the `get "how-to-play"` line in the routes block and the `GET /how-to-play?game=` row

## Scope

SPEC.md only. No code, no tests: `LobbiesController#how_to_play`, `app/views/lobbies/how_to_play.html.erb` and `spec/requests/lobbies_spec.rb` already do and prove what the row says (commit 94839cd).

## Acceptance criteria

- The §5 routes block lists `get "how-to-play" => "lobbies#how_to_play", :as => :how_to_play`, as `config/routes.rb` does
- The §5 URL table has a `GET /how-to-play?game=` row saying: a `?game=` matching `Game::CODE_FORMAT` sends **← Back** and **Back to the game** to that room's player screen; anything else, or no code, sends Back to `/`; only a code is accepted, never a path or URL

## Verification

`grep -q 'get "how-to-play" => "lobbies#how_to_play"' SPEC.md && grep -qE '^\| GET \| `/how-to-play\?game=` \|.*CODE_FORMAT.*never a path or URL' SPEC.md && echo ok`

Tests to write first: none, docs only.

## Out of scope

A §8 "How to play" view section describing the page's content and layout: the review asked for the route and Back behaviour only. Any code or test change. Any change to the landing's or player screen's link text.

## Comments

Decided: the row also documents the closing **Back to the game** button and the Start a game / Join fallback, because the page has two links driven by the same `?game=` check and a row naming only "Back" would leave the second one undocumented. Instead of: a row about the top "← Back" link alone, as the request worded it.

Decided: the `get "how-to-play"` line is added to the §5 routes block too, because the block is presented as the routes file and `config/routes.rb` has carried that line since the page was built. Instead of: adding the table row only.

Decided: the ticket closes in triage as `done`, as tickets 25 and 27 did, because every change it asks for is a spec edit that gate 1 makes triage commit, so a build would have nothing left to do; the Verification command above passed. Instead of: a ready-for-agent brief that spends a build session on no edit.
