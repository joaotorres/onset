# 07: Full standings on the player screen game over

Status: needs-triage
Kind: visual
Design gap: yes
Blocked by:
Model:
Effort:

## Request

Player screen game over: full standings under the rank, own row highlighted

Below "2nd · of N players", a compact standings list: rank, color dot, name, score, the player's own row highlighted. Ties share a rank, as on the big screen podium.

## Comments

Decided: created docs/design-system.md v1 from the code before filing this first visual ticket, as loop-rules section 9 says. Instead of: no visual gate.

Design gap: SPEC §8 "Phone controller" item 8 (Game over) lists the rank, "of N players · P points", the winner line and "Play again from the big screen", but no standings list. Does the list sit under the winner line or replace it? Each row shows rank, dot, name and score: anything else, such as the Locked tag or ready marks? How is the own row marked? Up to 8 players (8 preset colors, unique per room): must the list fit without scrolling in portrait and landscape?
