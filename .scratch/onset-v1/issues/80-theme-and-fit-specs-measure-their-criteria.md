# 80: Behind the scenes: make the theme and fit specs measure what their criteria name

Status: deployed
Kind: behavioural
Blocked by:
Priority: low
Feature: Themes
Model:
Effort:
Changelog: Behind the scenes: the theme and big screen fit tests now check the Game mode toggle itself, the light name error border, and the join link and QR size at every window.

## Request

Deferred from 64. Behind the scenes: make the theme and fit specs measure what their criteria name. In `spec/system/dark_contrast/landing_and_join_spec.rb` the "Game mode toggle track" example reads `fieldset > div`, whose first match on the landing is the settings menu's Theme track (the menu renders before the form), so it passes whatever border the toggle has: scope it to the Game mode form, and check every other bare selector in the dark contrast, theme and fit specs for the same first-match slip, now that every page renders the settings menu first. In `spec/system/big_screen_fit/waiting_spec.rb`, assert the "Join from this computer" link on one line and no wider than its QR tile at every `FIT_SIZES` window, not only at 1280×800: at 1280×1024 the link is still 24px under a 288px tile, so shrink it there if the example is red. Check the join page's name field error border in light (`red-600`), which ticket 46's criterion names and only dark tests.

## Spec references

No spec change. Specs for criteria already decided, and at most a size fix the spec already demands:

