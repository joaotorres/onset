# Changelog

What each deploy shipped, newest first, from the tickets' Changelog: lines.

## 2026-11-25, deploy-20261125-1633

- The host can add Easy, Medium and Hard bots to a waiting room from the big screen; they show in the room with a bot mark and count as ready, but do not play yet. (68)
- A join that loses a split-second race for a color now comes back with the next free color picked, or says the room is full when that was the last one. (74)
- A locked-out player's name and score on your phone's scoreboard are now easy to read in both themes. (76)
- Going Back to Onset from another site now shows the theme and card colors you picked meanwhile in another tab, with the settings menu closed. (77)
- Your theme and Color-blind picks now last a year on iPhone and Safari too, instead of lapsing after a week. (78)
- An error page you come back to with Back or Forward shows the theme you picked meanwhile, or follows your device again. (87)
- Behind the scenes: the ready, Start game and Play again limits are checked before the room is looked up, and the in-game limits gain specs for broadcasts and cookie-less counts. (79)
- Behind the scenes: the theme and big screen fit tests now check the Game mode toggle itself, the light name error border, and the join link and QR size at every window. (80)
- Behind the scenes: the spec names every answer a screen action can get, says a late submit is judged against the room's current claim, and the design system gives the tray slot number its built 24px. (82)
- Behind the scenes: the theme specs share one set of cookie, color, meta and no-reload helpers. (84)
- Behind the scenes: the rate limit and stale claim spec helpers each live in one place. (85)
- Behind the scenes: specs build their players with one helper that takes the room's next free color. (86)

## 2026-11-20, deploy-20261120-1251

- The error pages (such as page not found) now use Onset's own light and dark colors, following your device or the theme you picked in Onset. (42)
- In the dark theme, faint gray text and the borders of the room code and name fields are easier to read. (46)
- On a big screen 800 to 999px tall, such as a 1280×800 or 1440×900 laptop, all 8 players show in the Players list, clear of the settings button. (67)
- On the big screen, the waiting room's room code, QR code and player pills and the game-over podium now shrink to fit shorter windows, down to 1280×720, with the QR code never under 160px. Eight players with long names can still run past the bottom of the waiting room. (72)
- Behind the scenes: the server now refuses a join that does not take one of the 8 player colors still free, so a script can no longer push a room past 8 players. (54)
- Behind the scenes: the spec's list of markup hooks names everything the settings menu, invite, card picking, countdown and telemetry controllers rely on. (58)
- Behind the scenes: the player screen no longer computes an unused copy of the claim. (59)
- Behind the scenes: a script sending game actions far faster than anyone can tap is now refused for the rest of the minute, without slowing the table. (60)
- Behind the scenes: the database itself now refuses two players with the same name in one room, a guard behind the join page's own check. (61)
- Behind the scenes: the static error pages write their theme colors once as CSS variables, and their specs follow the app's theme colors. (63)
- Behind the scenes: specs now cover the dark theme's disabled labels and borders and the light theme's muted text, and the theme spec helpers are shared. (64)
- Behind the scenes: the design system's quote of the SPEC visual system matches SPEC again. (65)
- Behind the scenes: the spec's list of routes names every answer a screen action can get besides "no content", and points to the rate limits. (66)

## 2026-11-19, deploy-20261119-1509

- Escape now closes the open settings menu even after a click on its blank space. (51)
- A theme or card colors picked in another tab now show on the next page you open by a link or Back, not only after a reload. (52)
- A late or repeated Start game or Play again tap no longer reshuffles a running game or wipes the scores. (55)
- A SET! call still running when the game ends can no longer reopen the game or change the scores; an End game tap during a call does nothing, so tap it again once the call is judged. (56)
- Behind the scenes: the card palette, the color marks and the theme colors are each written in one place, which the cards and the settings menu read. (50)
- Behind the scenes: the design system matches what is built, and tests cover the browser color after a theme pick, the settings menu closed after Back and the tray slot's card edge. (53)
- Behind the scenes: the glossary defines the current claim and says only it is ever judged. (57)

## 2026-11-16, deploy-20261116-1720

