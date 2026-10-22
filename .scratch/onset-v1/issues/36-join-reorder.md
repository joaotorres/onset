# 36: Lobby screens ignore an older join broadcast

Status: ready-for-agent
Kind: behavioural
Blocked by:
Model:
Effort:
Changelog:

## Request

The waiting board, the start button and every player screen's controller status carry the newer of the game's and the room's players' versions, so two joins that arrive out of order cannot leave the roster or the player count one join behind (SPEC §7, Screens ignore broadcasts older than what they show, extends the second bullet to the waiting #board, #start_button and #controller_status for the other players)

From review 20261022-163847, pending decision 1, a gap left by ticket 34. A join writes only the player (`belongs_to :game` has no `touch`), yet `Player#broadcast_player_joined` calls `Game#broadcast_lobby_state`, which resends the waiting `#board` (roster), `#start_button` (player count) and each player's `#controller_status` at the game's unchanged version. Equal versions render, so when two join broadcasts are delivered out of order the older roster wins until the next broadcast.

The fix uses the stamp `#scoreboard` already uses (`stream_version(game, *players)` over the room's players), applied to those three roots. No `touch` on the association and no migration: the user chose this over accepting the gap, because a later fix costs the same and ships a known hole.

## Spec references

- §7, Screens ignore broadcasts older than what they show: the first bullet, which now puts the waiting `#board`, `#start_button` and `#controller_status` among the roots that carry the newer of the game's and every room player's version
- §7, Hooks that must survive any markup change (the six roots, unchanged)

## Scope

- The `data-version` expression on three roots: the waiting branch of the big screen board partial, the start button partial and the player screen's controller status partial. Each passes the game and every player in the room to `stream_version`, as the scoreboard partial does.
- The specs that pin the stamps: the request spec on the hook roots' versions and the broadcast versions block of the game model spec.
- Not touched: `ApplicationHelper#stream_version` (it already takes any number of records), the model callbacks and what they broadcast, `Player belongs_to :game`, the `turbo:before-stream-render` listener, the jobs, the schema.

## Acceptance criteria

1. Big screen of a waiting game with two players who joined after the game was created: `#board` and `#start_button` carry `data-version` equal to `stream_version(game, *game.players)`, which here is the newest player's version and strictly greater than `stream_version(game)`. `#announcement` and `#room_tile` still carry `stream_version(game)`.
2. Big screen of a playing game whose players were written after the last game write: `#board` carries `stream_version(game)`, as before.
3. Player screen: `#controller_status` carries `stream_version(game, *game.players)`. With Alice joined first and Bob second, Alice's screen carries Bob's version, strictly greater than `stream_version(game, alice)`.
4. Model, broadcasts captured with `capture_turbo_stream_broadcasts`: when Bob joins a waiting game Alice is already in, the `board` stream on the game's channel and the `controller_status` stream on Alice's channel each carry a version equal to Bob's `updated_at` in integer microseconds, strictly greater than the version the same targets carried in Alice's join broadcasts. The `#start_button` root inside that board stream carries the same version.
5. `spec/system/big_screen_spec.rb` and `spec/system/stale_broadcasts_spec.rb` pass unchanged.
6. The rest of the suite stays green.

## Verification

Write first: the request spec examples for 1 to 3 and the model example for 4, and see 1, 3 and 4 fail on the current code (the roots carry the game's version). Then:

```
bundle exec rspec
```

## Out of scope

- `touch: true` on `Player belongs_to :game`, any game write on join, a counter column, a migration.
- Changing which streams a join sends, their order or their partials; a queue or a mutex around broadcasts.
- The playing and finished `#board`, `#announcement` and `#room_tile`: they stay on the game's version.
- The listener in `stream_versions.js`, `UnblockNoSetJob`, `UnlockBroadcastJob`.
- A system spec that reorders two joins through the cable.
- Caching or preloading beyond reading `game.players` in the partial; `broadcast_lobby_state` and `broadcast_game_state` already load the association.

## Comments

Decided: `#controller_status` carries the newer of the game's and every room player's version in every game state, not only while waiting, because it shows the other players' scores and lockouts during play as well and one rule per root is easier to keep than one per state; a stamp that only grows hides nothing on the page. Instead of: widening the stamp to the room's players only in the waiting branch.

Decided: the playing and finished `#board` keep the game's version, because those branches show game state alone (the cards, and the claiming player comes from the game row) and the request names the waiting board. Instead of: stamping every `#board` with the room's players.

Decided: `#start_button` carries the room's players' version from its own partial wherever it renders, nested in the waiting board and as its own replace, because it shows the player count and is one partial. Instead of: stamping it only when broadcast on its own.

Decided: the stamp is proven by request and model specs (the rendered attribute and the captured join broadcasts), not by a system spec that reorders two joins, because the drop mechanism is already covered by ticket 34's system spec and the cable's reordering cannot be forced deterministically. Instead of: a system spec that would flake.

Decided: no glossary change, as ticket 34 decided: the version is a transport detail no player or screen names. Instead of: adding an entry.
