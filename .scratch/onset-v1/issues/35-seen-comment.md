# 35: Player#seen! comment gives the spec's reason

Status: needs-triage
Kind: behavioural
Blocked by:
Model:
Effort:
Changelog:

## Request

Behind the scenes: the comment on Player#seen! gives SPEC §7's reason for skipping callbacks (a heartbeat broadcast shows nothing new) instead of the stale-message reason the spec retired

From review 20261022-163847, pending decision 2. The comment is at `app/models/player.rb:17-18` and still says the method skips callbacks "so it doesn't broadcast a stale controller_status that can land after the real update". Ticket 34 reworded the SPEC §7 bookkeeping paragraph: the version check now guards against stale broadcasts, and the heartbeat skips its broadcast because it would show nothing new. Comment only: the method and its behaviour stay as they are.

## Comments
