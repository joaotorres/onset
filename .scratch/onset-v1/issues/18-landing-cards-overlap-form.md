# 18: Landing cards overlap the start game form at narrow desktop widths

Status: ready-for-agent
Kind: behavioural
Blocked by:
Model:
Effort:

## Request

Reducing the screen size on the desktop makes an image overlap with the start game form, let's fix it.

From the screenshot (browser window about 800px wide, production): the desktop landing layout still applies, the brand column has shrunk so the tagline wraps to one or two words a line, and the three fanned example cards spill out of it over the Start a game card, covering "Have a room code?" and the code field.

## Spec references

- SPEC §8 Landing (`/`): the first paragraph, split at `lg:`, phone layout below it, brand column contents shrink with the column and are full size from 1280px.

## Scope

- The landing view (`lobbies/new`) and its Tailwind classes only: the breakpoint the two-column grid switches at, and how the fanned cards and the wordmark are sized inside the brand column.
- A new system spec for the landing layout at several widths, following the resize helper the player screen system specs use.
- Must not touch the card partial (`cards/_card`), the join page, the how to play page, the forms' markup or behaviour, or the design system file.

## Acceptance criteria

- Below 1024px (for example 800px and 768px wide) the landing stacks in one centered column, the phone layout: the join form first, the Start a game form, then the fanned cards and caption below, and nothing overlaps.
- From 1024px up the brand column and the actions card sit side by side. At 1024px and at 1100px wide, the right edge of the fanned cards and of the wordmark stays at or left of the actions card's left edge, and the page has no horizontal scroll.
- The fanned cards keep their 5:7 shape and tilt at every width; their size follows the brand column's width, capped at the current desktop size (192px tall), which they have at 1280px wide and up.
- At 1280px wide the layout measures as today: cards 192px tall, wordmark 136px, actions card 448px wide.
- The phone layout at 375px wide is unchanged.
- Existing landing request specs stay green.

## Verification

Write first, in `spec/system/landing_layout_spec.rb`, driven by headless Chrome with the viewport-padding resize helper from `spec/system/player_screen_computer_spec.rb`:

- at 800px: the figure's top is below the actions section's bottom (stacked)
- at 1024px and 1100px: `figure div` (the card row) right edge and `h1` text right edge are `<=` the `section` left edge, and `document.documentElement.scrollWidth == window.innerWidth`
- at 1280px: the first `[data-card-id]` is 192px tall and the section is 448px wide

Then make them pass. The exact command:

```
bundle exec rspec spec/system/landing_layout_spec.rb spec/requests/lobbies_spec.rb
```

## Out of scope

- Changing the actions card's 448px width, the grid gap or page padding at 1280px and up: the 1280 board is the design.
- Redesigning the phone layout or what the tablet range shows beyond applying the existing phone layout to it.
- Any change to the design system file, the card partial or the How to play page.
- Fluid type for the tagline: it may wrap, as it does on phones.

## Comments

Decided: behavioural, because the desktop and phone landing layouts both already exist in docs/design-system.md (Landing, ticket 08) and the fix is which one applies at mid widths and keeping the cards inside their column. Instead of: visual.

Decided: the two-column landing starts at `lg:` (1024px) instead of `md:` (768px), because with a 448px actions card, 80px gap and 64px padding the brand column is 112px wide at 768px and 144px at 800px, where neither the 451px card fan nor the 136px wordmark can fit, so tablets get the phone layout. Instead of: keeping `md:` and shrinking the brand column's contents to a 112px column.

Decided: between 1024px and 1280px the fanned cards and the wordmark shrink with the brand column, full size from 1280px, because at 1024px the column is 368px wide and the fan is 451px, so moving the breakpoint alone leaves the overlap in the 1024-1100px range. Instead of: a third breakpoint that keeps the fan full size and hides a card.
