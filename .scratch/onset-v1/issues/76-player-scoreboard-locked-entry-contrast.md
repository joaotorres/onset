# 76: A locked entry on the player screen's scoreboard reads at 4.5:1 in both themes

Status: done
Kind: visual
Blocked by:
Priority: normal
Feature: Themes
Model:
Effort:
Changelog: A locked-out player's name and score on your phone's scoreboard are now easy to read in both themes.

## Request

Deferred from 46. A locked-out player's entry on the player screen's scoreboard reads at 4.5:1 or more in both themes, as the big screen's locked row does since ticket 46. `players/controller/_scoreboard.html.erb` fades the entry's dot, name and score with `opacity-45` (the design system's "locked entry content at 45% opacity"), which worked out by hand leaves the name and score at about 3:1 on the light theme's white entry and about 4.4:1 in dark, under SPEC §10's "Text at least 4.5:1 on its ground ... whatever its size" in both themes; a locked entry is no disabled control, so that exemption does not cover it. Give the locked name and score a text color that meets the rule in each theme, on a plain entry and on the player's own (`gray-800`, light `gray-100`), in the portrait chips and the landscape and computer rows, keep the red Locked tag as it is, and measure the computed contrast in a system spec.

## Spec references

No spec change. Covered by:

- SPEC.md, Shared: 10. Cards and visual system > Visual system: the **Text** bullet (at least 4.5:1 on its ground, whatever its size, "a locked player's entry on its scoreboard" named; only disabled controls' labels exempt) and Themes ("The theme never reaches a broadcast": themed colors from CSS keyed on `<html>`)
- SPEC.md, 8. Player screen (`/games/:code/controller`): the Scoreboard bullet (a locked-out player's entry is greyed with a red **Locked** tag; the own entry's surface tint)
- docs/design-system.md v9: Components > players/controller/_scoreboard (the locked entry) and Shared: Rules added in v9

## Scope

- `app/views/players/controller/_scoreboard.html.erb` only, for the view. On a locked entry (locked and not claiming, as today):
  - the dot alone keeps `opacity-45`; the `[data-entry-content]` wrapper, the name and the score lose every opacity fade
  - the name and the score take a text color: on a plain entry `text-muted light:text-gray-500` (dark `muted` on `gray-900`, light `gray-500` on white); on the player's own entry `text-gray-400 light:text-gray-600` (dark on `gray-800`, light on `gray-100`)
  - the same in the portrait chips and the landscape and computer rows (one markup, as today)
  - the red Locked tag, its position and its classes unchanged
  - colors only through classes and the `light:` variant, never chosen per viewer's theme in Ruby (the partial is broadcast)
- An entry that is not locked looks exactly as today, the claiming entry included
- Update the two request spec assertions that read `opacity-45` on the locked entry (`spec/requests/games/playing_spec.rb`, `spec/requests/games/playing_landscape_spec.rb`) to the new look: the dot faded, the name and score not
- Must not touch: the big screen's `games/_scoreboard` (already fixed by ticket 46), `docs/design-system.md`, the game over standings, any other partial

## Acceptance criteria

- With the viewing player and one other player both locked out during play, on the player screen in dark and in light, at 375×667 (portrait chips), 667×375 (landscape rows) and 1280×800 (computer rows):
  - the other player's locked name and score each have a computed contrast of at least 4.5:1 against their entry's computed background
  - the viewing player's own locked name and score each have at least 4.5:1 against the own entry's computed background
  - neither the name, nor the score, nor any ancestor of theirs up to the entry `li` has a computed opacity below 1
  - the locked entry's dot has a computed opacity of 0.45
  - the Locked tag is still shown, `bg-red-600` with white text as today
- In dark the plain locked name's computed color is the `muted` token and the own locked name's is `gray-400`; in light `gray-500` and `gray-600`
- An entry not locked keeps today's color and full opacity

## Verification

`bin/test-all && bundle exec standardrb`

Write first, and show red on today's markup: a system spec measuring the criteria above, computing the WCAG contrast ratio from the computed `color` of the name and score and the computed `background-color` of their `li`, split into one file per theme (for example `spec/system/player_screen_theme/locked_entry_dark_spec.rb` and `..._light_spec.rb`) so each stays under 8 s, reusing the existing theme contexts (`player screen theme`, `dark contrast`) and putting the ratio helper in `spec/support/system/`. Then the updated request spec assertions.

## Out of scope

- The bot mark in the player scoreboard (ticket 69); a bot is never locked out, so it never takes the locked color
- Any change to the big screen's locked row, the Locked tag's look, or the claiming entry
- Consolidating the theme spec helpers (ticket 81)

## Comments

Decided: a small visual fix, its design entry written at filing (v9), because it makes an existing, built entry readable with tokens the design system already has (muted, secondary) and adds one state. Instead of: a full design pass and brief.

Decided: gate 2 passes on DESIGN v9 (commit c7a4f79, after the filing in 3fc2a8b), judged a small visual fix as its Decided line says: it uses only existing tokens (`muted`, `gray-400`, `gray-500`, `gray-600`) and the one state it changes is already built. Instead of: holding it for a design pass.

Decided: no spec change, because SPEC §10 Visual system's Text bullet already names "a locked player's entry on its scoreboard" and the build had fallen short of it; "greyed" in §8 Player screen still holds with a muted color. Instead of: a History line in §10.

Decided: the flaw lives in this one partial, because a search of `app/views`, `app/helpers` and `app/javascript` finds no other text faded by `opacity-*` or an alpha text color (`text-*/NN`); the big screen fades only its locked dot (`opacity-50`), which is no text. Instead of: widening the scope to other screens.

Decided: the two request spec assertions on `opacity-45` change with the markup, because they assert the look this ticket replaces. Instead of: leaving them red for the build to discover.

Decided: Priority normal and Feature Themes, because it is a contrast shortfall in built work, as its parent 46 (Themes, normal) was. Instead of: high, kept for broken behaviour.
