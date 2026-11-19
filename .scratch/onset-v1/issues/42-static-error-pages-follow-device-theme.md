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

Rechecked 2026-11-17: still waiting for the design pass. docs/design-system.md has no changelog entry for this ticket (the latest, v6, is tickets 40 and 41, plus ticket 49's records correction, which designs nothing for the error pages). Blocker 43 is deployed, so the brief can be written now. The five files in `public/` are still the scaffold. No conflict with open tickets 46 to 55: 46 already covers the error pages' dark muted text and field borders if this ticket is built first, 50's one-source rule covers only `app/` and leaves static files such as `public/icon.svg` as they are, and 52's spec change (every page load takes the cookie as it is then) is the rule the inline script already follows. The brief draws each error page in dark and light from Onset's surfaces and text shades, its message unchanged, with no settings menu and no byline footer.

Rechecked again 2026-11-17, after builds 50 to 56: still waiting for the design pass, no `DESIGN` changelog entry covers it and `public/` is unchanged. The spec and design edits since (claims, Start and Play again, the light selection ring, the byline footer and menu records) touch nothing on the error pages, and the new open tickets, 47, 48 and 57, do not conflict.

Decided: brief 20261119-42-46 draws the error pages as four new boards, 404 on a phone and 500 on a computer, each dark and light, the other three pages taking the same layout with their own words, and redraws no board, because no board of the error pages exists yet and the five differ only in their text. Instead of: a board per page and theme, ten boards, over the 6-board round.

Design entry: docs/design-system.md v7, Screens > Static error pages, boards `err-404-p-dark`, `err-404-p-light`, `err-500-d-dark`, `err-500-d-light`. Colors only: dark page `gray-950`, bold first sentence `gray-50`, rest `gray-300`, numerals `gray-800`, status name `red-400`; light `gray-50`, `gray-900`, `gray-700`, `gray-200`, `red-700`.

Design question: the error pages' faint status code numerals (dark `gray-800` 1.37:1, light `gray-200` 1.18:1, as faint as the scaffold's) are below SPEC §10 Visual system's 4.5:1 for text. The design treats them as a backdrop graphic under the red status name, with the page title and the SVG's label naming the code. Confirm SPEC §10 Themes treats them as decoration, or say they must reach 4.5:1, which would turn them into a visible second headline.

Decided: the design entry records the numerals as decoration in DESIGN v7 and leaves the 4.5:1 question to triage, because the scaffold draws them as SVG paths behind the status name, ticket 42 keeps the header graphic, and the SPEC rule lists text, not graphics. Instead of: flagging them as a conflict with SPEC §10 and holding the entry.

Decided: the entry adds Screens > Static error pages and retires the Visual rules line that called the error pages "not drawn yet (ticket 42)"; no existing rule or token changes for this ticket. Instead of: leaving the stale line.
