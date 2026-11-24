# 80: Behind the scenes: make the theme and fit specs measure what their criteria name

Status: needs-triage
Kind: behavioural
Blocked by:
Priority:
Feature:
Model:
Effort:
Changelog:

## Request

Deferred from 64. Behind the scenes: make the theme and fit specs measure what their criteria name. In `spec/system/dark_contrast/landing_and_join_spec.rb` the "Game mode toggle track" example reads `fieldset > div`, whose first match on the landing is the settings menu's Theme track (the menu renders before the form), so it passes whatever border the toggle has: scope it to the Game mode form, and check every other bare selector in the dark contrast, theme and fit specs for the same first-match slip, now that every page renders the settings menu first. In `spec/system/big_screen_fit/waiting_spec.rb`, assert the "Join from this computer" link on one line and no wider than its QR tile at every `FIT_SIZES` window, not only at 1280×800: at 1280×1024 the link is still 24px under a 288px tile, so shrink it there if the example is red. Check the join page's name field error border in light (`red-600`), which ticket 46's criterion names and only dark tests.

## Comments
