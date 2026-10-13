# 21: Refuse a No Set call once per board

Status: needs-triage
Kind: visual
Design gap: yes
Blocked by:
Model:
Effort:

## Request

Allow any player to refuse once to extend time once up until cards are added, if refused no one is allowed to call "no set" for 15s

## Comments

Decided: visual, because a refuse action during the No Set countdown and a blocked No Set state are not in docs/design-system.md. Instead of: behavioural.

Design gap: SPEC §2 has no refusal of a No Set call. (1) Who refuses and when: any active player during the 15-second No Set countdown, including the caller and players who already agreed? (2) What a refusal does to the running call: cancels it at once, or extends its countdown ("extend time")? (3) "Once up until cards are added": one refusal per player, or one per room, until the next cards are dealt (a Set found or a No Set resolved)? (4) The 15-second block: does it stop everyone calling No Set, the refuser included, and does SET! stay open during it? (5) Is there a penalty for refusing, as for a wrong SET!? (6) What the big screen and every player screen show for a refusal and during the block (who refused, a countdown, the No Set pill disabled)?
