# Design handoff

Where the design tool's work lives and what it was last given.

## Design links

- Canvas: https://claude.ai/artifact/123TNq7nwcKGoXDaroSGcM (private, created 2026-10-12)
- Handed off: docs/design-system.md v5, 2026-10-25 (return in `.scratch/onset-v1/design/20261024-37/return.md`)
- Components (each also a board): Main (landing), Join, Waiting, PlayPortrait, PlayLandscape, PlayComputer, PlayPortraitRefusal, PlayLandscapeRefusal, PlayComputerRefusal, GameOver, BigScreen. Every other board imports one of them with a state. Board files are `project/<name>.dc.html`

| Screen | Tickets | Boards | State |
|---|---|---|---|
| Landing | 08 | landing-phone, landing-phone-quick, landing-phone-notfound, Main, landing-desktop-quick, landing-desktop-notfound | built |
| Join page | 08 | Join, join-creator, join-name-blank, join-taken, join-started, join-full | built |
| Player screen, Waiting, portrait | 10 | waiting-p-1, Waiting, waiting-p-voted, waiting-p-failed, waiting-p-share, waiting-p-qr | built |
| Player screen, Waiting, landscape and computer | 10 | waiting-l-1, waiting-l-8, waiting-l-voted, waiting-l-qr, waiting-c-1, waiting-c-8, waiting-c-voted, waiting-c-qr | built |
| Player screen, play, portrait 8/18 | 09 | PlayPortrait, play-p8-deck-empty, -claiming, -other, -noset, -agreed, -wrong, -timeup, -found, -arrive | built |
| Player screen, play, portrait 3/12 | 09 | play-p3-idle, play-p3-deck-empty, -claiming, -other, -noset, -agreed, -wrong, -timeup, -found, -arrive | built |
| Player screen, play, landscape | 09 | PlayLandscape, play-l-deck-empty, -claiming, -other, -noset, -agreed, -wrong, -timeup, -found, -arrive | built |
| Player screen, play, computer | 09 | PlayComputer, play-c-deck-empty, -claiming, -other, -noset, -agreed, -wrong, -timeup, -found, -arrive | built |
| Player screen, Game over, portrait | 07 | GameOver, gameover-p-voted, -tie, -win, -long | built |
| Player screen, Game over, landscape and computer | 07 | gameover-l-second, -voted, -tie, -win, -long; gameover-c-second, -voted, -tie, -win, -long | built |
| Player screen, play, No Set refusal, portrait 8/18 | 21 | PlayPortraitRefusal, play-p8-refuse-locked, play-p8-blocked, play-p8-blocked-self | exploring |
| Player screen, play, No Set refusal, landscape | 21 | PlayLandscapeRefusal, play-l-blocked | exploring |
| Player screen, play, No Set refusal, computer | 21 | PlayComputerRefusal, play-c-blocked | exploring |
| Big screen, during play | 21 | BigScreen | exploring |
| Player screen, play, claiming with Submit, every layout | 37 | play-p8-, play-p3-, play-l- and play-c- each with -claim0, -claiming, -claim2, -claim3, -submitted (PlayPortrait, PlayLandscape, PlayComputer states claiming0, claiming2, claiming3, submitted) | exploring |
