# 24: Add a "by joaotorr.es" byline footer

Status: needs-triage
Kind: visual
Blocked by:
Model:
Effort:

## Request

Add a "by joaotorr.es" byline footer to every page that uses the main layout (retroactive: already built in d7f1cc8)

Filed after the build. The look and behaviour come from a brief shared across all of the user's apps and must match it exactly: muted "by joaotorr.es" with a 1px red underline, one link to https://joaotorr.es in a new tab, on hover or keyboard focus the dot hops and the domain fades into the logo colours and stays coloured until the next page load, no hop under reduced motion, 44px tap target, hidden "(Opens in a new tab)" label.

Settled in the conversation: the app is always dark, so the logo colours take their dark values. English only, since the views use no i18n. The footer comes after `main`, not pinned to the bottom of a short window, because pinning it would move the landing's centred content and the join page's Join button. The big screen and the player screen get no footer, since they are full-screen `h-dvh` views and a footer would make them scroll. The user wants it written into SPEC.

## Comments
