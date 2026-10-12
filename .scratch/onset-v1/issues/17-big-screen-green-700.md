# 17: Big screen green buttons on green-700

Status: done
Kind: behavioural
Blocked by:
Model:
Effort:

## Request

Big screen Start game and Play again use green-700 under white text, per design system v2

docs/design-system.md v2 added the rule that white text on green uses `green-700` (`#15803D`), since `green-600` is about 3.3:1, and listed these two buttons under Known gaps: `games/_start_button` (Start game) and `games/_board` (Play again) both use `bg-green-600 hover:bg-green-500` with white text. The user chose to leave them out of tickets 07 to 10 and fix them in a ticket of their own.

## Spec references

- SPEC §10 Cards and visual system > Visual system, the color meaning table, green row (now says `green-700` for white text, as the orange row does)
- SPEC §8 Views & UX > Big screen (`/games/:code`): Waiting, `#start_button` Start game; and §2 Game Rules > Round flow, 6. Game end: the big screen's Play again

## Scope

- The big screen's Start game button (the `#start_button` partial) and Play again button (the game over view of the big screen board partial): `bg-green-600 hover:bg-green-500` becomes `bg-green-700 hover:bg-green-800`, the pair the player screen's I'm ready and Play again already use
- `docs/design-system.md`: remove the Known gaps bullet about these two buttons once they are fixed
- Must not touch the player screen, sizes, copy, the disabled Start game state or any other green (outlines, `green-400` text, the correct-claim panel)

## Acceptance criteria

- On the big screen in waiting with 2 or more players, the Start game button's classes include `bg-green-700` and `hover:bg-green-800`, and include neither `bg-green-600` nor `hover:bg-green-500`
- On the big screen at game over, the Play again button (the form posting to the restart path) has classes including `bg-green-700` and `hover:bg-green-800`, and neither `bg-green-600` nor `hover:bg-green-500`
- The disabled Start game (fewer than 2 players) stays `bg-gray-800`
- No view under `app/views` puts `bg-green-600` on a button
- The Known gaps section of `docs/design-system.md` no longer lists these buttons

## Verification

`bundle exec rspec`

Write first, in `spec/requests/games_spec.rb` next to the player screen's "uses green-700 for Play again" example: request specs for the big screen `GET /games/:code` in waiting (2 players) and at game over that read the Start game and Play again button classes with Nokogiri.

## Out of scope

- A shared button partial or helper for green buttons
- Changing hover or active effects beyond the `green-800` hover
- Any other color on the big screen

## Comments

Decided: Kind behavioural, because the green-700 rule and token are already in docs/design-system.md v2 and nothing new is drawn. Instead of: visual, waiting on a design pass.

Decided: SPEC §10 green row gets the `green-700` for white text note, mirroring the orange row, because the rule is behaviour-visible and the spec stated it only for orange. Instead of: No spec change, leaving the rule in docs/design-system.md alone.

Decided: hover goes to `green-800`, because the player screen's green-700 buttons already hover to `green-800`. Instead of: keeping `hover:bg-green-500`, which is lighter and fails white text contrast too.
