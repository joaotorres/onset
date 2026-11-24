# 76: A locked entry on the player screen's scoreboard reads at 4.5:1 in both themes

Status: needs-triage
Kind: visual
Blocked by:
Priority:
Feature:
Model:
Effort:
Changelog:

## Request

Deferred from 46. A locked-out player's entry on the player screen's scoreboard reads at 4.5:1 or more in both themes, as the big screen's locked row does since ticket 46. `players/controller/_scoreboard.html.erb` fades the entry's dot, name and score with `opacity-45` (the design system's "locked entry content at 45% opacity"), which worked out by hand leaves the name and score at about 3:1 on the light theme's white entry and about 4.4:1 in dark, under SPEC §10's "Text at least 4.5:1 on its ground ... whatever its size" in both themes; a locked entry is no disabled control, so that exemption does not cover it. Give the locked name and score a text color that meets the rule in each theme, on a plain entry and on the player's own (`gray-800`, light `gray-100`), in the portrait chips and the landscape and computer rows, keep the red Locked tag as it is, and measure the computed contrast in a system spec.

## Comments

Decided: a small visual fix, its design entry written at filing (v9), because it makes an existing, built entry readable with tokens the design system already has (muted, secondary) and adds one state. Instead of: a full design pass and brief.
