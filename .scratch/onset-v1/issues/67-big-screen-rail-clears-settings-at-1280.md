# 67: Big screen Players rail clears the settings button at 1280×800

Status: needs-triage
Kind: behavioural
Blocked by:
Priority:
Feature:
Model:
Effort:
Changelog:

## Request

Deferred from 47. On the big screen at 1280×800 with 8 players, keep the Players rail clear of the 56×56 settings button in every state (waiting, playing and ended): the built boards' rail, a 152px room tile and 60px rows with 8px gaps, is about 760px tall and runs under the button. Check what the code renders at 1280 and shrink the rows as the design system's 1280 board draws them (52px rows, padding 8px 16px, 36px scores, 6px gaps) where it does not fit.

## Comments

Decided: Kind behavioural, because design system v8 already draws the 1280 rail's sizes, so nothing new is invented. Instead of: visual.
