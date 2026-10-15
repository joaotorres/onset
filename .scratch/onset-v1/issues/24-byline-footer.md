# 24: Add a "by joaotorr.es" byline footer

Status: deployed
Kind: visual
Blocked by:
Model:
Effort:

## Request

Add a "by joaotorr.es" byline footer to every page that uses the main layout (retroactive: already built in d7f1cc8)

Filed after the build. The look and behaviour come from a brief shared across all of the user's apps and must match it exactly: muted "by joaotorr.es" with a 1px red underline, one link to https://joaotorr.es in a new tab, on hover or keyboard focus the dot hops and the domain fades into the logo colours and stays coloured until the next page load, no hop under reduced motion, 44px tap target, hidden "(Opens in a new tab)" label.

Settled in the conversation: the app is always dark, so the logo colours take their dark values. English only, since the views use no i18n. The footer comes after `main`, not pinned to the bottom of a short window, because pinning it would move the landing's centred content and the join page's Join button. The big screen and the player screen get no footer, since they are full-screen `h-dvh` views and a footer would make them scroll. The user wants it written into SPEC.

## Spec references

SPEC §8 Views & UX, Byline footer (new).

## Scope

`app/views/layouts/application.html.erb`, a new `app/views/layouts/_byline_footer.html.erb`, the byline styles in `app/assets/tailwind/application.css`, an opt-out in `games/show` and `controllers/show`, and a request spec. Must not change any page's existing layout, `main` classes or spacing.

## Acceptance criteria

- The landing, How to play and the join page end with a footer holding one link to https://joaotorr.es, `target="_blank"`, `rel="noopener"`
- The link's accessible name is "by joaotorr.es (Opens in a new tab)": the coloured copies of "joaotorr" and "es" are `aria-hidden`
- The big screen and the player screen have no footer
- At rest, hover, keyboard focus and reduced motion behave as SPEC §8 Byline footer says (checked in a browser)

## Verification

`bundle exec rspec spec/requests/byline_footer_spec.rb && bundle exec rspec`. Write `spec/requests/byline_footer_spec.rb` first, from the criteria above.

## Out of scope

i18n of the footer, a light mode, pinning the footer to the bottom of short windows, any change to the error pages or mailers.

## Comments

Decided: design entry v3 written from the cross-app byline brief, because its look is fixed across all of the user's apps and a design pass could only copy it. Instead of: a design brief and a design-tool pass.

Decided: the footer follows the content instead of pinning to the bottom of a short window, because pinning moves the landing's centred content and the join page's Join button. Instead of: a min-height flex body with `main` set to flex 1.

Decided: no footer on the big screen and player screen, because they are full-screen `h-dvh` views and a footer would make them scroll. Instead of: the footer on every page of the layout.

Decided: the code came first (d7f1cc8), so the spec was red only with the footer removed from the layout, 4 of 6 failing. Instead of: rebuilding it after the tests.
