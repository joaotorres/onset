# 42: Static error pages follow the device's light or dark setting

Status: needs-triage
Kind: visual
Blocked by: 43
Priority:
Model:
Effort:
Changelog:

## Request

Deferred from 40. Static error pages (404, 422, 500 and the others in public/) follow the device's light or dark setting, as the app's own pages do since the light theme.

Ticket 40 left them dark because they are static files that cannot read the `theme` cookie.

## Comments

Decided: the error pages take Onset's own dark and light surfaces and text shades, because the five pages in `public/` are the untouched Rails scaffold, which already follows the device but in generic colors of its own (white, `#101010`), so "as the app's own pages do" means the app's two themes. Instead of: closing it `wontfix` as already built.

Decided: the `theme` cookie, when set, wins on the error pages through a few lines of inline script in `<head>` that accept only `light` or `dark`, because the cookie is not HttpOnly and a player who picked Dark on a light device would otherwise get the one light page in the app. Instead of: following the device only, as the request reads.

Decided: no settings menu, no byline footer and unchanged messages on the error pages, because they are static files with no Stimulus controllers and the request asks for the theme only. Instead of: bringing them in line with the app's pages in full.

Decided: blocked by 43 still, because the error pages copy the light values 43 builds as plain hex in their own CSS. Instead of: building them on the design entry alone.

Spec settled in SPEC.md, Shared: 10. Cards and visual system > Themes (The static error pages) and Shared: 8. Views & UX. Gate 2 not met: docs/design-system.md v6 does not cover the static error pages (the brief for 40 and 41 left them out and its entry quotes them as staying dark), so the design pass has not happened. Missing: the error pages' dark and light look in Onset's tokens, a board for each theme. Waiting for /design-brief 42.
