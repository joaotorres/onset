# 65: Design system's quote of SPEC visual system matches SPEC

Status: done
Kind: behavioural
Blocked by:
Priority: low
Feature: Themes
Model:
Effort:
Changelog: Behind the scenes: the design system's quote of the SPEC visual system matches SPEC again.

## Request

Deferred from 46. Behind the scenes: bring the "Quoted from `SPEC.md`" part of `docs/design-system.md` (Shared: 10 Visual system) up to date with SPEC: add SPEC's `muted` `#7C8390` token bullet, and end its History line with SPEC's "which raises them to `muted` and `gray-500`". Check the rest of that quoted part against SPEC word for word and correct any other line that has drifted.

## Spec references

No spec change: SPEC.md, Shared: 10. Cards and visual system (Palette, Component, Visual system, Themes) is the source the quote follows, and already reads as ticket 46 left it.

To correct in the build: docs/design-system.md v8, Shared: Visual rules > SPEC §10. Cards and visual system (the Visual system and Themes parts of the quote), Changelog.

## Scope

Records only: `docs/design-system.md` is the one file that changes.

- **Visual system, tokens list:** after the `.found-set-flash` bullet, add SPEC's bullet word for word: "`muted` (`#7C8390`): dark muted text and dark form placeholders, the one color outside the Tailwind default palette (ticket 46). Light muted text and placeholders stay `gray-500`."
- **Visual system, History line:** end it as SPEC does: "... and deferred them to ticket 46, which raises them to `muted` and `gray-500`."
- **Themes, the pointer line** ("`SPEC.md` §10 Themes also holds ..."): the quote leaves out four of SPEC's Themes bullets on purpose, and the pointer names only three of them. Add the fourth, Picking a theme applies at once (other tabs on their next page load, `theme-color` included), so it names all four: the `theme` cookie, the no-flash rule and `color-scheme`, picking a theme applying at once, and the static error pages. Keep its pointer to Screens > Static error pages
- **Changelog:** one entry at the top, `v8, <date>: ticket 65, ...`, saying the quoted SPEC §10 Visual system matches SPEC again and the Themes pointer names every bullet left out, nothing new designed. No version bump, as tickets 49 and 53
- The rest of the quote (Palette, Component, the Visual system's other lines and its table, the quoted Themes bullets) already reads word for word as SPEC, checked by this triage: leave it
- Must not touch: SPEC, the glossary, any other DESIGN section (Shared: Tokens and Shared: Themes (v6) already carry `muted`), the canvas boards, `docs/design-handoff.md`, any file under `app/` or `spec/`

## Acceptance criteria

- DESIGN's quoted SPEC §10 Visual system reads word for word as SPEC §10 Visual system, from "Two themes, dark and light" to "Inverted codes fail on some phone cameras.", the `muted` bullet and the full History line included
- DESIGN's quoted SPEC §10 Palette and Component still read word for word as SPEC's
- DESIGN's Themes pointer line names the `theme` cookie, the no-flash rule, `color-scheme`, picking a theme applying at once and the static error pages, and every SPEC §10 Themes bullet is either quoted word for word or named there
- DESIGN's Changelog has the ticket 65 entry first, and its title still reads version 8
- `git diff` of the build touches only `docs/design-system.md` and the ticket's own records

## Verification

`bin/test-all && bundle exec standardrb`

No tests to write first: nothing in `spec/` reads `docs/design-system.md`, and the change is to a record, not to code. The word-for-word check is by reading the quoted part beside SPEC §10 after the edit.

## Out of scope

- Re-copying the four SPEC §10 Themes bullets the quote leaves out on purpose
- A DESIGN version bump, a handoff doc change or redrawing boards
- Any other DESIGN, SPEC or glossary rewording beyond the items above

## Comments

Decided: no spec change, because SPEC §10 is the source and already reads as ticket 46 left it; only the quote drifted. Instead of: touching SPEC.

Decided: the fix covers the whole quote, Palette, Component, Visual system and Themes compared word for word: only the `muted` bullet, the History line's ending and the Themes pointer drifted, so those three are the scope, because a fix covers the whole flaw (loop-rules 11). Instead of: the two lines the request named.

Decided: the Themes part stays abridged and its pointer line gains "picking a theme applies at once", the one left-out SPEC Themes bullet it did not name, because ticket 53 kept that abridgement on purpose and the pointer is what makes it safe. Instead of: quoting all of SPEC §10 Themes.

Decided: one Changelog entry at v8 with no version bump, as tickets 49 and 53 did for records corrected to the build, because nothing new is designed and a bump would put the handed-off version behind for no drawing. Instead of: v9.

Decided: Verification is the repo's standard command with no new tests, because no spec reads the design system and the change is to a record. Instead of: a spec comparing the quote to SPEC.

Decided: Priority low, Feature Themes (ticket 46's), Model and Security left empty, because no user notices a records fix. Instead of: normal.
