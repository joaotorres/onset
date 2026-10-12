# 14: Player screen stands alone in portrait

Status: ready-for-agent
Kind: visual
Blocked by:
Model:
Effort:

## Request

Split from 09 (player screen stands alone, computer layout): the portrait player screen during play, plus the pieces every layout shares (found-set banner, purple pills, arrive outline).

## Spec references

- SPEC §1 Overview (the player screen stands alone)
- SPEC §2 Round flow, step 3, and §2 Edge cases (lockout only blocks SET!)
- SPEC §7 Hooks that must survive any markup change (`#controller_status`, `card-tap`, `card-selection`)
- SPEC §8 Player screen: the Portrait layout, "Shared by all three during play" and states 2 to 7
- SPEC §10 Component: "Player screen, portrait" and the player screen card size rule; §10 Visual system `animate-arrive`
- docs/design-system.md v2: `_scoreboard` (portrait chips), `_status_panel`, `_found_banner`, "Player screen, during play (ticket 09)" and "Rules added in v2" (card size, 128px SET! slot, 64px status slot, filled purple pills). Boards PlayPortrait and the play-p8-* and play-p3-* boards on the canvas in docs/design-handoff.md

## Scope

The playing branches of the player screen status (`#controller_status` while `Game#playing?`), in portrait (narrower than tall). New partials `players/controller/_scoreboard`, `_status_panel` and `_found_banner`; `_secondary_action` restyled. The idle board in portrait reuses the `card-tap` claim form that the landscape board already has.

Layout-independent changes land in every layout now: the found-set banner component, the filled purple pills and the arrive outline on every player screen board, landscape included.

Do not touch: the waiting and ended branches (tickets 07 and 10), the header partial's markup (it stays on waiting and game over), the landscape columns, a computer layout (tickets 15 and 16), the big screen, any model or controller behaviour.

## Acceptance criteria

- In portrait, every playing state (idle, deck empty, claiming mine, someone else claiming, No Set countdown before and after agreeing, locked out wrong and time's up, found-set banner) shows top to bottom: the scoreboard, the board at full width with the deck line, the 64px status slot, the 128×128 SET! slot and its pill. The header with dot, name and score is not shown during play
- The scoreboard lists every player in score order, ties in join order, as chips (dot, truncated name, score), 4 per row, at most 2 rows with 8 players. The claiming player's chip is solid `yellow-400` with `gray-950` text; a locked-out player's chip has its content at 45% opacity and a red Locked badge on its top-right corner; the player's own chip is `gray-800` with a `gray-500` border
- The deck line reads "N cards left in the deck", or an orange "Deck is empty" pill once the deck is empty
- Cards in `Game#last_dealt` carry the `animate-arrive` green outline on the player screen board in every state that shows the board, in portrait and in landscape
- The status slot keeps 64px in every state and is empty while idle, so the board does not resize on a state change
- Idle: tapping a portrait board card posts the SET! claim and opens the claim with that card selected (1/3), as landscape already does; read-only states (someone else claiming, No Set, locked out) render the board without the tap form and not dimmed
- Claiming (mine): the yellow claim bar (ring, "Your SET!", "Tap 3 cards", n/3) takes the status slot and the 3-slot tray replaces SET! and its pill; no No Set is offered
- Someone else claiming: the status slot reads "Alex is calling SET!" on `gray-900` with a `yellow-400` border; the disabled SET! shows the seconds inside a yellow ring; No Set disabled
- No Set countdown: the purple status panel with the ring, "No Set called by Alex" and "n/m agreed"; SET! above "I agree, no Set" filled `purple-700` with white text; after agreeing, or for the caller, the waiting text outlined `purple-500` with `purple-200` text
- Idle No Set is filled `purple-700` with white text, in every layout
- Locked out: the status slot is `red-950` with a `red-600` border, "Wrong! −1" or "Time's up! −1", shaking once; SET! is the 5-second Locked countdown; No Set, or the End game vote once the deck is empty, stays enabled
- Found-set banner: a `green-950` panel with a `green-500` border, the three cards small, the finder's dot, "Alex found a Set" and "+1" in `green-400`, over the scoreboard in portrait, ignoring taps and fading with `.found-set-flash`; the board under it shows the replaced cards with the arrive outline
- Other players' wrong claims and time's ups show no banner, only their Locked tag and score on the scoreboard
- With 8 players and 18 cards there is no page scroll at 375×667 in every playing state; with 3 players and 12 cards the cards are larger (about 71×99)
- `#controller_status` stays the outermost element of the region and still wraps the scoreboard, deck line, state body and banner

## Verification

`bundle exec rspec`

Write first:
- request specs in `spec/requests/games_spec.rb` for `GET /games/:code/controller` on a playing game: scoreboard entry order (score desc, join order on ties), the claiming entry's yellow class, the locked entry's "Locked" tag, the own entry's tint class, the deck line text for a full and an empty deck, the arrive class on `last_dealt` cards, no header during play, No Set enabled while locked out, no No Set during the player's own claim
- a system spec with 8 players (one per preset color, long names) and 18 cards at 375×667, asserting no page scroll (document scroll height equals the viewport) in each playing state, and that tapping a portrait idle card opens the claim at 1/3 with that card selected

## Out of scope

- The landscape action and scores columns, landscape card sizing and the computer layout (tickets 15 and 16)
- Keyboard shortcuts (Space for SET!, N for No Set)
- Waiting, game over, the invite and the big screen
- Banners for other players' wrong claims or time's ups
- New tokens or animations

## Comments
