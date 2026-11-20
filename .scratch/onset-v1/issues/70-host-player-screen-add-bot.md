# 70: The host adds bots from their own player screen

Status: ready-for-agent
Kind: visual
Blocked by: 68
Priority: normal
Feature: AI opponent
Model:
Security: yes
Effort:
Changelog:

## Request

Split from 47 (AI opponent the host can add from the lobby): the add-bot control on the host's own waiting player screen, so a person alone can add a bot with no big screen, found through `host_player_id`.

## Spec references

- SPEC.md, AI opponent > Adding a bot (Who, Levels, Accessible names, Telemetry)
- SPEC.md, Shared: 4. Data Model > `Game` (`host_player_id`), `Player` Methods (`host?`)
- SPEC.md, 8. Join page (joining from the host browser records `host_player_id`, granting nothing else)
- SPEC.md, 8. Player screen (1. Waiting: the add-bot control on the host's own screen, the no-page-scroll sizes)
- SPEC.md, Shared: 7. Realtime > Hooks that must survive any markup change (`#controller_status`)
- SPEC.md, Shared: 17. Telemetry > Custom events (`bot_added` from the host's player screen)
- docs/design-system.md v8: Components > Add-bot control (Player screen, Focus, Disabled); Screens > Player screen, Waiting (Host's screen, Host alone)
- Boards (canvas in docs/design-handoff.md, row "11 · Bots"): bot-waiting-p-alone-light, bot-waiting-p8-dark, bot-waiting-l7-dark, bot-waiting-c7-light

## Scope

- **`host_player_id`**: set when a player joins from the browser holding the room's `host_game` cookie; a later join from that browser points it at the newer player. It only decides which player screen shows the control: `POST /games/:code/bots` still checks the cookie (ticket 68). This replaces ticket 08's "the creator is not the host player" expectation, which SPEC §4 and §8 Join page now reverse
- **The control on the host's waiting screen**: one row right under the roster, before the invite, as DESIGN v8 draws it in portrait, landscape (in the roster column) and computer (inside the roster panel): "Add a bot" in a fixed label column, then Easy, Medium and Hard. Each tap posts one add at that level (68's route) and sends `bot_added` with the level. Disabled with "Room full" under the label when every color is taken, tied by `aria-describedby`. Group and button accessible names per SPEC Adding a bot
- Rendered inside `#controller_status` from `host_player_id`, never from the viewer's cookie, since the partial is rendered for broadcasts with no request; so it appears, disables and goes with each room update and is gone once play starts
- Other players' screens show no add-bot row: the roster runs straight into the invite
- Must not touch: the add route and its rules (68), the bots' play (69), removing a bot (48), the big screen

## Acceptance criteria

- A player who joins from the host browser becomes the room's `host_player_id`; a player joining from any other browser does not change it
- The host's waiting player screen shows the add-bot row under the roster in portrait, landscape and computer; no other player's screen shows it
- Alone in the room, the host taps Easy and "Easy bot" appears in the roster with its mark and ✓, and I'm ready replaces "Waiting for more players to join…", with no reload and no big screen open
- With every color taken the three buttons are disabled and "Room full" shows under "Add a bot", with `aria-describedby` pointing to it
- Once play starts the row is gone
- A request to add a bot from a browser without the `host_game` cookie still answers `403`, even from the player that `host_player_id` names (the cookie is the check, not the column)
- With 8 players in portrait, and 7 in landscape and computer, the host's waiting screen has no page scroll at 375×667, 667×375 and 1024×640, with the invite and the add-bot row
- A tap sends `bot_added` with its level
- In both themes the row takes DESIGN v8's values (spot checks: the raised buttons, the disabled gray, the focus outline)

## Verification

`bin/test-all && bundle exec standardrb`

Tests first:

- Request specs for joining: from the host browser sets `host_player_id`, from another browser leaves it (replace the spec that expects the creator not to be the host player)
- View or request specs that `#controller_status` renders the row for the host player only, disabled at 8 players
- System specs: the host alone adds a bot from the player screen; the no-page-scroll sizes in the three layouts

## Out of scope

- Remove controls on roster rows (48)
- Any other host power on the player screen (Start game, Play again stay the big screen's)
- Changing the add route, its checks or its limits (68, 62)

## Comments

Decided: split from 47 as its third child, blocked by 68, because it reuses 68's route and rules and only adds the player screen's place for the control. Instead of: folding it into 68, which would not fit one session with the play rules.

Decided: Security yes, because it sets which player stands for the host browser, so who sees a host-only control, though the server's check stays the cookie. Instead of: no flag.

Decided: a later join from the host browser repoints `host_player_id` at the newer player, because the browser holds one player cookie, so its newest player is the screen the host is looking at. Instead of: keeping the first.
