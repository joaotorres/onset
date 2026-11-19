# 58: SPEC §7 Hooks names everything the settings controller relies on

Status: needs-triage
Kind: behavioural
Blocked by:
Priority:
Feature:
Model:
Effort:
Changelog:

## Request

Deferred from 50. SPEC §7 Hooks' Settings menu line names everything the settings controller relies on, as the other hook entries do. It names only `data-controller="settings"`, but the controller now also needs `data-settings-theme-colors-value` (this ticket; without it `connect()` throws) and three document actions: `keydown.esc@document->settings#escape` (51), `turbo:before-cache@document->settings#dismiss` (53) and `turbo:before-render@document->settings#syncFromCookies` (52). Check the other §7 hook entries against their partials for the same gap.

## Comments