- The How to play page uses its full 944 px for content, with the side padding outside it, and its running text is capped to a comfortable line length. (39)
- Cards now come in Set's classic red, green and purple, and a Color-blind option in Settings switches them to blue, orange and magenta with a small mark in two corners that tells the colors apart. (41)
- The landing, the join page and How to play now come in a light theme too, following your device or your pick in a new settings menu. (43)
- The player screen comes in a light theme too, following your device or your pick in the settings menu, which opens from a button by the room code; the greyed-out No Set button is easier to read. (44)
- The big screen has a settings button in its bottom-right corner and a light theme for every state. (45)
- Behind the scenes: the design records now match where the built settings menu opens and its size, and system specs pin where it opens. (49)

## 2026-10-25, deploy-20261025-1730

- Starting a game no longer leaves the big screen or a player screen stuck on the waiting state when two updates arrive out of order. (34)
- The waiting roster and player count no longer fall one join behind when two players join at once. (36)
- A Submit button lets you send your three cards as soon as they are picked, instead of waiting out the 15 seconds. (37)
- Behind the scenes: the comment on Player#seen! gives SPEC §7's reason for skipping callbacks, a heartbeat broadcast shows nothing new. (35)
- Behind the scenes: a Submit that never reaches the server now unfreezes the claiming screen even when a room update redrew it meanwhile. (38)

## 2026-10-21, deploy-20261021-2026

- Countdown rings show the same time left on every screen, even on a device whose clock is off. (32)
- Behind the scenes: the server logs how late a SET! call arrived when it loses the race to another player's claim. (33)

## 2026-10-19, deploy-20261019-2027

- Behind the scenes: the spec now describes the telemetry and its custom events, nothing changes for players. (31)

## 2026-10-17, deploy-20261017-1810

- Behind the scenes: tests now cover where the How to play Back link goes, and a variable got a clearer name. (29)
- Behind the scenes: the How to play page names its player screen link more clearly in the code. (30)

## 2026-10-17, deploy-20261017-0058

- Behind the scenes: spec wording fixes, nothing changes for players. (27)
- Behind the scenes: the spec now describes the How to play page's Back link, nothing changes for players. (28)

## 2026-10-16, deploy-20261016-0229

- The byline no longer makes the landing, How to play and join pages scroll. (26)
- Behind the scenes: the spec and glossary give the right claim and lockout times and say who can refuse a No Set call. (25)

## 2026-10-16, deploy-20261016-0139

- Any player can refuse a No Set call once per board, and after a refusal nobody can call No Set for 15 seconds. (21)

## 2026-10-16, deploy-20261016-0106

- Picking a third card no longer submits right away: you can change your picks until the claim time runs out, and they are judged then. (19)
- After a wrong or timed-out claim you are locked out for 15 seconds, as long as a claim lasts. (20)
- On a computer, the room code sits right under the cards, lined up with them. (22)
- Cards you pick during a claim stay picked when the screen redraws. (23)
- The landing, How to play and join pages have a "by joaotorr.es" byline at the bottom. (24)

## 2026-10-12, deploy-20261012-2206

- On a narrow desktop window, the landing's example cards no longer cover the start game form. (18)

## 2026-10-12, deploy-20261012-2151

- Striped cards keep their stripes on a computer after you tap a card. (01)
- The big screen shows one QR code, only while waiting, and the room code fits on a laptop screen. (02)
- The big screen has a "Join from this computer" link that opens the join page in a new tab. (03)
- The join form picks the first free color for you. (04)
- SET! stays on top of the player screen in every state, the No Set countdown included. (05)
- Tapping a card on the player screen while nobody is claiming calls SET! and picks that card. (06)
- The player screen's game over shows the full standings, with your row highlighted. (07)
- The landing has one "Start a game" button with a standard or first-to-5 choice, and takes you to your own join form, with the option to use that screen as the big screen instead. (08)
- The player screen's waiting room lets you invite others with the room code, a link to copy or share, a QR code and a "Show on a big screen" link. (10)
- Play again on the player screen is a vote: the game restarts once every player has voted. (11)
- How to play explains that everyone plays on their own phone or computer, with the big screen optional. (13)
- In portrait, the player screen shows the whole game during play: every player's score, the board and the deck. (14)
- In landscape, the player screen shows the board, every player's score and SET! side by side, with no sideways scroll. (15)
- On a computer, the player screen shows a board-sized layout, with the scores and SET! in a side column. (16)
- The big screen's Start game and Play again buttons are a darker green, so their white text is easier to read. (17)
- Behind the scenes: the spec describes playing on your own devices, with the big screen optional. (12)