- SPEC.md, 8. Big screen (`/games/:code`), **Fit**: on every window from 1280×720 up, "the QR is never under 160px ... and the link stays on one line under its tile, no wider than it", the code choosing the sizes
- SPEC.md, Shared: 10. Cards and visual system > Visual system (the 3:1 form field border rule; the room code and name fields)
- SPEC.md, Shared: 10. Cards and visual system > Themes
- Ticket 46's Acceptance criteria (the name field keeps `red-500` dark and `red-600` light with an error) and ticket 64's (the Game mode toggle track's `gray-700` border in dark)
- docs/design-system.md, `bot-big-waiting8-light`: "The code is the truth for how the built hero and rail shrink"

## Scope

Specs and spec support, plus the big screen waiting hero's join link classes only if a new example is red.

1. **The Game mode toggle track.** The dark contrast example for the landing's Game mode toggle reads the track inside the Game mode form (the fieldset whose legend is "Game mode", in the form that starts a game), never the first `fieldset > div` on the page, which is the settings menu's Theme track
2. **The bare-selector audit is done** (see the Decided line): no other selector read by first match in the dark contrast, theme, settings menu, card colors, static error page or fit specs lands on the settings menu or on another element than its example names. Change none of them
3. **The join link and the QR floor at every fit window.** The "waiting fit" shared context's check, run by every waiting fit example (each `FIT_SIZES` window, 1920×1080 and the light 1280×720), also asserts:
   - the "Join from this computer" link (`[data-join-here]`) sits under its QR tile (`[data-qr-tile]`), is no wider than the tile, and is on one line (its rendered height no more than its computed line height)
   - the QR's `svg` is at least 160px wide

   The 1280×800 example's own link-under-tile checks and the 1280×720 QR floor example go, now covered by the shared check
4. **If any window is red,** shrink the link at that window's height step in the big screen board partial's join link classes, using the type sizes the link already steps through (`text-2xl`, `text-xl`, `text-base`, `text-sm` and their leadings), so it fits its tile at every `FIT_SIZES` window and stays at 24px at 1920×1080. Nothing else in the hero changes
5. **The join page's name field error border in light.** The dark contrast landing and join spec asserts that with a name error the name field's border is `red-600` in light, beside its existing `red-500` dark example

Must not touch: any stylesheet, controller or other view; the height variants' names or thresholds (ticket 83); the hero's other sizes and the pills (ticket 73); the values existing examples assert; the shared helpers' homes (ticket 81).

## Acceptance criteria

- The landing's Game mode toggle example reads an element inside the Game mode form, so no element of the settings menu can match it, and it fails when it asserts a wrong shade such as `gray-600`
- At every `FIT_SIZES` window (1280×720, 1366×768, 1280×800, 1440×900, 1280×1024), at 1920×1080 and in light at 1280×720, with 8 players, a spec asserts the "Join from this computer" link is under its QR tile, no wider than it and on one line, and the QR is at least 160px wide, and it passes
- At 1920×1080 the link is still 24px
- In light, with a name error, a spec asserts the join page's name field border computes to `red-600`
- No file under `app/` changes except the join link's classes in the big screen board partial, and those only if the link check was red
- The whole suite passes and no spec file runs over 8 s

## Verification

`bin/test-all && bundle exec standardrb`

Tests first:

1. The scoped toggle example and the light name error example, each first asserting a wrong shade (`gray-600`, `red-500`) to see it fail, then the right one
2. The link and QR floor checks in the waiting fit shared context, run with `bundle exec rspec spec/system/big_screen_fit` before any view change: note which windows are red. Only then shrink the link at those height steps and rerun

## Out of scope

- A guard that makes `style`, `rect` or `font_px` refuse a selector with more than one match
- Horizontal fit checks for the hero text and room code against the rail
- Renaming the height variants (ticket 83) or moving the shared helpers (ticket 81)
- Any other size in the waiting hero, and the ended screen's fit
- The `find(..., text: ...)` calls, which Capybara already refuses when ambiguous

## Comments

Decided: Priority low, because it tightens specs and at most shrinks a link a few pixels on two laptop heights, polish on a built screen. Instead of: normal.

Decided: Feature Themes, ticket 64's, because most of the work is the theme specs it deferred. Instead of: Page layout, ticket 72's, for the fit part.

Decided: no spec change, because SPEC §8 Big screen, Fit already says the link stays on one line under its tile, no wider than it, on every window from 1280×720 up, and the code chooses the sizes (the design system says the same for the hero). Instead of: a spec edit naming the link's size per height.

Decided: the bare-selector audit is done in triage and found one slip, the Game mode `fieldset > div`. Checked and clean, because the settings menu holds none of their elements or the page has only one match before the one meant: `main > p` (player screen, its Room footer), `main section`, `h1`, `figure .card-edge`, `section .card-edge`, `.byline`, `input[type=submit]` (the landing's Start a game is a `button`), `p.text-sm` (the join hint, with no error shown), `fieldset .grid-cols-4 label:has(input:checked)` (the menu's grids are 3 and 2 columns), `section[aria-label=Invite]`, `html`, `:root`, `body > main`, landing layout's `section`, `figure`, `figure div` and `header`, the fit specs' `[data-...]` and `#...` selectors, and every `find(..., text:)`. Instead of: leaving the audit to the build.

Decided: the link and QR floor checks go into the waiting fit shared check, which runs at every window, because the spec states both for every window and each was asserted at one size only, the same flaw. Instead of: only the link, and only in the file the request names (the 1280×800 link check lives in the sizes spec, not `waiting_spec.rb`).

Decided: "on one line" is the link's rendered height no more than its computed line height, because the link is `whitespace-nowrap` and a second line would double its height. Instead of: counting `getClientRects()`.

Decided: a red window is fixed by stepping the link down through the sizes it already uses at that height step, because the spec lets the code choose the hero's sizes and no new token is needed, so no design pass. Instead of: a design pass for the link's size, or shrinking the QR tile's padding.

Decided: no guard making `style` refuse multi-match selectors, because many examples read the first of several on purpose (`figure .card-edge`, `[data-hero-text] > p`) and ticket 81 reshapes these helpers. Instead of: a guard in the shared helper.

No conflict: no spec change. Ticket 83 renames the height variants the link's classes use, ticket 73 resizes the waiting hero for long names and ticket 81 moves the shared helpers; none contradicts this request, and whichever builds later keeps the others' names and checks green.

Decided: no change to the join link's classes, because the new link and QR check passed at every `FIT_SIZES` window, 1920×1080 and light 1280×720 before any view change (the link is no wider than its tile at 1280×1024 too). Instead of: shrinking it at the 1024 height step.
