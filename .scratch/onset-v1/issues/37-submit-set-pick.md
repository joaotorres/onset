# 37: Submit button for a SET! claim

Status: needs-triage
Kind: visual
Design gap: yes
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

Design gap: SPEC §11 says "there is no submit" and §2 Round flow, §6, §8 Player screen state 3 and §16 say nothing is judged before the 15 seconds run out, so no SPEC sentence decides the submit. Before the claiming screen can be drawn: (1) Is Submit offered only with exactly 3 picks, shown disabled below that, or hidden until then? (2) Once submitted, is the claim judged at once with the same outcomes and announcements as at expiry (correct: +1, deal, found-set banner; wrong: −1, lockout), and are the picks frozen from the tap on? (3) What does the claiming screen show between the tap and the broadcast that resolves it, and what if the submit request fails: the screen stays on the claim and the timer judges the stored picks? (4) A submit that lands after the claim resolved or expired: ignored, answering 204? (5) Telemetry: CLAUDE.md wants a jtTrack event per new user-facing action, but §17 leaves `set_found` untracked because it fires many times per game; does a submit get an event (`claim_submitted`) or the same exemption? (6) Does the big screen change at all, for example the Claiming panel ending early, or only through the existing Correct and Wrong panels?
