# 55: Start game and Play again act only in their state

Status: needs-triage
Kind: behavioural
Blocked by:
Priority:
Feature:
Model:
Effort:
Changelog:

## Request

Deferred from 11. The host's Start game and Play again act only in the state they belong to. `Game#start!` (`app/models/game.rb`) takes no lock and checks no status, `restart!` runs in any status, and `GamesController#start` and `#restart` check only the `host_game` cookie. So a Start game tap that lands once the game is playing (the last ready vote started it a moment before, a double tap before the broadcast removes the button, or a big screen whose button is stale after a dropped connection or a back-button visit) deals a new board mid-game with the scores kept, a Play again that lands while a game is playing zeroes the scores, and one in a waiting room starts it whatever the player count; a claim pending at that moment stays pending and `ExpireClaimJob` later resolves it in the new game. SPEC §6 says transitions always run under the game lock, and §17 names the two as `waiting` to `playing` and `ended` to `playing`; the ready votes already check (`vote_start!`, `vote_play_again!`). Say in SPEC §5 Routes that each is ignored, still `204`, outside its state, as the bot routes say; make `start!` act only when `waiting?` and `restart!` only when `ended?`, both under the game lock (`vote_start!` and `vote_play_again!` call them inside theirs), and add model and request specs for a start while playing, a restart while playing and a restart while waiting. From the security review `.scratch/onset-v1/reviews/security-20261115.md`, finding F5.

## Comments
