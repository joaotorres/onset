# 08: Devices-first landing and creator join

Status: needs-triage
Kind: visual
Blocked by:
Model:
Effort:

## Request

Devices-first: landing has one "Start a game" plus the standard / first-to-5 toggle, leading to the creator's join form with "Use this screen as the big screen instead"

Settled while grilling (ADR 0001): devices-first is the default. "Start a game" creates the room and opens the creator's join page (name and color). Its secondary action, "Use this screen as the big screen instead", leads to today's `/games/:code`. The separate "Start quick game" button becomes a standard / first-to-5 toggle above "Start a game".

Every game is the same: no big screen vs devices mode is stored on the Game. The big screen is a URL any room can open at any time, even mid-game. User-facing text says "player screen" and "big screen" (GLOSSARY.md); code names stay.

## Comments

Design gap: SPEC §8 "Landing" has two start buttons and "This screen becomes the board". Not decided: the toggle's labels and default (standard?), and whether the mode stays on `POST /games` as `mode=quick` (§5). The creator's join page: same as §8 "Phone join" or a different heading ("Starting room CODE")? Where "Use this screen as the big screen instead" sits on it, and that it opens the same room's `/games/:code`. Does the creator become the host (`host_player_id`, §4) when they join, and who is host on the big-screen path? What the big screen's room tile shows for "host" once there may be no host player.

Decided: SPEC §8 Landing puts a Standard / First to 5 toggle, Standard selected, above one Start a game button in the same no-JS form, and `POST /games` keeps `mode=quick` (§5), because the controller already reads that param and Standard is today's primary button. Instead of: First to 5 as default, or a new param.

Decided: Start a game's sub-line reads "Play from this screen, then invite the others" and the tagline says each player plays on their own screen with a big screen optional, because ticket 12 left Landing to this ticket and §1 bars "phone" in user-facing text. Instead of: keeping "This screen becomes the board" and the "cards go on the big screen" tagline.

Decided: the creator gets the same Join page, heading "Joining room" and code unchanged, with a "Use this screen as the big screen instead" text link under Join opening `/games/:code` in the same tab, because the request only adds that action and "instead" means leaving the form. Instead of: a "Starting room" heading or a new tab.

Decided: the link shows to the browser whose `host_game` cookie matches the room, also in a "Join from this computer" tab of that browser where it is harmless, because that cookie already marks the creator and needs no new param or column. Instead of: a `?creator` param or showing it to every joiner.

Decided: the creator does not become `host_player_id`; hosting stays with the creating browser's `host_game` cookie on both paths, as today, and §4 now says the column is unused, because start and play again are ready votes on player screens and the big screen's Start game and Play again already check the cookie. Instead of: setting `host_player_id` on the creator's join.

Decided: the big screen room tile is unchanged and §8 now says its "host" line is the site address (`join_host`), because the code shows the hostname there, never a host player. Instead of: adding or removing a host player line.
