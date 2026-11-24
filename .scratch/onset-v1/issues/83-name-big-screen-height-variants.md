# 83: Behind the scenes: name the big screen's height variants by what they mean

Status: ready-for-agent
Kind: behavioural
Blocked by: 71
Priority: low
Feature: Page layout
Model:
Effort:
Changelog:

## Request

Deferred from 72. Behind the scenes: name the big screen's height variants by what they mean, before another step joins them. `app/assets/tailwind/application.css` defines `short` (under 1000px tall, ticket 67's rail) and `snug`, `tight`, `compact` and `cramped` (under 1080, 920, 820 and 740px, ticket 72's play area). The names give neither their order nor their threshold, `short` falls between `snug` and `tight`, and the comment on `short` says the rail "takes the compact sizes" though `compact:` is another step. Rename the five by threshold, or by one clear order, across their 30 uses in `app/views/games/` (`_board`, `_scoreboard`, `_start_button`, `_room_tile`, `show`), correct the comment, and name ticket 71's under-800px rail step the same way, whichever is built first. No size changes.

Conflicts with: 71

## Spec references

No spec change: nothing a user sees changes. SPEC.md, 8. Big screen (`/games/:code`), the Scoreboard bullet (the rail's shrink under 1000px and 800px tall) and the Fit bullet (the play area's shrink with the window's height) already decide every size this ticket keeps.

## Scope

Today `app/assets/tailwind/application.css` declares five height variants, each a `@custom-variant <name> (@media (max-height: <N-1>px))`: `short` (under 1000, the rail, ticket 67), `snug`, `tight`, `compact` and `cramped` (under 1080, 920, 820 and 740, the play area, ticket 72), used about 30 times in `app/views/games/` (`_board`, `_scoreboard`, `_start_button`, `_room_tile`, `show`). Ticket 71 adds an under-800px rail step before this builds.

- **Rename every height variant by its threshold**, `h-under-<N>` for `max-height: <N-1>px`: `h-under-1080`, `h-under-1000`, `h-under-920`, `h-under-820`, `h-under-740`, and ticket 71's under-800px step as `h-under-800`, plus any other height variant an earlier build added by then. Every use in `app/` changes with it, whatever ticket added it (48, 68, 73 may add uses before this builds)
- Declare them in one block, tallest threshold first, so a shorter step always wins over a taller one on the same property; confirm first that no element today relies on the old declaration order (`short` sits before `snug` now: no element uses both, as the triage found)
- One comment over the block: these are max-height steps named by the height they start under, the rail (SPEC §8 Big screen, Scoreboard) and the play area (SPEC §8 Big screen, Fit) each using the steps it needs. Drop the comment's "takes the compact sizes", which named another step
- No size, class value or markup change beyond the variant names. Keep every hook and its `data-version` (SPEC §7 Hooks)
- Must not touch: the `light` variant and the theme block, any width breakpoint, the card grid's size formula, the player screen, SPEC, the design system

## Acceptance criteria

- `application.css` declares no height variant named other than `h-under-<N>`, and each one's media query is `max-height: <N-1>px`
- No file in `app/` uses `short:`, `snug:`, `tight:`, `compact:` or `cramped:` (nor ticket 71's own name for its step) as a variant
- The height variants are declared tallest threshold first
- Every existing big screen rail and fit spec passes unchanged (`spec/system/big_screen_fit/`, `spec/system/big_screen_theme/rail_fit_*`, `spec/system/big_screen/layout_spec.rb`, ticket 71's specs): no size moved

## Verification

`bin/test-all && bundle exec standardrb`

Tests first, one fast non-system spec (for example `spec/assets/height_variants_spec.rb`) that reads `app/assets/tailwind/application.css` and the files under `app/views/`:

- every `@custom-variant` with a `max-height` query is named `h-under-<N>` with N one more than its max-height, and they come in descending N: red today
- no view uses one of the old names as a variant (`short:`, `snug:`, `tight:`, `compact:`, `cramped:`, and 71's name): red today
- the existing rail and fit system specs then prove no size changed; edit none of them

## Out of scope

- Any size change, or a new height step
- Width breakpoints, or moving the variants into a config of their own
- Renaming anything outside the height variants (classes, hooks, partials)

## Comments

Decided: filed alongside ticket 71 rather than merged into it, because 71 adds the under-800px rail step and this renames every step, which the request already orders "whichever is built first". Instead of: merging the rename into 71.

Decided: the conflict with 71 is settled by blocking this on 71, so 71 builds its under-800px step under a name of its own and this rename covers all six steps at once, because the two do not disagree on any behaviour, only on order, and 71 (high) would build first anyway. Instead of: rewriting 71's brief to use the new names, or asking which wins.

Decided: the variants are named by threshold, `h-under-<N>` for `max-height: <N-1>px` (h-under-1080, h-under-1000, h-under-920, h-under-820, h-under-800, h-under-740), because a name that carries its number gives both the order and the threshold and leaves room for any later step; `h-` names the dimension, and a `max-h-` prefix would read as Tailwind's own `max-h-*` utility and `max-*` variants. Instead of: a word scale (tall, short, shorter), which a new step breaks again.

Decided: declared tallest first in one block, because with max-height queries a later declaration wins, so the shorter step must come last; triage found no element using both `short:` and `snug:`, so moving `short` after `snug` changes no size. Instead of: keeping today's order, with `short` before `snug`.

Decided: a fast spec that reads the CSS and the views guards the names, because a rename changes no size and the existing fit specs alone would stay green before the change. Instead of: relying on the system specs only.

Decided: no spec change, because nothing a user sees changes; SPEC §8 Big screen, Scoreboard and Fit already decide the sizes. Instead of: a spec note on the variant names.

Decided: Priority low, Feature Page layout (the parent's, 72), Model empty and no Security line, because it is a behind-the-scenes CSS rename with no shared logic and no auth. Instead of: normal.
