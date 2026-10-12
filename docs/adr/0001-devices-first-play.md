# Devices-first play, big screen optional

v1 was built Jackbox-style: a shared big screen showed the board and phones only called SET! and picked cards. We are flipping the default so each player plays on their own device, phone or computer, and the player screen carries everything a game needs (board, scores, announcements, play again). The big screen stays as an optional URL any room can open at any time, not a mode stored on the game. Shared-TV play is the less common case, and devices-first also allows remote play. The cost is a player screen that has to stand alone and a computer layout of its own.

## Consequences

- Starting a game leads to the creator's join form, with "use this screen as the big screen" as the secondary path.
- Play again becomes a ready vote on the player screens; the big screen keeps its own button.
- Code names (`ControllersController`, `#board`) predate this and stay; user-facing text says "player screen" and "big screen".
