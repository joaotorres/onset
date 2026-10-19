# 31: SPEC: telemetry with jt_telemetry and the custom events

Status: deployed
Kind: behavioural
Blocked by:
Model:
Effort:
Changelog: Behind the scenes: the spec now describes the telemetry and its custom events, nothing changes for players.

## Request

SPEC: document the telemetry from 6ad66e4, e3a67b0 and 2539ceb: jt_telemetry (PostHog and Sentry, link its README, no gem internals), APP_NAME onset, Sentry DSN in Keychain item onset-sentry-dsn, the custom event catalog with properties and where each fires (flash-based for server actions), game_started/finished/restarted sent only by the player at the top of the standings, duration_seconds left out when that screen did not see play start (no started_at column; adding one would make it exact), start_method and set_found deliberately not tracked, PostHog memory persistence. Docs only

From the user. The code is built and committed; this documents it, no code or test change. The gem is https://github.com/joaotorres/jt_telemetry: link its README for how it works rather than repeating it.

game_started, game_finished and game_restarted arrive by broadcast, so only one screen sends them: the player at the top of the standings. duration_seconds on game_finished is left out when that player's screen was opened fresh mid-game, since there is no started_at column; adding one would make it exact.

start_method is not tracked: the screen cannot tell whether the host pressed Start or everyone voted ready. set_found is deliberately not tracked: it fires many times per game.

Privacy: PostHog uses memory persistence, so it sets no cookies and keeps nothing in browser storage.

## Spec references

- §17 Telemetry, new: Setup, Custom events, Privacy
- §13 Deployment, the `config/deploy.yml` Env line and `.kamal/secrets`
- §7 Hooks that must survive any markup change, the Telemetry line

## Scope

SPEC.md only. No code, no tests: 6ad66e4, e3a67b0 and 2539ceb already do what §17 says, and `spec/helpers/tracking_helper_spec.rb`, `spec/system/telemetry_spec.rb` and `spec/requests/telemetry_spec.rb` prove it.

## Acceptance criteria

- §17 links the jt_telemetry repo and README and repeats no gem internals beyond the settings Onset relies on
- §17 names `APP_NAME` `onset` and the Keychain item `onset-sentry-dsn`; §13 lists `SENTRY_DSN` and `APP_NAME` in Env and the Sentry DSN in `.kamal/secrets`
- §17 has a row per custom event (`game_created`, `player_joined`, `invite_shared`, `game_started`, `game_restarted`, `game_finished`) with its properties and where it fires, and explains the flash route for server actions
- §17 says only the player at the top of the standings sends the game state events, when `duration_seconds` is left out and that a `started_at` column would make it exact
- §17 says why `start_method` and `set_found` are not tracked, and that PostHog uses memory persistence

## Verification

`grep -q "^## 17. Telemetry" SPEC.md && grep -q "onset-sentry-dsn" SPEC.md && grep -q "github.com/joaotorres/jt_telemetry#readme" SPEC.md && for e in game_created player_joined invite_shared game_started game_restarted game_finished; do grep -qE "^\| \`$e\` \|" SPEC.md || exit 1; done && grep -q "memory persistence" SPEC.md && grep -q "started_at" SPEC.md && grep -q "set_found" SPEC.md && grep -q "start_method" SPEC.md && echo ok`

Tests to write first: none, docs only.

## Out of scope

Adding a `started_at` column, a `start_method` property or a `set_found` event. Any code or test change. A glossary entry: §17 adds no domain term.

## Comments

Decided: telemetry is a new §17 after §16, not a section after §13, because CLAUDE.md, closed tickets and the loop log cite §14 to §16 by number and renumbering would break them. Instead of: inserting it as §14 and shifting the rest.

Decided: Privacy also names the one `sessionStorage` entry per room the `game-events` controller keeps, because PostHog stores nothing but Onset's own telemetry code does, and "no browser storage" alone would misstate the code. Instead of: the PostHog line alone.

Decided: §13's Env and `.kamal/secrets` lines and a §7 hook line for the `game-events` and `track` elements are updated too, because §13 reads as the deploy config and would be stale, and a markup change that drops the `game-events` element would silently stop the game events. Instead of: §17 alone.

Decided: the ticket closes in triage as `done`, as tickets 25, 27 and 28 did, because every change it asks for is a spec edit that gate 1 makes triage commit; the Verification command above passed. Instead of: a ready-for-agent brief that spends a build session on no edit.
