# 77: Back or Forward into Onset from another site shows the current theme and card colors

Status: needs-triage
Kind: behavioural
Blocked by:
Priority:
Feature:
Model:
Effort:
Changelog:

## Request

Deferred from 52. Back or Forward into Onset from another site shows the theme and card colors picked meanwhile in another tab. SPEC §10 Themes counts "Back or Forward to a page shown before" as a page load that takes the cookies as they are then, but `settings#syncFromCookies` runs only on `turbo:before-render`, and a page the browser restores from its own back-forward cache (the landing, the join page or How to play, after leaving Onset by a typed address or an outside link) gets no Turbo render, so `<html>`, the `theme-color` metas and the menu's marked choice keep the old picks. Run the same sync when the page is shown again from that cache (`pageshow`), metas and radios included, for both cookies. Read from the code, not seen in a browser: reproduce it in a system spec first, and close this as already covered if no Onset page is restored that way.

## Comments
