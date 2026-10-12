# 15: Player screen stands alone in landscape

Status: deployed
Kind: visual
Blocked by: 14
Model:
Effort:

## Request

Split from 09 (player screen stands alone, computer layout): the landscape player screen during play, with every player's score and cards that fit without sideways scroll.

## Spec references

- SPEC §8 Player screen: the Landscape layout, "Shared by all three during play" and states 2 to 7
- SPEC §10 Component: "Player screen, landscape" and the player screen card size rule
- docs/design-system.md v2: `_scoreboard` (landscape rows), `_status_panel` (landscape 144×104), "Player screen, during play (ticket 09)" and the card size rule. Boards PlayLandscape and the play-l-* boards on the canvas in docs/design-handoff.md

## Scope

The playing branches of `#controller_status` in landscape (wider than tall): the board on the left, the 9rem action column (status panel, SET!, pill) and a scores column that replaces the landscape info column during play. Reuses the `_scoreboard`, `_status_panel` and `_found_banner` partials from ticket 14, adding their landscape variants.

Do not touch: the portrait layout from ticket 14 beyond the shared partials' landscape variants, the waiting and ended branches, a computer layout (ticket 16), the big screen, any model or controller behaviour.

## Acceptance criteria

- In landscape, every playing state shows three columns: the board with the deck line on the left, a 9rem action column (status panel, the 128×128 SET! slot, its pill), and the scores column
- The scores column is the scoreboard, one row per player: dot, truncated name, the Locked tag inline before the score for a locked-out player, the score. Same order and entry colors as ticket 14 (claiming solid `yellow-400`, locked content at 45%, own entry `gray-800` with a `gray-500` border)
- The landscape info column (the player's own dot, name and score alone) no longer shows during play
- The board never scrolls sideways: at 18 cards the cards shrink to fit the board's width (about 55×77 at 667×375 with 8 players), at 12 cards they fill the height
- The status panel is 144×104 in the action column: someone else claiming, the No Set panel with "n/m agreed", the locked-out panel, empty while idle
- Claiming (mine): one yellow block (ring, "Your SET!", "Tap 3 cards", n/3) replaces the status panel and SET!, the pill slot is empty, and the board's cards are selectable
- Idle card taps still call SET! as before (ticket 06)
- Found-set banner over the top of the board area
- With 8 players and 18 cards there is no page scroll and no horizontal scroll at 667×375 in every playing state

## Verification

`bundle exec rspec`

Write first:
- request specs in `spec/requests/games_spec.rb` for the playing controller: the scores column lists every player in order with the inline Locked tag, and the own-claim block replaces SET! with no pill
- a system spec with 8 players and 18 cards at 667×375 asserting no page scroll and a board element whose scroll width equals its client width, in each playing state

## Out of scope

- The computer layout at 1024px wide and up (ticket 16)
- Portrait changes beyond the shared partials
- Keyboard shortcuts, waiting, game over, the big screen

## Comments

Decided: the deck line stays under the board in landscape, as the acceptance criteria say, because the spec puts the deck "with the board". Instead of: the foot of the scores column, as on the PlayLandscape board.

Decided: kept the page's 16px padding and the "Room CODE" footer under the columns, so 18 cards at 667×375 come out about 52×73 rather than 55×77, because changing the shared frame would also move the waiting and game over screens. Instead of: an 8px landscape padding with the room code in the scores column, as on the board.

Decided: one scoreboard and one status slot per state, placed by CSS (the scoreboard `landscape:order-last`, the action column `portrait:contents`), and SET!, its rings and the pill now share one size in both layouts per the 128px slot rule, because duplicate renders would double ids and countdown targets. Instead of: separate portrait and landscape copies.
