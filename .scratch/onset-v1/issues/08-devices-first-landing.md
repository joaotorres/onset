# 08: Devices-first landing and creator join

Status: deployed
Kind: visual
Blocked by:
Model:
Effort:

## Request

Devices-first: landing has one "Start a game" plus the standard / first-to-5 toggle, leading to the creator's join form with "Use this screen as the big screen instead"

Settled while grilling (ADR 0001): devices-first is the default. "Start a game" creates the room and opens the creator's join page (name and color). Its secondary action, "Use this screen as the big screen instead", leads to today's `/games/:code`. The separate "Start quick game" button becomes a standard / first-to-5 toggle above "Start a game".

Every game is the same: no big screen vs devices mode is stored on the Game. The big screen is a URL any room can open at any time, even mid-game. User-facing text says "player screen" and "big screen" (GLOSSARY.md); code names stay.

## Spec references

- §8 Views & UX > Landing (`/`) (the toggle, one Start a game, its sub-line, the tagline, Room not found, the phone order)
- §8 Views & UX > Join page (`/games/:code/players/join`) (the creator's page, the big screen link for the `host_game` browser, host stays with the browser, the full room)
- §5 Routes: `POST /games` (`mode=quick`, `host_game` cookie, redirect to the join page), `GET /join?code=`
- §4 Data Model > `Game`: `host_player_id` unused
- §1 Overview > Terms (user-facing text says "player screen" and "big screen")
- §10 Cards and visual system > Visual system (surfaces, the meaning table: `blue-600` primary, `violet-600` quick game)
- docs/design-system.md v2: Components > Landing mode toggle, Screens > Landing (ticket 08), Screens > Join page (ticket 08), Changelog v2 ticket 08. Boards per `docs/design-handoff.md`: Main, landing-phone, landing-phone-quick, landing-phone-notfound, landing-desktop-quick, landing-desktop-notfound, Join, join-creator, join-name-blank, join-taken, join-started, join-full

## Scope

`GamesController#create` (redirect only), `LobbiesController#join` (the alert text), `app/views/lobbies/new.html.erb`, `app/views/players/new.html.erb`, and `PlayersController` only to expose whether this browser holds the room's `host_game` cookie and whether the room is full. Specs in `spec/requests/games_spec.rb`, `spec/requests/lobbies_spec.rb`, `spec/requests/players_spec.rb`, plus any system spec that follows the old `POST /games` redirect to the big screen.

Do not touch: the `Game` and `Player` models and the schema (`host_player_id` stays as is), `host_game` cookie checks in `start` and `restart`, the big screen (`games/*`, its "Join from this computer →" link included), the player screen, `lobbies/how_to_play` (ticket 13), the color pick and re-render logic of ticket 04 beyond the full room, rate limits.

## Acceptance criteria

Landing:
- One form posts to `/games` with a two-radio toggle named `mode`: **Standard** (value `standard`, checked by default) and **First to 5** (value `quick`, label from `Game::QUICK_WIN_SCORE`), styled as the design system's segmented control, with no JS. Selected Standard is `gray-700`, selected First to 5 is `violet-600`
- The form has one **Start a game** button (`blue-600`) with the sub-line "Play from this screen, then invite the others". "Start quick game" and "This screen becomes the board" are gone
- Submitting with First to 5 creates a `quick` game, with Standard a `standard` game
- The tagline reads "Set, played live in the room. Everyone plays on their own screen, and a big screen is optional." No user-facing "phone", "controller" or "TV" on the page
- Desktop (`md:` and up): brand left (wordmark, tagline, fanned cards, caption), actions right in a 448px `gray-900` card with a `gray-800` border: toggle, Start a game and sub-line, a divider, "Have a room code?", the code field and a `gray-800` Join button
- Phone: wordmark and tagline, the join form, a divider, the toggle and Start a game, then the fanned cards and caption
- The "New to Set? How to play →" link stays
- An unknown code redirects to `/` with the alert exactly "Room not found", shown in `red-400` under the code field, the field empty with a `red-500` border. No "on the big screen" text

Start a game:
- `POST /games` sets the `host_game` cookie and redirects to `/games/:code/players/join`, no longer to `/games/:code`

Join page:
- "Joining room" in `gray-400` over the code at 60px in display type, for the creator and every other joiner alike
- When this browser's `host_game` cookie matches the room, a `blue-300` text link "Use this screen as the big screen instead" sits under Join and links to `/games/:code` with no `target`. Without the cookie, or with another room's, the link is absent
- Joining from the creator's browser does not set `Game#host_player_id`
- Base errors (game already started, rate limit, full room) show in a `red-950` box with a `red-700` border and `red-200` text, under the code. Field errors stay `red-400` under their field with a `red-500` field border
- Taken swatches show the preset blended 30% over `gray-950` with the taker's initial in `gray-300` display type, the initial not faded
- Join is `blue-600`, 56px tall, at the bottom
- With all 8 presets taken: no swatch is selected, the base error box says "This room is full" and Join is `disabled`, `gray-800` with `gray-500` text. The server still rejects a posted player as today

## Verification

`bundle exec rspec`

Write first:
- `spec/requests/games_spec.rb`: `POST /games` redirects to `join_game_players_path(code)` and still sets `host_game`; `mode=quick` and `mode=standard` (and no mode) give the right mode
- `spec/requests/lobbies_spec.rb`: `GET /` has one Start a game form with the two `mode` radios, Standard checked, the new sub-line and tagline, and no "Start quick game", "This screen becomes the board", "phone", "controller" or "TV" in the page text; an unknown code's flash is exactly "Room not found"
- `spec/requests/players_spec.rb`: the join page shows the big screen link to `game_path(code)` after `POST /games` from the same session, and not without it or with another room's cookie; joining as the creator leaves `host_player_id` nil; with every color taken the page says "This room is full" and the Join submit is disabled

## Out of scope

- Storing a big screen or devices mode on `Game`, or any migration
- Setting or using `host_player_id`, or moving hosting to a player
- A "Starting room" heading or any other creator-only copy beyond the link
- Live updates of taken colors on the join page
- Keeping the typed code after Room not found
- The player screen's "Show on a big screen →" invite link (ticket 10) and how to play copy (ticket 13)
- Changing the big screen's Start game or Play again colors (design-system Known gaps)

## Comments

Design gap: SPEC §8 "Landing" has two start buttons and "This screen becomes the board". Not decided: the toggle's labels and default (standard?), and whether the mode stays on `POST /games` as `mode=quick` (§5). The creator's join page: same as §8 "Phone join" or a different heading ("Starting room CODE")? Where "Use this screen as the big screen instead" sits on it, and that it opens the same room's `/games/:code`. Does the creator become the host (`host_player_id`, §4) when they join, and who is host on the big-screen path? What the big screen's room tile shows for "host" once there may be no host player.

Decided: SPEC §8 Landing puts a Standard / First to 5 toggle, Standard selected, above one Start a game button in the same no-JS form, and `POST /games` keeps `mode=quick` (§5), because the controller already reads that param and Standard is today's primary button. Instead of: First to 5 as default, or a new param.

Decided: Start a game's sub-line reads "Play from this screen, then invite the others" and the tagline says each player plays on their own screen with a big screen optional, because ticket 12 left Landing to this ticket and §1 bars "phone" in user-facing text. Instead of: keeping "This screen becomes the board" and the "cards go on the big screen" tagline.

Decided: the creator gets the same Join page, heading "Joining room" and code unchanged, with a "Use this screen as the big screen instead" text link under Join opening `/games/:code` in the same tab, because the request only adds that action and "instead" means leaving the form. Instead of: a "Starting room" heading or a new tab.

Decided: the link shows to the browser whose `host_game` cookie matches the room, also in a "Join from this computer" tab of that browser where it is harmless, because that cookie already marks the creator and needs no new param or column. Instead of: a `?creator` param or showing it to every joiner.

Decided: the creator does not become `host_player_id`; hosting stays with the creating browser's `host_game` cookie on both paths, as today, and §4 now says the column is unused, because start and play again are ready votes on player screens and the big screen's Start game and Play again already check the cookie. Instead of: setting `host_player_id` on the creator's join.

Decided: the big screen room tile is unchanged and §8 now says its "host" line is the site address (`join_host`), because the code shows the hostname there, never a host player. Instead of: adding or removing a host player line.

Decided: the 07, 08, 09, 10 brief draws every screen fresh on a new empty canvas and says the code is the truth for what it does not change, because the canvas has no boards to redraw. Instead of: first drawing the built landing, join page and player screen on the canvas from the code.

Design proposes: after a bad room code, the landing's code field comes back empty, red-bordered, with "Room not found" under it. Today's alert reads "Room not found. Check the code on the big screen.", and "on the big screen" no longer holds devices-first; §8 Landing says only "Room not found".

Design question: with every color taken the room is full and Join can only fail. Proposal: a base error "This room is full" and Join disabled. Drawn as §8 says for now (none selected).

Decided: on phones the landing runs wordmark and tagline, the join form, then the mode toggle and Start a game, the fanned cards and caption last, because §8's "join form comes first" ranks it ahead of Start a game and the wordmark still names the page. Instead of: the join form above the wordmark.

Decided: after an unknown code the alert reads exactly "Room not found" under an empty, red-bordered code field, written into SPEC §8 Landing, because "Check the code on the big screen" no longer holds devices-first and the design pass drew it so. Instead of: keeping the old alert text or refilling the typed code.

Decided: with every color taken the join page says "This room is full" in the base error box and disables Join, written into SPEC §8 Join page and docs/design-system.md, because the 8 unique preset colors cap a room at 8 and a Join that can only fail with a color error misleads. Instead of: today's form with nothing selected and no message, as the join-full board draws it.

Decided: the tagline reads "Set, played live in the room. Everyone plays on their own screen, and a big screen is optional.", because SPEC §8 Landing asks for that meaning in the §1 terms and it keeps today's first sentence. Instead of: new copy that drops "played live in the room".

Decided: no Blocked by, because 08 touches only the landing, `POST /games`'s redirect and the join page, which no open ticket builds. Instead of: blocking on 10 for the big screen wording.

Decided: the landing keeps today's card caption ("That's a Set: same number, same shading, every shape and color different.") over the board's new one, because the ticket changes only the tagline and the shown cards match today's caption. Instead of: the board's "number, color, shape and shading are each all different" caption.
