# 22: Align the cards and room code left

Status: deployed
Kind: behavioural
Blocked by:
Model:
Effort:

## Request

Align cards left and room code?

## Spec references

- SPEC §8 Player screen > Shared by all three during play > **Deck**: the "Room CODE" footer centred on the board, directly under the deck line, in the computer layout
- SPEC §8 Player screen: the Computer layout bullet (1024px wide and up, Tailwind `lg:`)

## Scope

The player screen during play at the `lg:` breakpoint: the "Room CODE" footer in `app/views/controllers/show.html.erb` and the computer layout in `app/views/players/_controller_status.html.erb` and `app/views/players/controller/_board_strip.html.erb`. Today the deck line is centred on the board column while the footer is centred on the whole screen, side column included, so their centres differ. The footer may move inside `#controller_status` so it follows the game state across Turbo updates, or stay in `main` and shift by the side column's width during play; either way it ends up centred on the board.

Do not touch: the card grid's position or size, the deck line's text, the portrait and landscape layouts under 1024px, the big screen, any model or controller behaviour.

## Acceptance criteria

- At 1024×640 and 1280×800 during play (idle, claiming (mine), No Set called, deck empty), the horizontal centre of the "Room CODE" footer matches the horizontal centre of the deck line and of the board (`[data-board]`) within 1px
- The footer sits directly under the deck line, with nothing between them, and nothing sits under the 248px side column
- The footer still lines up after a Turbo update re-renders `#controller_status` (another player's claim, a redeal)
- Waiting and game over at 1024×640 keep the footer centred on the screen
- Portrait 375×667 and landscape 667×375 are unchanged: the footer stays centred on the screen
- With 8 players and 18 cards there is still no page scroll at 1024×640 in every playing state

## Verification

`bundle exec rspec`

Write first, in `spec/system/player_screen_computer_spec.rb`:
- a spec at 1024×640 asserting the footer's centre equals the deck line's and the board's in idle and claiming (mine), and that the footer is centred on `main` while waiting
- keep the existing no-page-scroll assertions passing

## Out of scope

- Left-aligning the cards, the deck line or the footer to the board's edge
- Merging the deck count and the room code into one line
- The landscape footer, which has the same offset under 1024px
- The big screen's room tile and deck line
- Any change to the footer's size or colour

## Comments

Decided: visual, because the request does not name the screen and a changed alignment may not be in docs/design-system.md; triage settles which screen. Instead of: behavioural.

Answered 2026-10-13: the user meant the two text lines under the board on the computer player screen (1024px and wider), "N cards left in the deck" and "Room CODE", which are not centred on the same thing. The cards do not move. Triage settled how they align in SPEC §8.

Decided: Kind behavioural, because the fix aligns two existing text lines on the computer layout with no new token, component or layout, so no design pass is needed. Instead of: visual, which would wait on a design brief for a one-line alignment.

Decided: the "Room CODE" footer centres on the board directly under the deck line in the computer layout, because the deck line already centres on the board and portrait centres both lines on it, so the three layouts follow one rule. Instead of: both lines left-aligned to the board's edge, the request's first wording, or one combined line.

Decided: landscape keeps its footer centred on the screen, because the user named the computer layout and the same offset there is a one-line follow-up if wanted. Instead of: moving the landscape footer in this ticket.

Decided: the footer stays centred on the screen while waiting and at game over, because those states show no board to centre on. Instead of: the play offset in every state, which would leave the footer off-centre under the waiting and game over layouts.

Decided: the footer stays in `main` and a CSS `:has([data-board])` group variant gives it a 280px right margin on `lg:` during play, because it follows every Turbo update of `#controller_status` with no markup moved or duplicated. Instead of: moving the footer inside `#controller_status` into each playing state.
