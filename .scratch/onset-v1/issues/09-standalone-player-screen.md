# 09: Player screen stands alone, computer layout

Status: needs-triage
Kind: visual
Blocked by:
Model:
Effort:

## Request

Devices-first: player screen stands alone (all scores, deck count, newly dealt outline, found-Set and No Set announcements), computer layout via the design pass

Without a big screen the player screen carries what only the big screen shows today: every player's score, the deck count or "Deck is empty", the green outline on newly dealt cards, who found which Set with its cards, who is calling SET!, and the No Set agreement count. On a computer it gets a board-sized layout: a large clickable card grid, scores in a side panel, the actions beside them. The exact layout comes from the design pass. Keyboard shortcuts (Space for SET!, N for No Set) are deferred.

## Comments

Decided: overlaps 06 (tapping a card calls SET!) for the clickable grid; filed as its own ticket, 06 owns the tap behaviour and this one the layout. Instead of: merging into 06.

Design gap: SPEC §8 "Phone controller" assumes a big screen shows the cards. In portrait while idle the player screen shows no cards (only SET! and No Set), so with no big screen a portrait phone player cannot see the board: must portrait show the board while idle, and where do SET! and No Set go then? Which scoreboard fields the player screen shows (§8 "Board": sorted by score, claiming row yellow, Locked tag) and where in portrait and landscape. Which big screen announcements move over (§8 "Announcement band": claiming, No Set, correct with cards, wrong or time's up of other players) and the deck count or "Deck is empty" pill. Whether `last_dealt`'s green outline (§10 `animate-arrive`) shows on the player screen. What width or input counts as "computer" for the board-sized layout, versus phone landscape.

Decided: SPEC §8 Player screen shows the board in every playing state and layout; portrait puts the scoreboard across the top, the board under it at full width, and the state's panel, SET! and its pill at the bottom, because ADR 0001 says the player screen carries the board and §8 keeps SET! under the thumb. Instead of: portrait idle with no cards, or the board behind a toggle.

Decided: the scoreboard lists every player in score order, ties in join order, as dot, truncated name and score, the claiming entry yellow, a locked-out entry greyed with a red Locked tag and the own entry surface-tinted; it shows during play only, waiting and game over keeping the header, because those are the big screen scoreboard's rules and ticket 07's own-row tint, and the waiting roster and game over standings already list everyone. Instead of: only the player's own score, or a player-color own entry.

Decided: the claiming, No Set and found-Set announcements stay as the player screen already shows them, the No Set n/m agreed count now in landscape too, and other players' wrong claims and time's ups show only through the scoreboard's Locked tag and score, because the request lists the announcements it wants and a banner per wrong claim would cover the board. Instead of: a red banner for every wrong claim.

Decided: "N cards left in the deck", or an orange "Deck is empty" pill, sits with the board in every layout and state, in the big screen's words, because the End game vote's "Deck empty" line only shows in idle and locked out. Instead of: the End game vote line alone.

Decided: the player screen board carries the §10 animate-arrive green outline on last-dealt cards in every state that shows the board, because the request lists it and the token exists. Instead of: big screen only.

Decided: the computer layout is the viewport at 1024px wide and up (Tailwind lg:), in either orientation and whatever the input, because phones in landscape stay under 1000px wide and keyboard shortcuts are deferred, so the input changes nothing yet; a landscape tablet gets the board-sized layout too. Instead of: a pointer or hover media query.

Decided: tapping a card while idle calls SET! in every layout, SPEC §2 and §7 updated to match, because ticket 06's request applies it wherever the board shows while idle; 06 keeps its landscape scope and its spec references were renamed, and this ticket's build covers portrait and computer, so it will be blocked by 06. Instead of: a read-only portrait board while idle.

Decided: no page scroll with 8 players and 18 cards at 375×667 portrait, 667×375 landscape and 1024×640 computer in every state, cards shrinking to fit and portrait fitting the scoreboard in at most two rows, because §8 bars page scroll and 8 preset colors cap a room at 8 players, as ticket 07 set its sizes. Instead of: page scroll or a capped scoreboard.
