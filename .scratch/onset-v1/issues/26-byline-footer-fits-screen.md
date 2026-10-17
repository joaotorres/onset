# 26: Byline footer fits the screen

Status: deployed
Kind: behavioural
Blocked by:
Model:
Effort:
Changelog: The byline no longer makes the landing, How to play and join pages scroll.

## Request

Byline footer pushes the landing, How to play and join pages taller than the screen on desktop and phone; it should fit without scrolling

The overflow is vertical: the page scrolls down because the footer adds height, not sideways.

Behavioural because the footer itself stays as ticket 24 and the design system (`layouts/_byline_footer`, v3) define it; only how it sits in the page layout changes.

## Spec references

SPEC §8 Views & UX, Byline footer, the "Where" bullet (changed: the footer fits inside the first screen).

## Scope

The page frame: the body in the main layout and the root `main` element of the landing, How to play and the join page, which today are each a full viewport tall (`min-h-dvh`) with the footer rendered after them, so the page is always one footer taller than the screen. Make the page a viewport-tall column in which `main` grows to fill the room left and the footer comes last. A system spec that measures the fit. Must not change the footer partial, its `.byline` and `.wm-*` styles, the big screen or the player screen (they hide the footer and stay `h-dvh`), or any page's content, spacing or inner layout beyond the root `main`'s height rule.

## Acceptance criteria

- At 1280×800 and 1024×900, the landing and the join page have no vertical scroll: `document.documentElement.scrollHeight` is at most `window.innerHeight`, and the footer's bounding box ends at or above the viewport's bottom edge
- At the same sizes, How to play, whose content is taller than the viewport, has the footer directly after its content: the page's scroll height equals `main`'s height plus the footer's height, with nothing in between
- On every one of the three pages the footer sits below `main`'s bottom edge, never over any content
- When the content is shorter than the viewport, the footer's bottom edge touches the viewport's bottom edge (the column fills the screen; `main` grows)
- The landing's content stays centred within `main`; the join page's Join button stays the last thing in `main`, above the footer
- The big screen and the player screen render no footer and keep their full-screen height; the existing byline request spec and system specs keep passing

## Verification

`bundle exec rspec spec/system/byline_footer_fit_spec.rb spec/requests/byline_footer_spec.rb && bundle exec rspec`. Write `spec/system/byline_footer_fit_spec.rb` first from the criteria above, resizing the viewport the way `spec/system/landing_layout_spec.rb` does, and show it red before changing the layout.

## Out of scope

Pinning the footer over the content (absolute or fixed), hiding it on any of the three pages, changing its look, padding, link or hover behaviour, a shorter footer, any change to the big screen or player screen, the error pages or mailers.

## Comments

Decided: the page is a viewport-tall flex column with `main` growing and the footer last, so the landing's centred content rises by about half the footer's height and the join page's Join button sits above the footer, because that is the only arrangement that fits without scrolling and never covers content. Instead of: overlaying the footer on the content, which would cover the join page's Join button and the phone landing's fanned cards, or a `main` min-height of the viewport minus a hard-coded footer height, which breaks as soon as the footer's height changes.

Decided: Kind stays behavioural as filed, because the footer component and every page's content are unchanged and only the page frame's height rule moves. Instead of: a visual ticket waiting on a design pass to redraw the landing and join boards.
