# 78: A theme or Color-blind pick lasts a year on Safari too

Status: needs-triage
Kind: behavioural
Blocked by:
Priority:
Feature:
Model:
Effort:
Changelog:

## Request

Deferred from 52. A theme or Color-blind pick lasts the year SPEC §10 gives it on Safari too. The `theme` and `card_colors` cookies are written only by script (`store` in `settings_controller.js`, `max-age` a year), and Safari caps a cookie a page's script writes at 7 days, so on an iPhone or in a Mac's Safari a pick lapses a week after it was made. Have the server send each valid cookie again with its year on page loads, or another way that keeps the pick itself in the browser with no request; both cookies, on every page the layout renders. The static error pages only read them.

## Comments
