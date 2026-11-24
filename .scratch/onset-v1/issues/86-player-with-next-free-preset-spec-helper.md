# 86: Behind the scenes: one spec helper for a player with the room's next free color

Status: done
Kind: behavioural
Blocked by:
Priority: low
Feature: Themes
Model:
Effort:
Changelog: Behind the scenes: specs build their players with one helper that takes the room's next free color.

## Request

Split from 81 (one home for the repeated spec helpers): the player part. Specs build players with literal preset colors in about 30 files, which ticket 54 had to edit one by one and the bot tickets will again; add one helper that creates a player with the room's next free preset and use it wherever the color is not the point. No example's assertions change. The theme helpers are 84, the rate limit and claim helpers 85.

## Spec references

No spec change: specs and spec support only, nothing a user would notice. The helper builds what this already decides:

- SPEC.md, Shared: 4. Data Model > `Player` (`color` one of `Player::PRESET_COLORS`, checked on create; `(game_id, color)` and `(game_id, name)` unique; The 8-player cap)
- SPEC.md, 8. Join page (the first free preset is the one picked)
- CLAUDE.md, Testing

## Scope

Spec support and specs only.

1. **One helper, in every spec type** (model, job, request, system, helper, view), defined in `spec/support/`: given a game and any player attributes, it creates a player in that game with the first preset in `Player::PRESET_COLORS` order that no player in the game holds, the order the join page picks in. Attributes passed in win, a `color:` included. With no `name:`, it names the player "Player <n>", n the game's player count plus one. With no preset free it raises, as the model's validations would. If by build time the app has a model method for the room's first free preset (the bot add, ticket 68, may add one), the helper calls it instead of its own copy
2. **Used wherever the color is not the point**: every player built under `spec/` with a literal preset hex or a `PRESET_COLORS` index, in spec files and in support files and contexts (the 8 player contexts, `add_players`), at build time, the bot tickets' specs included if they are built by then
3. **Kept literal where the color is the point**: examples whose expectations name a color or read it back (join picking and the color radios, the checked preset, the color shown or broadcast, the scoreboard dot), the color validations, uniqueness and the 8-player cap, a row from before the preset rule (any hex), and players created through the join request rather than the model

Must not touch: anything under `app/` or `config/`; what any example asserts; the join request specs that post a color (they test the form); the theme helpers (84); the rate limit and claim helpers (85).

## Acceptance criteria

- One helper under `spec/support/` creates a player in a game with the first free preset; a spec for it shows the first player gets `PRESET_COLORS[0]`, the next `PRESET_COLORS[1]`, a passed `color:` or `name:` wins, a game whose first preset is taken gets the second, and a full game raises
- Every `players.create!`, `Player.create!` or `create(:player)`-style build under `spec/` with a literal preset hex sits in an example whose own expectations name or read that color, or check color validation, uniqueness, the cap or a pre-rule row; every other build uses the helper
- The suite runs as many examples as before the change plus the helper's own, and they pass
- No file outside `spec/` changes, and no spec file runs over 8 s

## Verification

`bin/test-all && bundle exec standardrb`

Tests first: the helper's own spec (first, second, taken first preset, overrides, full game), red before the helper exists. Run `bin/test-all` before moving any build and note the example count, then switch builds folder by folder (`spec/models`, `spec/jobs`, `spec/helpers`, `spec/requests`, `spec/support` with `spec/system`), running each folder after it, and finish with the Verification command.

## Out of scope

- A factory library (FactoryBot or similar) or fixtures
- An app method for the room's first free preset; `PlayersController#first_free_color` stays as it is
- Changing which color any example's assertion names
- The theme helpers (84) and the rate limit and claim helpers (85)

## Comments

Decided: the helper takes the first free preset in `PRESET_COLORS` order, as the join page picks, because a spec reading a player's color then gets the one a real join would. Instead of: a random free preset, which would make color-bearing output vary between runs.

Decided: the helper names an unnamed player "Player <n>", because names must be unique in a room and most builds whose color is not the point do not care about the name either. Instead of: a required `name:`.

Decided: a literal color stays wherever the example's expectations name or read it, because swapping those for the helper would hide what the example checks. Instead of: the helper everywhere with the expected color read back from the player.

Decided: no blocking edge on 68, 69 or 70, because the helper helps their specs whichever builds first and item 2 covers their builds when they come first. Instead of: blocked by the bot tickets.

Decided: the helper is `create_player(game, **attrs)` in `spec/support/create_player.rb`, its spec in `spec/spec_support/`, because a `_spec.rb` under `spec/support/` would be loaded as support by `rails_helper`. Instead of: a spec beside the helper.

Decided: a model-built player that exists before a join request posting a fixed color keeps its literal color (`no_sets`, `claims` Bob, `card_colors` Bob, and the players `controller`, `controller_theme`, `no_set_countdown`, `no_set_refusal` specs), because the helper would take the join's posted color and the join would fail; the color is the point there. Instead of: reordering those examples or changing the colors their joins post.

Decided: the `Player.create!(valid_attrs)` builds in `player_spec` that check name or color validation, uniqueness or a pre-rule row stay literal; the rest use the helper. Instead of: the helper in the validation examples.

Decided: `spec/system/realtime_sync/claim_spec.rb` and `game_over_spec.rb` run over 8 s in both Verification runs, but this ticket does not touch them (they build players only through joins) and they were already slow, so splitting them is left out of this ticket. Instead of: splitting them here, outside Scope.
