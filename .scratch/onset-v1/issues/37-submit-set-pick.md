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

Design gap: SPEC §11 says "there is no submit" and §2 Round flow, §6, §8 Player screen state 3 and §16 say nothing is judged before the 15 seconds run out, so no SPEC sentence decides the submit. Before the claiming screen can be drawn: (1) Is Submit offered only with exactly 3 picks, shown disabled below that, or hidden until then? (2) Once submitted, is the claim judged at once with the same outcomes and announcements as at expiry (correct: +1, deal, found-set banner; wrong: −1, lockout), and are the picks frozen from the tap on? (3) What does the claiming screen show between the tap and the broadcast that resolves it, and what if the submit request fails: the screen stays on the claim and the timer judges the stored picks? (4) A submit that lands after the claim resolved or expired: ignored, answering 204? (5) Telemetry: CLAUDE.md wants a jtTrack event per new user-facing action, but §17 leaves `set_found` untracked because it fires many times per game; does a submit get an event (`claim_submitted`) or the same exemption? (6) Does the big screen change at all, for example the Claiming panel ending early, or only through the existing Correct and Wrong panels?

Gap settled (triage, 2026-10-24): SPEC §2 Round flow rule 4, §5 Routes (`POST /games/:code/claims/:id/submit`), §6 diagram, §7 (the 204 list, the `card-selection` hooks), §8 Player screen state 3, §11, §12 `ExpireClaimJob`, §16 and §17 Not tracked now decide the submit, and the glossary's Claim entry says a claim is picked and submitted. Answers to the six questions: (1) disabled below three picks, enabled at exactly three, in one fixed place the design pass chooses; (2) judged at once, same outcomes and announcements as at expiry, the picks frozen from the tap; (3) the screen stays on the claim, frozen, ring running, until the resolving broadcast; a request that never reaches the server unfreezes it; (4) a late submit changes nothing and answers 204; (5) no event, listed under §17 Not tracked; (6) the big screen changes only through the existing Correct and Wrong panels. Next: the design brief, then triage.

Decided: Submit is shown disabled below three picks and enabled at exactly three, in one fixed place, because §8 keeps SET! in a fixed slot so the thumb never moves, and a control that appears at the third tap would be a surprise. Instead of: hidden until three picks.

Decided: the submit is its own route, `POST /games/:code/claims/:id/submit`, because judging is a different action from storing picks, and the route table reads it. Instead of: a `submit` flag on the pick PATCH.

Decided: from the tap the screen takes no more picks and no second tap until the resolving broadcast, unfrozen only when the request never reaches the server, because the server has judged what was sent and a response of any kind means the broadcast or the timer follows. Instead of: picks changeable after the tap, or the screen resolving itself before the broadcast.

Decided: a submit that arrives once the claim is resolved, or carrying fewer than three distinct board cards, changes nothing and answers 204, because §7 makes every action answer 204 and the broadcast is the truth, and `pick!` already ignores an invalid selection the same way. Instead of: 409 or 422, which no screen reads.

Decided: no `claim_submitted` event, listed under §17 Not tracked, because like `set_found` it fires once per claim, many times a game, and `Claim` records already show a submitted claim by its `resolved_at`. Instead of: an event per CLAUDE.md's default for a new user-facing action.

Decided: the big screen is unchanged, the Claiming panel ending through the existing Correct and Wrong panels, because the resolution broadcasts are the ones expiry sends. Instead of: a new panel or early-end treatment.

Decided: no column records whether a claim was submitted or timed out, because that is a schema change and `resolved_at` against `started_at` plus the timeout already tells. Instead of: a `submitted_at` column on `Claim`.

Decided: the brief leaves the four claiming boards (`play-p8-claiming`, `play-p3-claiming`, `play-l-claiming`, `play-c-claiming`) as they are, because the only change since they were drawn (ticket 19, no dimming at three picks) does not show at their 1/3, and the brief tells the design tool the code is the truth for it. Instead of: redrawing them from the code first.
