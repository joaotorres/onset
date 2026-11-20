Design return for tickets 47.

## New tokens

None. Every color below is already in Shared: Themes (v6) or the Tailwind default palette, used in a role the design system already gives it (secondary text, raised bordered, disabled gray button, focus outline, the band name colors).

## New components

### Bot mark

The Lucide-style "bot" glyph (a rounded head with an antenna, two eyes and two ears), inline stroke SVG, 24 viewBox, stroke 2 (2.4 at 11px), round caps and joins, `stroke="currentColor"`. It sits right after the name (after "you" where both show), before the ✓, the Locked tag and the score, so it never moves those.

- **Accessible text**: `role="img" aria-label="bot"` on the SVG, so a screen reader hears "Easy bot, bot" in every list, pill, row and announcement. Decorative only nowhere: the mark is the one sign of a bot that does not rely on the name
- **Color**: secondary text, `gray-400` dark / `gray-600` light. On the claim fill (`yellow-400`) it takes the entry's `gray-950` text. In the big screen bands it takes the band's name color. As a graphic it needs 3:1; it gets more everywhere:
  - `gray-600` `#4B5563` light: 7.56:1 on white, 7.23:1 on `gray-50`, 6.8:1 on the `gray-100` own row
  - `gray-400` `#9CA3AF` dark: 7.8:1 on `gray-950`, 6.8:1 on `gray-900`, 5.6:1 on the `gray-800` own entry
  - `gray-950` on `yellow-400`: 13.2:1
  - Claiming band light `yellow-800` `#854D0E` on `yellow-50`: 6.6:1; dark `yellow-400` on its 10% tint over `gray-950`: about 11:1
