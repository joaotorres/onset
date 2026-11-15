# Design handoff

Where the design tool's work lives and what it was last given.

## Design links

- Canvas: https://claude.ai/artifact/123TNq7nwcKGoXDaroSGcM (private, created 2026-10-12)
- Handed off: docs/design-system.md v6, 2026-11-15 (return in `.scratch/onset-v1/design/20261115-40-41/return.md`)
- Components (each also a board): Main (landing), Join, Waiting, PlayPortrait, PlayLandscape, PlayComputer, PlayPortraitRefusal, PlayLandscapeRefusal, PlayComputerRefusal, GameOver, BigScreen. Themed components (v6, props for theme, palette, state and menu; each a board at light and Classic): LandingTh, JoinTh, HowToPlayTh, WaitingTh, PlayPortraitTh, PlayLandscapeTh, PlayComputerTh, GameOverTh, BigScreenTh, and SettingsMenu. Every other board imports one of them with a state. Board files are `project/<name>.dc.html`

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
| Player screen, play, No Set refusal, portrait 8/18 | 21 | PlayPortraitRefusal, play-p8-refuse-locked, play-p8-blocked, play-p8-blocked-self | built |
| Player screen, play, No Set refusal, landscape | 21 | PlayLandscapeRefusal, play-l-blocked | built |
| Player screen, play, No Set refusal, computer | 21 | PlayComputerRefusal, play-c-blocked | built |
| Big screen, during play | 21 | BigScreen | built |
| Player screen, play, claiming with Submit, every layout | 37 | play-p8-, play-p3-, play-l- and play-c- each with -claim0, -claiming, -claim2, -claim3, -submitted (PlayPortrait, PlayLandscape, PlayComputer states claiming0, claiming2, claiming3, submitted) | built |
| Foundations: light theme sheet, card colors sheet | 40, 41 | LightSheet, CardColorsSheet | exploring |
| Settings menu, landing and join page | 40, 41 | SettingsMenu, s-landing-p-dark, -p-dark-open, -p-light-open, s-landing-d-dark, -d-dark-open, -d-light-open, s-join-dark-open, s-join-light-open | exploring |
| Settings menu, player screen | 40, 41 | s-waiting-p-dark-open, s-waiting-p-light-open, s-play-p-dark, -p-dark-open, -p-light-open, -p-picked-light, -p-picked-cb, s-gameover-p-dark, s-play-l-dark, s-play-c-dark, -c-dark-open, -c-light-open | exploring |
| Settings menu, big screen | 40, 41 | s-big-dark, s-big-dark-open, s-big-light-open | exploring |
| Landing and join page, light | 40, 41 | l-landing-p, l-landing-p-notfound, LandingTh, l-landing-d-quick, JoinTh, l-join-creator, -taken, -started, -full | exploring |
| How to play, light and dark | 39, 40, 41 | l-htp-p, s-htp-p-dark, HowToPlayTh, d-htp-d | exploring |
| Player screen, Waiting, light | 40, 41 | WaitingTh, l-waiting-p-voted, l-waiting-p-qr, l-waiting-l-8, l-waiting-c-8 | exploring |
| Player screen, play, portrait 8/18, light | 40, 41 | PlayPortraitTh, l-play-p-deck-empty, -claim3, -submitted, -other, -refusal, -agreed, -blocked, -wrong, -found, -arrive | exploring |
| Player screen, play, landscape and computer, light | 40, 41 | PlayLandscapeTh, l-play-l-claim3, -other, -refusal, -wrong, -found; PlayComputerTh, l-play-c-claim3, -other, -refusal, -wrong, -found | exploring |
| Player screen, Game over, light | 40, 41 | GameOverTh, l-gameover-p-voted, l-gameover-l, l-gameover-c | exploring |
| Big screen, light, and dark waiting and ended | 40, 41 | l-big-waiting4, l-big-waiting1, d-big-waiting4, d-big-waiting1, BigScreenTh, l-big-claiming, -noset, -refused, -correct, -wrong, -deck-empty, -ended, d-big-ended | exploring |
| Color-blind card colors, player screen and landing | 41 | cb-play-p-dark, -light, cb-play-p-claim2-dark, -light, cb-play-p-found-dark, -light, cb-play-c-dark, -light, cb-landing-p-dark, -light, cb-landing-d-dark, -light | exploring |
| Color-blind card colors, big screen and How to play | 41 | cb-big-correct-dark, -light, cb-htp-d-dark, -light | exploring |
