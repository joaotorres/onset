# 03: Join from this computer link on the big screen

Status: ready-for-agent
Kind: behavioural
Blocked by: 02
Model:
Effort:

## Request

Big screen: "Join from this computer" link under the QR, opens the join page in a new tab

For someone playing from the same computer as the big screen, and for testing. A browser holds one player (one `player_token` cookie), so testing several players still needs a private window or a second browser. No cookie change.

## Spec references

- §8 Views & UX > Big screen (`/games/:code`) > Waiting (a **Join from this computer →** link under the hero QR opens the join page in a new tab; one player per browser)
- §5 Routes (`GET /games/:code/players/join`, the link's target, unchanged)

## Scope

Confirmed by code path: the waiting branch of the `games/board` partial renders the hero QR tile with the hero text beside it and no link anywhere; the join page (`PlayersController#join`) renders the name and color form for any browser, so opening it in a new tab from the big screen works today with no server change.

Touches only the waiting hero in the `games/board` partial: a link under the white QR tile. The link reuses the existing text-link style (the "New to Set? How to play →" link on the landing page and player screen: semibold `text-blue-400`, `hover:text-blue-300`), sized up for the big screen. Must not touch the join page, `PlayersController`, the `player_token` cookie, the QR helper, the hero text, the `#board`/`#start_button` ids and other §7 hooks, or the playing and ended states.

## Acceptance criteria

- `GET /games/:code` for a waiting game renders a link with the text "Join from this computer" whose `href` is that game's `/games/:code/players/join`, with `target="_blank"` and `rel` including `noopener`
- For a playing game and for an ended game the page renders no such link
- The waiting board broadcast (the `#board` replacement sent when a player joins or votes ready) still carries the link, so it survives live updates
- At a 1280x800 window on a waiting game the link sits below the QR tile, is no wider than the QR tile, stays on one line, and the hero text and room code still end left of the rail (ticket 02's bounding-box check still passes)
- Following the link and submitting the form in the new tab creates a player and lands on the player screen, and the big screen shows the new player pill without a reload

## Verification

`bundle exec rspec`

Write first: request specs in `spec/requests/games_spec.rb` for the link (text, `href`, `target`, `rel`) on a waiting game and its absence on playing and ended games. Extend the 1280x800 system spec ticket 02 adds with the link's bounding box: top below the QR tile's bottom, width at most the QR tile's width, a single line.

## Out of scope

- Any cookie change, multiple players per browser, or a "switch player" control
- Redirecting a browser that already holds a player in this room away from the join page
- A copy or share link, or a QR on the player screen (ticket 10)
- The reverse link from the player screen to the big screen (ticket 10)
- Renaming other big screen text to "big screen" / "player screen" (ticket 12)

## Comments

Decided: the link reuses the existing text-link style ("New to Set? How to play →": semibold blue-400) at big screen size, labelled "Join from this computer →", so Kind stays behavioural. Instead of: Kind visual and a design pass for a new link component.

Decided: blocked by 02, because both rewrite the same waiting hero and 02's 1280px system spec is the check this link must keep passing. Instead of: building both in parallel against the same partial.

Decided: the link sits under the QR, inside the QR tile's width, and shows only while waiting, because the request places it there and late joining is blocked once play starts. Instead of: a line in the hero text column, or keeping it during play.

Decided: the link opens with `target="_blank"` and `rel="noopener"`, because the request asks for a new tab and the big screen must keep running. Instead of: same-tab navigation.
