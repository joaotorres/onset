# 46: Dark theme muted text and field borders meet contrast

Status: needs-triage
Kind: visual
Blocked by: 43, 44, 45
Priority:
Model:
Effort:
Changelog:

## Request

Deferred from 40. In the dark theme, muted text (the "Room CODE" footer, the big screen's empty band text, the tray slot numbers) reads at 4.5:1 or more on its ground, and field borders at rest at 3:1 or more, as the light theme's do.

Ticket 40 kept dark as built, so muted `gray-500` (4.16:1 on `gray-950`) and the `gray-700` field border stayed below the spec's contrast.

## Comments

Decided: the fix covers every dark text in the muted shade, not only the three the request names: the "Room CODE" footer, the big screen's empty band text, its scoreboard's "No one yet" and locked player entry, the "/N" of the No Set vote count, the join page's hint under the colors, the tray slot numbers and the placeholders of the room code and name fields, all `gray-500` today, because they are one flaw, a muted shade under 4.5:1 on `gray-950` and `gray-900`, and SPEC 10 Visual system now holds every text to 4.5:1 whatever its size. Instead of: the three named places only.

Decided: the labels of disabled controls (Join when the room is full, Start game with one player, `gray-800` with `gray-500`) are exempt and stay as built, because WCAG exempts inactive controls and the design system gives them their own disabled looks. Instead of: raising them with the muted text.

Decided: a field border at rest must reach 3:1 against both the field's fill and the surface around it, and only the two form fields (the landing's room code field, the join page's name field) are field borders; the mode toggle's track and the Join and invite button borders are not, and stay as built, because a button's label and a toggle's selected segment show the control, while an empty field shows only its border. Instead of: raising every `gray-700` border.

Decided: blocked by 43, 44 and 45, because they move every dark color of each screen into the theme CSS keyed on `<html>`, and raising the dark muted text and field border after them changes each role once there instead of colliding with their rewrite of the same views. Instead of: building it first on the dark-only markup.

Decided: when ticket 42 is built first, this ticket's scope also covers the static error pages' dark muted text and field borders, which copy Onset's dark shades as plain hex, because SPEC 10 Themes gives them Onset's text shades and the Visual system contrast rule covers every page. Instead of: a follow-up for the error pages.

Spec settled in SPEC.md, Shared: 10. Cards and visual system > Visual system (the contrast rule for text and form field borders, both themes). Gate 2 not met: docs/design-system.md v6 has no changelog entry for this ticket and keeps dark muted text `gray-500` and the dark field border at rest `gray-700`. Missing: the dark muted text shade (`gray-400`, the secondary shade, is the first Tailwind gray to reach 4.5:1 on `gray-900`, so the pass also says how muted stays apart from secondary, or that the two merge), the dark field border at rest, and the placeholder shade in both themes, on a dark sheet beside `LightSheet`; the layouts do not change, so no board needs redrawing. Waiting for /design-brief 46.
