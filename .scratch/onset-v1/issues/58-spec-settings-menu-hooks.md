# 58: SPEC §7 Hooks names everything the settings controller relies on

Status: deployed
Kind: behavioural
Blocked by:
Priority: low
Feature: Themes
Model:
Effort:
Changelog: Behind the scenes: the spec's list of markup hooks names everything the settings menu, invite, card picking, countdown and telemetry controllers rely on.

## Request

Deferred from 50. SPEC §7 Hooks' Settings menu line names everything the settings controller relies on, as the other hook entries do. It names only `data-controller="settings"`, but the controller now also needs `data-settings-theme-colors-value` (this ticket; without it `connect()` throws) and three document actions: `keydown.esc@document->settings#escape` (51), `turbo:before-cache@document->settings#dismiss` (53) and `turbo:before-render@document->settings#syncFromCookies` (52). Check the other §7 hook entries against their partials for the same gap.

## Spec references

SPEC `## Shared: 7. Realtime: Action Cable + Turbo Streams`, `### Hooks that must survive any markup change`: the Settings menu, Waiting invite, `card-selection`, Telemetry and `countdown` entries, edited by this triage.

## Scope

SPEC.md only, edited in this triage. No code, no tests.

- Settings menu: the theme-colors value, the three document actions, the `button`, `shield` and `menu` targets with their actions, the close button, the two radio groups by name and value, and the layout's viewport meta the `theme-color` metas follow (checked against `layouts/_settings.html.erb` and `settings_controller.js`)
- Waiting invite: the `label`, `copyIcon` and `shareIcon` targets (`players/controller/_invite.html.erb`, `invite_controller.js`)
- `card-selection`: the Submit button's `data-state` and `data-submit-label` child (`players/controller/_submit.html.erb`), each card's `<svg>` the tray copies, the `csrf-token` meta both requests send
- Telemetry: the `game-events` and `track` controllers and their values, written by `TrackingHelper`
- `countdown`: either target may stand alone (`_button_ring` has only the ring, `_secondary_action`'s No Set button only the seconds)
- Checked and unchanged: the big screen and player screen hook ids, and `card-tap` (`players/controller/_board_strip.html.erb`, `card_tap_controller.js`), which match their entries

## Acceptance criteria

- §7 Hooks' Settings menu entry names `data-settings-theme-colors-value`, the three document actions, the `button`, `shield` and `menu` targets and the two radio groups
- The invite, `card-selection`, Telemetry and `countdown` entries name every target, value and attribute their controllers read

## Verification

`grep -c 'settings#syncFromCookies' SPEC.md && grep -c 'data-settings-theme-colors-value' SPEC.md && grep -c 'shareIcon' SPEC.md && grep -c 'data-submit-label' SPEC.md`

Tests to write first: none, spec only.

## Out of scope

- Any markup or controller change to match the spec: the spec now describes the code as it is
- The global `turbo:before-stream-render` listener, already in §7 Screens ignore broadcasts older than what they show

## Comments

Decided: §7 Hooks also gains the gaps found in the invite, `card-selection`, Telemetry and `countdown` entries, because the request asks to check the other entries for the same gap and each names less than its controller reads. Instead of: the Settings menu line alone.

Decided: no change to the big screen and player screen ids or to `card-tap`, because each matches its partial and controller. Instead of: restating them.

Decided: the ticket closes in triage as `done`, as tickets 25, 27 and 57 did, because its only change is a spec edit that gate 1 makes triage commit, so a build would have nothing left to do; the Verification command above passed. Instead of: a ready-for-agent brief that spends a build session on no edit.

Decided: Priority low, Feature "Themes" (ticket 50's, which it was deferred from), Model empty, because no user notices a spec fix. Instead of: normal.

Decided: no conflict with open tickets or the spec changes since the last deploy, because 42, 46 and 54 edit §4, §5, §8 and §10, not §7 Hooks, and 47, 48, 59 and 60 add no hook to these entries. Instead of: blocking on any of them.
