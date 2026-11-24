# 87: A static error page shown again by Back or Forward takes the current theme

Status: needs-triage
Kind: behavioural
Blocked by:
Priority:
Feature:
Model:
Effort:
Changelog:

## Request

Deferred from 77. A static error page (400, 404, 406, 422, 500) shown again by Back or Forward from another site shows the theme picked meanwhile in another tab. Each page's inline script in `<head>` reads the `theme` cookie once before the first paint, so a page the browser restores from its back-forward cache keeps the old theme on `<html>` and in the `theme-color` meta, and the script removes the device-matching `theme-color` metas it would need when the cookie has since been deleted. Run the same read on `pageshow` when `persisted`, restoring both metas for Match device, in all five pages, with a system spec that leaves for another site and comes back.

## Comments
