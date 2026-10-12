# 08: Devices-first landing and creator join

Status: needs-triage
Kind: visual
Blocked by:
Model:
Effort:

## Request

Devices-first: landing has one "Start a game" plus the standard / first-to-5 toggle, leading to the creator's join form with "Use this screen as the big screen instead"

Settled while grilling (ADR 0001): devices-first is the default. "Start a game" creates the room and opens the creator's join page (name and color). Its secondary action, "Use this screen as the big screen instead", leads to today's `/games/:code`. The separate "Start quick game" button becomes a standard / first-to-5 toggle above "Start a game".

Every game is the same: no big screen vs devices mode is stored on the Game. The big screen is a URL any room can open at any time, even mid-game. User-facing text says "player screen" and "big screen" (GLOSSARY.md); code names stay.

## Comments
