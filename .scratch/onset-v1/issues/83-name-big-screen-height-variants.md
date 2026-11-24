# 83: Behind the scenes: name the big screen's height variants by what they mean

Status: needs-triage
Kind: behavioural
Blocked by:
Priority:
Feature:
Model:
Effort:
Changelog:

## Request

Deferred from 72. Behind the scenes: name the big screen's height variants by what they mean, before another step joins them. `app/assets/tailwind/application.css` defines `short` (under 1000px tall, ticket 67's rail) and `snug`, `tight`, `compact` and `cramped` (under 1080, 920, 820 and 740px, ticket 72's play area). The names give neither their order nor their threshold, `short` falls between `snug` and `tight`, and the comment on `short` says the rail "takes the compact sizes" though `compact:` is another step. Rename the five by threshold, or by one clear order, across their 30 uses in `app/views/games/` (`_board`, `_scoreboard`, `_start_button`, `_room_tile`, `show`), correct the comment, and name ticket 71's under-800px rail step the same way, whichever is built first. No size changes.

Conflicts with: 71

## Comments

Decided: filed alongside ticket 71 rather than merged into it, because 71 adds the under-800px rail step and this renames every step, which the request already orders "whichever is built first". Instead of: merging the rename into 71.
