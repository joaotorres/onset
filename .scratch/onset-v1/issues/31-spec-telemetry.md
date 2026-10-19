# 31: SPEC: telemetry with jt_telemetry and the custom events

Status: needs-triage
Kind: behavioural
Blocked by:
Model:
Effort:
Changelog:

## Request

SPEC: document the telemetry from 6ad66e4, e3a67b0 and 2539ceb: jt_telemetry (PostHog and Sentry, link its README, no gem internals), APP_NAME onset, Sentry DSN in Keychain item onset-sentry-dsn, the custom event catalog with properties and where each fires (flash-based for server actions), game_started/finished/restarted sent only by the player at the top of the standings, duration_seconds left out when that screen did not see play start (no started_at column; adding one would make it exact), start_method and set_found deliberately not tracked, PostHog memory persistence. Docs only

From the user. The code is built and committed; this documents it, no code or test change. The gem is https://github.com/joaotorres/jt_telemetry: link its README for how it works rather than repeating it.

game_started, game_finished and game_restarted arrive by broadcast, so only one screen sends them: the player at the top of the standings. duration_seconds on game_finished is left out when that player's screen was opened fresh mid-game, since there is no started_at column; adding one would make it exact.

start_method is not tracked: the screen cannot tell whether the host pressed Start or everyone voted ready. set_found is deliberately not tracked: it fires many times per game.

Privacy: PostHog uses memory persistence, so it sets no cookies and keeps nothing in browser storage.

## Comments
