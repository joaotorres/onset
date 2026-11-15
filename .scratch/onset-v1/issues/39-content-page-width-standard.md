# 39: Content pages: width standard (944 px content, 65ch prose)

Status: done
Kind: behavioural
Blocked by:
Priority: low
Feature: Page layout
Model:
Effort:
Changelog: The How to play page uses its full 944 px for content, with the side padding outside it, and its running text is capped to a comfortable line length.

## Request

Width standard for content pages (jt-playbook `LAYOUT.md`, onset rows, adopted 2026-11-14, commit e835296; handoff 690f02).

How-to-play and other content pages keep 944 px (`max-w-5xl`), an agreed exception because of the card diagrams. Their padding moves from the max-width element to an outer wrapper (`px-5 sm:px-8 lg:px-10`), so the content is the full 944 px.

Prose on those pages is capped at `max-w-[65ch]`. Headings and diagrams can use the full width.

The byline footer follows the page's width. Game screens stay full width: no change.

## Spec references

- SPEC.md, Shared: 8. Views & UX (the Width paragraph)
- SPEC.md, 8. Byline footer (Where)
- GLOSSARY.md, Content page

## Scope

- `app/views/lobbies/how_to_play.html.erb`: replace the `mx-auto max-w-5xl px-5 pt-6 pb-16 md:px-10 md:pt-10 md:pb-24` element with an outer wrapper carrying the gutter `px-5 sm:px-8 lg:px-10` and an inner `mx-auto max-w-[944px]` box with no horizontal padding, keeping the vertical padding (`pt-6 pb-16 md:pt-10 md:pb-24`) on one of them
- On that page, the running prose takes `max-w-[65ch]` in place of its current caps: the header intro (now `max-w-2xl`), the intro line under Every card has four features (now `max-w-2xl`) and the statement under What makes a Set (now `max-w-3xl`)
- The headline `h1` drops its `max-w-3xl` and uses the whole box. Other headings, the card diagrams, the panels and grids keep their markup; text inside a panel or grid cell gets no cap
- `app/views/layouts/_byline_footer.html.erb`: the same gutter wrapper and `mx-auto max-w-[944px]` box in place of `mx-auto max-w-5xl px-5 md:px-10`, centred text as now, on every page that renders it
- Must not touch: the landing, the join page's own markup, the big screen, the player screen, the footer's styles in `app/assets/tailwind/application.css`, the footer's vertical spacing and the "fits inside the first screen" behaviour (SPEC 8. Byline footer)

## Acceptance criteria

Widths below are measured against the page's width, `document.documentElement.clientWidth` (W), so a scrollbar does not skew them:

- At a 1280px wide window, How to play's content box is 944px wide and centred: its left edge at (W - 944) / 2
- At an 800px wide window the box is W - 64 (32px gutters); at 375px wide, W - 40 (20px gutters)
- The header intro, the four-features intro line and the What makes a Set statement each carry `max-w-[65ch]`; no element on the page carries `max-w-2xl`, `max-w-3xl` or `max-w-5xl`
- The `h1` has no max-width class
- The byline footer's inner box is the same 944px box with the same gutter wrapper; on How to play, at 1280px and 800px wide, its left edge and width match the content box's
- The byline footer still fits the first screen on the landing and the join page (the existing `byline_footer_fit_spec` passes unchanged)
- The big screen and the player screen render no width box: no `max-w-[944px]` in their markup

## Verification

`bin/test-all && bin/rubocop`

Tests first:

- A system spec (headless Chrome, as `spec/system/byline_footer_fit_spec.rb` does) that opens `/how-to-play` at 1280, 800 and 375px wide and measures the content box's width and left offset and the footer box's left offset with `getBoundingClientRect`
- A request spec in `spec/requests/lobbies_spec.rb` that checks the How to play markup: the three prose elements carry `max-w-[65ch]`, the `h1` carries no `max-w-` class, and none of `max-w-2xl`, `max-w-3xl`, `max-w-5xl` appears

## Out of scope

- Moving the landing or the join page onto the width standard's classes (form, reading), or changing their widths
- A shared layout partial or helper for content pages: there is one content page
- Restyling headings, panels or card diagram sizes on How to play
- Any change to the game screens

## Comments

Decided: Kind behavioural, not visual, because the request names every class and How to play has no entry in docs/design-system.md, so the build invents no token, component, state or layout. Instead of: waiting on a design pass for a layout already specified.

Decided: the content box is 944px (`max-w-[944px]`), because the request says the page keeps 944px and its content becomes "the full 944 px", and `max-w-5xl` with the padding moved out would be 1024px. Instead of: `max-w-5xl`, a 1024px box wider than today.

Decided: the running prose capped at 65ch is the header intro, the four-features intro line and the What makes a Set statement; text inside panels and grid cells takes no cap, because it is already narrower than 65ch. Instead of: putting the cap on every paragraph.

Decided: the headline drops its `max-w-3xl`, because the request says headings use the full width. Instead of: keeping the headline at 768px.

Decided: the byline footer uses the same box on the landing and the join page too, because SPEC 8. Byline footer already centres it in one container on all three and its text is centred, so nothing visible changes there. Instead of: a per-page footer width.

Decided: How to play is the only content page today, and SPEC states the rule for content pages so a later one follows it. Instead of: naming How to play alone.