- **Sizes, per place** (gap to the name is the row's own gap, 4 to 12px):
  - Big screen waiting pills: 26px at 1920 (30px names), 22px at 1280 (24px names)
  - Big screen rail scoreboard rows: 26px
  - Big screen announcement band (Claiming, and Correct, which no board draws): 44px inline in the 60px headline, `vertical-align: -4px`, between the name and the rest
  - Big screen ended headline: 72px between "Hard bot" and "wins", in `gray-400` dark / `gray-600` light (the headline stays primary text)
  - Big screen podium: 30px under the first place's 36px name, 26px under the 30px names
  - Player screen waiting roster: 14px portrait, 13px landscape, 16px computer
  - Player screen play scoreboard: 11px in portrait chips; 13px in landscape rows, 16px in computer rows (no board, see below)
  - Status panel (someone else claiming): 16px, 4px closer to the name than the panel's 10px gap
  - Found-set banner: 14px (no board, see below)
  - Winner line: 16px, "★ Hard bot [mark] wins with 9"
  - Standings rows: 14px portrait, 14px landscape, 16px computer
- **Where no board draws it**:
  - Non-host player screen while waiting: the roster as boards 4 to 6 draw it, bots with their mark and ✓, and no add-bot control at all (the roster runs straight into the invite)
  - Landscape and computer play scoreboards: one row per player, mark after the truncated name, then the Locked tag (never on a bot, which is never locked out) and the score; on the claiming row it is `gray-950` like the text
  - Found-set banner: "Easy bot [mark] found a Set", the mark 14px in secondary text after the name, `gray-400` on `green-950` (5.8:1) dark, `gray-600` on `green-50` (7.2:1) light
  - Big screen Correct band: "Easy bot [mark] found a Set", 44px, in the band's name color, `green-400` dark / `green-700` light, as the Claiming band takes yellow
- Portrait chips are 83px wide, so a bot's name truncates there ("Easy…") like any long name; the mark and the dot still tell it apart

### Add-bot control

A group of three buttons, one per level, each tap adding one bot at that level: no picker and no open state, so there is no eleventh board. `role="group"` with `aria-label="Add a bot"`; each button's accessible name is "Add Easy bot", "Add Medium bot", "Add Hard bot" (the visible word is in the name). Each button shows a 2.5-stroke "+" glyph then the level. Style: the Raised, bordered row (dark `gray-800`, `gray-700` border, `gray-50` text, 14.5:1; light `gray-100`, `gray-300` border, `gray-900` text, 16.12:1), the same as Copy link and Show QR.

- **Big screen**: a panel tile at the top of the rail while waiting, where the room tile appears once play starts (the room tile is hidden while waiting). Panel, radius 24, padding 20, light inset edge. "ADD A BOT" label 18px uppercase, 0.1em tracking, secondary text, as "ROOM" and "PLAYERS". Then three equal buttons, 56px tall, radius 14, gap 10, 22px semibold, 18px "+". Tile 136px tall. Shown on every big screen while waiting, accepted from the host only, as Start game. Gone once play starts
- **Player screen, host only, while waiting**: one row right under the roster. The label "Add a bot" sits left in a fixed column, then the three equal buttons
  - Portrait: 44px tall, label column 72px, 14px semibold label, 15px buttons, 14px "+", radius 12, gap 8
  - Landscape: 40px tall, label column 64px, 13px label, 14px buttons, 13px "+", in the roster column
  - Computer: 48px tall, label column 88px, 16px label and buttons, 16px "+", inside the roster panel
- **States**:
  - Enabled: as above
  - Focus: the 2px `blue-500` outline at 2px offset on the focused button (board 2 dark, board 3 light)
  - Pressed or pending: none. The action answers 204 and the broadcast adds the bot; the control does not change
  - Disabled, every color taken: all three buttons take the disabled gray button (`gray-800` + `gray-500` dark, `gray-200` + `gray-600` light, 6.10:1; labels exempt), the border set to the fill so nothing resizes, `disabled` and `aria-describedby` on the reason. The reason "Room full" sits at the right of the big screen tile's label row (18px, secondary) and under "Add a bot" in the phone label column (12px, secondary)
- No sizes move between states, and the control never moves SET!, the pill slot or the board (it only exists while waiting)

### Start game, disabled with "Need a person to play"

The existing disabled `_start_button`: disabled gray button, "Need a person to play" beside it in secondary text at the size of "Need at least 2 players", tied to the button with `aria-describedby`. Board 2.

## New or changed rules

- A bot shows its bot mark right after its name everywhere a player's name shows: pills, rosters, scoreboards, the status panel, the found-set banner, the bands, the headline, the podium, the winner line and the standings. The mark takes secondary text color, or the text color of a claim-filled entry, or the name color in a band
- The bot mark carries `aria-label="bot"`; it is never `aria-hidden`
- The add-bot control is three level buttons, one tap per bot, on the big screen's waiting rail and under the host's own waiting roster, nowhere else. Disabled, all three take the disabled gray button and the reason "Room full"
- Room left for ticket 48's remove control: on a bot's big screen pill, after the ✓ (pills are content-sized and wrap; board 1 leaves a third pill row free at 1280×800); on a roster row, after the ✓ at the row's right end, where it would truncate the name further rather than move anything
- New dark boards here use `muted` `#7C8390` for the "Room CODE" footer and the settings icon (v7)

## Decisions the spec does not cover

- One tap adds one bot: three level buttons rather than an "Add a bot" button that opens a level picker. Fewer taps and no open state to close; the host taps three times for three bots. Each tap sends `bot_added`
- On the big screen the control lives in the rail, in the room tile's place while waiting, not in the play area under the pills: the play area at 1280×800 has no height left for another row beside the hero, the pills and Start game
- The disabled reason reads "Room full", the plain words for "every color taken"
- On the player screen the control sits right under the roster, before the invite, so the bot appears next to the control that added it
- The host-alone line "Waiting for more players to join…" is drawn as plain secondary text centred in the 56px I'm ready slot (board 3); the built `waiting-p-1` look wins if it differs
- The 1280×800 big screen (board 1) draws the waiting state smaller than 1920: room code 80px, hero text 24px and 20px, pills 24px with 16px dots, Start game 80px tall, rail rows 52px (padding 8px 16px, 36px scores, 6px gaps) so 8 rows fit under the add-bot tile and clear the settings button

## Open questions

- At 1280×800 with 8 players, the rail as the existing boards draw it (152px room tile, 60px rows, 8px gaps) is about 760px tall and runs under the 56×56 settings button, in play as well as waiting. Board 1 draws 52px rows to fit; the build should check what the code does at 1280 and keep the rail clear of the settings button

## Artboards added or changed

Added in a new row under the title note "11 · Bots · add-bot control and bot mark (ticket 47)", below the error pages. No existing board changed. Each board is self-contained: WaitingTh, PlayPortraitTh, GameOverTh and BigScreenTh are unchanged, since a new prop on them could not be checked against the boards that import them.

- `bot-big-waiting8-light.dc.html`: big screen, waiting, 1280×800, light. Ana, Ben, Chloé, Dev, Eli, Easy bot, Easy bot 2, Hard bot; "6 of 8 ready"; Start game enabled; add-bot control disabled, "Room full"
- `bot-big-botsonly-dark.dc.html`: big screen, waiting, 1920×1080, dark. Easy bot and Medium bot, both ✓; Start game disabled, "Need a person to play"; add-bot control enabled, Easy focused
- `bot-waiting-p-alone-light.dc.html`: player screen, waiting, portrait, light, host alone; "Waiting for more players to join…"; add-bot control enabled, Easy focused
- `bot-waiting-p8-dark.dc.html`: player screen, waiting, portrait, dark, host, 8 players with 3 bots; "Ready ✓ · waiting for 2 more"; add-bot control disabled, "Room full"; no page scroll
- `bot-waiting-l7-dark.dc.html`: player screen, waiting, landscape, dark, host, 7 players with 2 bots, before voting; add-bot control enabled; no page scroll
- `bot-waiting-c7-light.dc.html`: player screen, waiting, computer, light, as board 5; no page scroll
- `bot-play-p8-other-dark.dc.html`: player screen, play, portrait 8/18, dark, someone else claiming: Hard bot's chip solid yellow with a `gray-950` mark, the status panel "Hard bot [mark] is calling SET!", the other bots' chips with the mark
- `bot-big-claiming-light.dc.html`: big screen, playing, 1920×1080, light, Claiming band "Hard bot [mark] is calling SET!" with the ring at 9; Hard bot's rail row solid yellow; the other bots' rows with the mark
- `bot-gameover-p-light.dc.html`: player screen, game over, portrait, light; viewer Ana 2nd; "★ Hard bot [mark] wins with 9"; 8 standings rows, 3 bots, ranks 1, 2, 3, 3, 5, 6, 7, 8; Play again
- `bot-big-ended-dark.dc.html`: big screen, ended, 1920×1080, dark; "Game over", "Hard bot [mark] wins"; podium Ana #2, Hard bot #1 ★, Easy bot #3; Play again
