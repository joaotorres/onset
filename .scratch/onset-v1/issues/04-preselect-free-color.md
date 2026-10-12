# 04: Pre-select the first free color

Status: done
Kind: behavioural
Blocked by:
Model:
Effort:

## Request

Join form: pre-select the first free color; on a color clash, re-render with the next free one selected

Taken colors are already greyed out when the join page renders, and the server already rejects a duplicate color. The player can still pick another free color. The join page does not update live as others join.

## Spec references

- §8 Views & UX > Join page (`/games/:code/players/join`) (first free color selected, next free after a clash, none when all are taken, no live update)
- §4 Data Model > `Player` > Validations (`(game_id, color)` unique, documenting the existing validation)

## Scope

Confirmed by code path: the join form renders from `Player.new` with no color, so no swatch is checked and a name-only submit fails with "Color can't be blank". On a clash, `PlayersController#create` re-renders with `@player.color` set to the now-taken hex, whose radio is disabled, so the form comes back with the taken swatch checked and disabled and no free one selected. The `Player` color uniqueness validation (scoped to game) already rejects the duplicate.

Touches how the join form's selected color is chosen (`PlayersController` join/new/create and the `players/new` view, or a small helper on `Game` such as a free-color lookup over `PlayersController::PRESET_COLORS`). Server-rendered `checked` radio only, no JS. Must not touch the preset list, the swatch markup and its taken/selected styles, the color validation, the error copy, the rate limit, the `player_token` cookie or any broadcast.

## Acceptance criteria

- `GET /games/:code/players/join` on a game with no players renders the first preset color's radio checked and no other checked
- With the first two preset colors taken, the join page renders the third preset color's radio checked and the taken radios unchecked and disabled
- Submitting the form with only a name (the preselected color left as is) creates the player with that color and redirects to the player screen
- Posting a color that another player in the game already holds answers 422, shows the color error, renders the next free preset after the posted one checked (preset order, wrapping past the last to the first), and leaves the taken radio unchecked
- A re-render for a name error with a free color posted keeps that color checked
- With all 8 preset colors taken, the join page renders no radio checked and still renders the form
- The rate-limited 429 render and `GET /games/:code/players/new` select the first free color the same way

## Verification

`bundle exec rspec`

Write first: request specs in `spec/requests/players_spec.rb` for each criterion above, asserting the `checked` attribute on the `player[color]` radios by value (empty game, first two taken, clash with wrap-around, name error keeps the choice, all taken). Extend the existing "rejects a duplicate color in the same game" example with the next-free check.

## Out of scope

- Live updates of the join page as others join (Turbo stream or polling)
- Random or remembered color choice, or a cookie for the last color used
- Auto-retrying the join with the next free color instead of re-rendering
- Changing the presets, their order or the swatch styles
- The creator's join flow of ticket 08 (it reuses this form and inherits the behaviour)

## Comments

Decided: "next free" after a clash means the next free preset after the clashed one in `PRESET_COLORS` order, wrapping to the start, because the request distinguishes it from "first free" and preset order is the grid's reading order. Instead of: the first free color again.

Decided: a re-render for any other error keeps the player's color when it is still free, and falls back to the first free color when none was posted, because overriding a valid choice would surprise the player. Instead of: always resetting to the first free color.

Decided: with all 8 colors taken nothing is selected and the form renders as today, because the spec sets no player cap and the existing color error covers the submit. Instead of: hiding the form or adding a "room full" message.

Decided: SPEC §4 now states the existing `(game_id, color)` uniqueness, because this ticket relies on it and the code already enforces it. Instead of: leaving the validation undocumented.

Decided: Kind stays behavioural, because the selected swatch style (white ring and check) already exists. Instead of: a design pass.
