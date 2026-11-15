# 41: Colour-blind friendly card palette, toggled in settings

Status: needs-triage
Kind: visual
Blocked by: 40
Priority:
Model:
Effort:
Changelog:

## Request

Add a colour-blind friendly option for the cards, toggled from the settings menu that ticket 40 adds.

Settled in conversation:
- The option swaps the card colours to a colour-blind-safe palette and adds a shape or pattern cue beyond colour, so cards can be told apart without relying on colour alone.
- It also applies to the card diagrams on the How to play page.
- The setting is stored per device in the browser, like ticket 40's, not on `Player`.
- Stack stays Hotwire (Stimulus) and Tailwind only.

## Comments

Decided: the user chose on 2026-11-15 that the current IBM palette (blue, orange, magenta), already colour-blind safe, becomes the opt-in Color-blind option, and the default becomes a new, more distinct palette; SPEC 10 Palette now has two card palettes. Instead of: keeping the IBM palette as the default and only adding a colour cue, or a third palette for the option.

Decided: the default palette is Set's own red, green and purple, called Classic, because they are the most widely separated hues for normal vision and the colours every Set player already knows; their exact shades come from the design pass, kept apart from each other, the card face and the player presets' own red, green and purple. Instead of: another palette of three hues, which would still land near red, green and blue-purple and be one players do not recognise.

Decided: the default is named Classic, not Standard, because Standard already names a game mode (GLOSSARY). Instead of: Standard.

Decided: the player colour presets stay as they are and the Classic shades are picked apart from them, because changing presets would recolour players already stored in rooms and SPEC 16 already asks presets and card palette not to collide. Instead of: changing PRESET_COLORS.

Decided: the colour meanings table stays as it is and governs the UI, not card faces, because cards were always their own palette (SPEC 10 Palette) and a red card next to a red Wrong panel names a card feature, not a result. Instead of: moving meaning colours away from red, green and purple.

Decided: the Color-blind option also adds a color mark on every card, one per colour, drawn inside the SVG so sizes and layouts do not change, never altering shape, number or shading, its form left to the design pass, because the request settled a cue beyond colour and the answer on the palette did not take it back. Instead of: the IBM palette alone.

Decided: Card colors is a second option in the settings menu, Classic and Color-blind, Classic the default with no device preference to follow, because no browser setting states colour blindness. Instead of: an on/off switch, or following a device setting.

Decided: the choice is a `card_colors` cookie (`colorblind`, a year, SameSite Lax, deleted for Classic) the layout renders on `<html>`, card colours and the mark coming from CSS keyed on it and the mark always in the markup, because cards render in Turbo Stream partials shared by every screen (SPEC 7) and the theme cookie works the same way. Instead of: localStorage, or rendering cards per viewer.

Decided: the setting applies wherever a card renders, the landing's fanned cards included, and How to play's colour captions and its Not a Set example ("two red, one green") follow it through the same CSS, because a caption naming the wrong colour would teach the wrong card. Instead of: only boards and How to play diagrams.

Decided: each palette and the color mark are the same in both themes, because SPEC 10 Themes keeps the cards the same in both and the setting is independent of the theme. Instead of: palettes tuned per theme.

Decided: picking card colors sends `card_colors_changed` with `card_colors` (`classic`, `colorblind`), added to SPEC 17 Custom events, and the cookie joins `theme` in SPEC 17 Privacy as needing no consent, because CLAUDE.md asks for an event per new user-facing action. Instead of: no event.

Decided: GLOSSARY gains Card colors and Color mark, "pattern" avoided because shading already means solid, striped and outline. Instead of: calling it colour-blind mode.

Decided: no split for now, judged again after the design entry, as ticket 40's is, because the theme cookie mechanism and the settings menu come from 40 and the rest (palette tokens, one menu option, the mark, captions, one event) fits one session. Instead of: splitting now.

Waiting for the design pass: docs/design-system.md has no changelog entry for this ticket. The brief draws the Classic palette's shades, the color mark on each colour, the Card colors option in the settings menu, and every screen's cards under both palettes in both themes. Brief it with ticket 40, in one round: `/design-brief 40 41`.

Decided: brief 20261115-40-41 leaves every existing board as drawn and adds the light theme, settings menu and card colors boards beside them, because the light theme only recolours (SPEC 10 Themes keeps the layouts) and the brief describes as the truth what the code changed since the boards: the byline footer on the landing and join boards (tickets 24, 26), the narrow-desktop fanned cards (18), the computer "Room CODE" footer under the deck line (22), the 15 s lockout ring (20), the -win winner line (triage 07) and How to play's 944px box (39); the boards of tickets 21 and 37, still marked exploring in the handoff doc, are of deployed tickets and stay too. Instead of: redrawing the landing, join, computer play, locked out and game over boards from the code first.

Decided: the brief draws every new board in Classic, plus a Color-blind set in both themes for each place a card renders (player screen board, tray and found-set banner, big screen board and band, landing fanned cards, How to play diagrams and captions), and names the existing dark boards as Color-blind without the mark, because that shows every card surface under both palettes without drawing each screen four times. Instead of: every screen under both palettes in both themes.
