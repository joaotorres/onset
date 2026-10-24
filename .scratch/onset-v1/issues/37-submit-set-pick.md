# 37: Submit button for a SET! claim

Status: needs-triage
Kind: visual
Blocked by:
Model:
Effort:
Changelog:

## Request

Submit button for a SET! claim: once 3 cards are picked the claiming player can submit; the request carries the full card_ids and the server judges at once under the game lock (same outcomes as Claim#expire!: correct, wrong). Picks stay changeable until submit; the 15s ExpireClaimJob stays as the fallback when submit is never pressed. Partly reverses ticket 19 (no submit step): the submit must not depend on earlier pick PATCHes having landed, which avoids the race that ticket recorded.

Why: today a claim is judged only when the 15s run out (§11), so even a correct Set waits out the full timer.

Ticket 19 dropped the v1 auto-submit because the third tap was seen not to submit on a phone and the submit raced a mid-claim redraw. An explicit button whose request carries the whole selection avoids both: it does not wait on the pick requests, and the server judges what the button sent.

Kind is visual: a new control in the claim bar or tray, so it waits on the design pass.

## Comments
