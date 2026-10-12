# 16: Player screen computer layout during play

Status: done
Kind: visual
Blocked by: 15
Model:
Effort:

## Request

Split from 09 (player screen stands alone, computer layout): a board-sized player screen layout during play at 1024px wide and up.

## Spec references

- SPEC §8 Player screen: the Computer layout (1024px wide and up, Tailwind `lg:`), "Shared by all three during play" and states 2 to 7
- SPEC §8 Player screen > 2. Idle (tapping a card calls SET! in every layout)
- SPEC §10 Component: "Player screen, computer" and the player screen card size rule
- docs/design-system.md v2: `_scoreboard` (rows), `_status_panel` (computer 248×76), "Player screen, during play (ticket 09)" and the card size rule (12px gap on computer). Boards PlayComputer and the play-c-* boards on the canvas in docs/design-handoff.md

## Scope

The playing branches of `#controller_status` at the `lg:` breakpoint, whatever the orientation: the card grid on the left and a 248px side column with the scoreboard stacked above the status panel, SET! and its pill. Reuses the partials from tickets 14 and 15, adding their computer variants. Under 1024px wide, portrait and landscape stay as tickets 14 and 15 built them.

Do not touch: the waiting and ended branches, the portrait and landscape layouts under 1024px, the big screen, any model or controller behaviour.

## Acceptance criteria

- At 1024px wide and up, every playing state shows the board with the deck line on the left and a 248px side column on the right: the scoreboard (one row per player, as in ticket 15), then the 248×76 status panel, the SET! slot (108px button) and its pill
- The computer layout applies in either orientation: a 1024×1366 viewport gets it too, and a 1023px wide landscape viewport keeps the landscape layout
- Cards are 3 rows flowing into columns with a 12px gap, sized to the board's width and height: about 106×148 at 1024×640 with 18 cards, no horizontal scroll
- Idle: tapping a card calls SET! and opens the claim with that card selected (1/3)
- Claiming (mine): one yellow block replaces the status panel and SET!, the pill slot is empty, the board's cards are selectable
- Found-set banner over the top of the board area
- With 8 players and 18 cards there is no page scroll at 1024×640 in every playing state

## Verification

`bundle exec rspec`

Write first:
- a system spec with 8 players and 18 cards at 1024×640 asserting no page scroll and no board horizontal scroll in each playing state, that tapping an idle card opens the claim at 1/3 with it selected, and that 1023×640 shows the landscape layout instead

## Out of scope

- Keyboard shortcuts (Space for SET!, N for No Set), deferred by the request
- Hover or pointer media queries: the viewport width alone picks the layout
- Waiting, game over, the big screen

## Comments

Decided: the play partials scope their portrait and landscape classes with `max-lg:`, because Tailwind emits the orientation variants after `lg:` so they would beat the computer classes in a 1024x1366 viewport. Instead of: a custom variant overriding `portrait:`/`landscape:` globally, which would also change the waiting and ended branches.

Decided: the deck line stays under the board on computer, as in portrait and landscape, because `_board_strip` owns it in every layout and the ticket only asks for it with the board. Instead of: the PlayComputer board's line above the cards beside the room code.
