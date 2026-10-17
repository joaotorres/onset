# 12: Spec update for devices-first play

Status: deployed
Kind: behavioural
Blocked by:
Model:
Effort:
Changelog: Behind the scenes: the spec describes playing on your own devices, with the big screen optional.

## Request

Spec: update §1, §5 and §8 for devices-first play and the new terms (ADR 0001)

ADR 0001 and GLOSSARY.md settled devices-first play, the big screen as an optional URL, and the terms "player screen" and "big screen" (code names unchanged).

## Spec references

- Intro and §1 Overview > What it is, Terms (devices-first, the big screen an optional URL any room can open at any time, the player screen meant to stand alone, the terms and the code names that stay)
- §8 Views & UX > Big screen (`/games/:code`) > Announcement band (empty while playing: "Spot a Set? Hit SET! on your screen."; No Set: "Agree on your screen, or find one first")
- Renamed, wording only: §8 headings Big screen, Join page and Player screen; §5 Routes purposes; §2 Round flow; §3, §4, §7 and §10 to §11 terms

## Scope

The spec change is committed. What is left for code is the big screen's announcement band, the two lines that still say "on your phone": the idle line while playing with no claim and no No Set call, and the No Set panel's second line. Confirmed by code path: both live in the `games/_announcement` partial and no spec covers either string today.

Touch only those two strings and the request specs for the big screen page. Do not rename any route, controller, partial, id or Stimulus controller.

## Acceptance criteria

- `GET /games/:code` while playing with no claim and no No Set call shows "Spot a Set? Hit SET! on your screen."
- `GET /games/:code` while a No Set call is active shows "Agree on your screen, or find one first"
- Neither page contains "on your phone"

## Verification

`bundle exec rspec`

Write first: request specs in `spec/requests/games_spec.rb` for `GET /games/:code` in the idle playing state and with a No Set call active, asserting the new lines and the absence of "on your phone".

## Out of scope

- The landing page copy, including the tagline and "This screen becomes the board" (ticket 08)
- The how-to-play page, which SPEC does not cover
- What the player screen shows without a big screen, its computer layout (ticket 09) and its waiting-room invite (ticket 10)
- Renaming code: `ControllersController`, the `controller` route, `#controller_status`, `#board`, the `board` column (ADR 0001)
- Any other text on the big screen or the player screen

## Comments

Decided: overlaps 08 to 11, which each change the spec for their own behaviour under gate 1; this one owns §1, the terms across the spec and whatever of §5 and §8 they leave. Instead of: merging into 08.

Decided: §8 headings renamed to Big screen, Join page and Player screen, and the Spec references of open tickets 02 to 06 and 11 updated to match, because the old headings used terms the glossary avoids and a builder looks headings up by name. Instead of: keeping "Board", "Phone join" and "Phone controller" as headings.

Decided: §8 Landing left as it is, because ticket 08 rewrites it. Instead of: renaming "This screen becomes the board" here.

Decided: §15 Implementation plan left in the old terms, because it records how v1 was built. Instead of: rewriting history.

Decided: §5 `/games/:code` reads "Big screen, optional: any room can open it at any time", which the code already allows (`GamesController#show` has no status guard). Instead of: a big screen vs devices mode on the game, which ADR 0001 rules out.

Decided: the big screen's two "on your phone" lines say "on your screen", because players may be on computers and "your screen" reads naturally on a TV. Instead of: "on your player screen", which is glossary-correct but stiff in copy.
