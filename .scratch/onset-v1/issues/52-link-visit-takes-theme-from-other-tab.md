# 52: A tab that follows a link takes on the theme and card colors picked in another tab

Status: needs-triage
Kind: behavioural
Blocked by:
Priority:
Feature:
Model:
Effort:
Changelog:

## Request

Deferred from 43. A tab that follows a link inside Onset takes on the theme and card colors picked in another tab. The picks live on `<html data-theme>` and `<html data-card-colors>` (`layouts/application.html.erb`), but Turbo Drive keeps the old `<html>` on a link visit and copies over only `lang`, so the tab keeps its old theme and card colors while the new head brings the new `theme-color` meta and the menu's radios come checked from the new cookie (SPEC §10 Themes, "Other open tabs of the same browser take it on their next page load", and §10 Palette for card colors, ticket 41). Copy both attributes from the incoming document's `<html>` on `turbo:before-render`, and cover it with a system spec that changes the cookie, then follows a link.

## Comments
