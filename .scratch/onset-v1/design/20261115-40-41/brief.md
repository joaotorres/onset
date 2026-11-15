Canvas: https://claude.ai/artifact/123TNq7nwcKGoXDaroSGcM. Written against docs/design-system.md version 5, 2026-11-15.

# Design brief: light theme, settings menu and card colors (tickets 40, 41)

## Context

Onset is real-time multiplayer Set. Each player plays on their own **player screen**, on a phone or a computer, from which they call SET!, pick cards and vote; a shared **big screen** (a TV or laptop the whole table can see) is optional. Every page is dark today, with the cards the only bright surfaces.

This round adds three things, to every page the app renders (the landing, How to play, the join page, the big screen and the player screen):

1. **Ticket 40, a light theme**, and a new **settings menu** to pick it: Match device (the default, following the device's light or dark setting), Light or Dark. Dark stays exactly as it is today.
2. **Ticket 41, card colors**, a second option in the same menu: **Classic** (a new default palette, Set's own red, green and purple, whose exact shades you pick) or **Color-blind** (the blue, orange and magenta every card uses today, plus a new **color mark** on each card, whose form you design).

Who uses these screens: anyone in a room, on their own phone or computer, and whoever sets up the big screen. The settings menu is per browser: nothing about it reaches the other players.

Glossary terms these screens show:

- **Player screen**: One player's own view of a game, on a phone or a computer, from which they call SET!, pick cards and vote.
- **Big screen**: An optional shared display of a game, such as a TV or laptop the whole table can see. It is not a player.
- **Content page**: A page people read rather than play on, held in the 944px content box with its prose capped at 65ch. Today only How to play.
- **Settings menu**: The menu on every page where a player chooses how Onset looks on their browser, such as the theme or the card colors. Stored per browser, never on the player.
- **Theme**: Dark or light, the colors every page is drawn in. Each browser picks Match device (the default), Light or Dark in the settings menu. _Avoid_: Mode (a game's mode is Standard or First to 5), skin
- **Card colors**: The palette the cards are drawn in, picked per browser in the settings menu: Classic (red, green, purple; the default) or Color-blind (blue, orange, magenta, with a color mark on each card). A card's color feature is the same under both: only how it is drawn changes. _Avoid_: Color-blind mode, accessibility mode
- **Color mark**: The small mark the Color-blind card colors add to every card, one per color, so the colors can be told apart without seeing color. _Avoid_: Color symbol, pattern (shading already means solid, striped, outline)
- **Board**: The face-up cards in play, 12 to 18 of them.
- **Claim**, **Lockout**, **No Set call**, **Refusal**, **Ready vote**, **Standings**: as on the existing boards.

Use these words in every label: "Settings", "Theme", "Match device", "Light", "Dark", "Card colors", "Classic", "Color-blind". Never "dark mode", "color-blind mode" or "pattern".

## What to design

Board sizes, from the design system's screen anatomy: phone portrait 375×667, phone landscape 667×375, computer 1024×640, landing desktop 1280×800, big screen 1920×1080 (it must also fit a laptop down to 1280 wide). How to play is a scrolling page: draw it 375 wide and 1280 wide, as tall as its content.

Every new board draws its cards in **Classic**, the new default, unless the list says Color-blind. Add the boards beside the existing ones, grouped under new section titles; move no existing board.

### A. Foundations

1. **Light theme sheet**: one board that maps every dark-theme surface, border, text shade and meaning color used on the existing boards to its light counterpart, with each pair's contrast ratio on its ground. It covers at least: page, panel, raised panel (`gray-800` fills), borders, primary, secondary and muted text, the meaning colors as fills with white text, as tinted panels (the 10% to 15% tints with their rings) and as text, the disabled pill look, the yellow claim fill with its dark text, the focus outline, the overlay behind the QR sheet, the byline's at-rest text and underline, and the browser's `theme-color` (the address bar tint, `#030712` today) per theme
2. **Card colors sheet**: Classic red, green and purple and Color-blind blue, orange and magenta, each as solid, striped and outline on the `#FAFAFA` card face, on the dark ground and on the light ground; beside them the 8 player presets, so their distance from the Classic shades shows; and the three color marks, each on a card of its color, at the smallest card size the app uses (portrait at 8 players, 54×76) and at a large one

### B. Settings menu

The settings button and the open menu, in both themes, Classic cards:

3. Landing, phone and desktop: button closed; menu open with Match device and Classic marked
4. Join page, phone: menu open
5. How to play, phone and desktop: button closed (top of page)
6. Player screen, Waiting, portrait: menu open
7. Player screen, play, idle, portrait 8/18, landscape and computer: button closed; menu open over idle in portrait and computer
8. Player screen, Game over, portrait: button closed
9. Big screen, playing: button closed; menu open

Show in the open menu what changes on a pick: one portrait board with Light just picked (the page already light under the open menu) and one with Color-blind just picked (the cards behind it with their marks). Show its keyboard focus once.

### C. Light theme of every screen

Classic cards throughout. States in brackets are the existing dark boards to follow, which keep their layout:

10. **Landing**: phone Standard, phone Room not found, desktop Standard, desktop First to 5 (`landing-phone`, `landing-phone-notfound`, `Main`, `landing-desktop-quick`), each with the byline footer
11. **Join page**: joiner, creator, name and color taken (field errors), game already started (base error), every color taken (`Join`, `join-creator`, `join-taken`, `join-started`, `join-full`), with the byline footer
12. **How to play**: phone and desktop, full page, from the description under Spec facts (no dark board exists: draw a dark desktop one too, Classic cards, so both themes are on the canvas)
13. **Player screen, Waiting**: portrait 8 players, portrait voted with Copied ✓, portrait Show QR open, landscape 8, computer 8 (`Waiting`, `waiting-p-voted`, `waiting-p-qr`, `waiting-l-8`, `waiting-c-8`)
14. **Player screen, play, portrait 8/18**: idle, idle deck empty, claiming 3/3 with Submit enabled, submitted, someone else claiming, No Set may refuse, No Set agreed, No Set blocked after a refusal, locked out Wrong!, found-set banner, cards just dealt (the arrive outline) (`PlayPortrait`, `play-p8-deck-empty`, `play-p8-claim3`, `play-p8-submitted`, `play-p8-other`, `PlayPortraitRefusal`, `play-p8-agreed`, `play-p8-blocked`, `play-p8-wrong`, `play-p8-found`, `play-p8-arrive`)
15. **Player screen, play, landscape** and **computer**, each: idle, claiming 3/3, someone else claiming, No Set may refuse, locked out Wrong!, found-set banner (`PlayLandscape`/`PlayComputer` and their `-claim3`, `-other`, `Refusal`, `-wrong`, `-found`)
16. **Player screen, Game over**: portrait before voting, portrait voted, landscape, computer (`GameOver`, `gameover-p-voted`, `gameover-l-second`, `gameover-c-second`)
17. **Big screen**: waiting with 4 players, 2 ready; waiting with 1 player (Start game disabled); playing with the empty band; playing with each band panel: Claiming, No Set, Refused, Correct, Wrong; deck empty; ended with the podium. Draw the waiting and ended states in dark too (no dark board exists for them), and the playing band panels follow `BigScreen`

### D. Color-blind card colors

The Color-blind palette with its color marks, in both themes, wherever a card renders:

18. Player screen portrait 8/18: idle, claiming 2/3 (the tray), found-set banner
19. Player screen computer: idle
20. Big screen: playing, with the Correct band panel (its three cards)
21. Landing desktop and phone (the fanned cards)
22. How to play, desktop: the Color section and the Almost, but not a Set section, with their captions in the Color-blind words

The existing dark boards stay as they are: their cards are the Color-blind palette without its mark, which is now the opt-in option, not the default.

States not listed are the existing boards recoloured by the light theme sheet; draw no more of them. The settings menu has no loading, empty or error state: it makes no request (Spec facts). No favicon board: the app has its own.

## Spec facts

### SPEC §8 Settings menu

> One menu for the choices a player makes about how Onset looks on their browser, on every page the app renders: the landing, How to play, the join page, the big screen and the player screen. It holds two options, each with the current choice marked:
>
> - **Theme** (§10, Themes): **Match device**, **Light** and **Dark**, Match device until the player picks
> - **Card colors** (§10, Palette): **Classic** and **Color-blind**, Classic until the player picks
>
> Later options join it the same way.
>
> - **Opening it**: a settings button with the accessible name "Settings", always in the same place on a screen. Where it sits on each screen and how the menu opens (a sheet, a popover) comes from the design pass. It never moves SET!, the pill slot or the board, and it keeps the player screen's and the big screen's no-page-scroll rules (§8, Player screen; §10 Component)
> - **Picking** applies the option at once (§10, Themes and Palette) and leaves the menu open, so the player sees the result; Escape, a tap outside it or its close button closes it. It is a plain browser control with no request to the server: the settings menu's Stimulus controller writes the cookies
> - **Outside every broadcast target**: the menu and its button sit outside the regions Turbo Streams replace (§7, Hooks), so a room update never closes it or resets it, unlike the QR sheet inside `#controller_status`
> - **Telemetry**: picking a theme sends `theme_changed`, picking card colors `card_colors_changed` (§17, Custom events)

Under §7 Hooks:

> - Settings menu (§8, Settings menu): `data-controller="settings"` around the settings button and the menu, in the layout, outside every hook root above, so no stream replaces it

So the menu must not depend on anything inside the replaced regions: on the player screen that is `#controller_status` (the header or scoreboard, the deck count, the state body and the found-set banner); on the big screen `#board`, `#scoreboard`, `#announcement`, `#start_button`, `#room_tile`. The settings button can sit in the page frame around them (the player screen's colored top strip and "Room CODE" footer are outside `#controller_status`).

### SPEC §10 Themes

> **Dark** is the look every screen had before themes. **Light** puts dark text on light surfaces. Each browser picks one in the settings menu (§8, Settings menu): **Match device** (the default), **Light** or **Dark**. Match device follows the device's light or dark setting (`prefers-color-scheme`), live: switching the device's setting while a page is open switches the page with it. A device that states no preference gets dark.
>
> - **Stored per browser**, never on `Player` or `Game`: a `theme` cookie, `light` or `dark`, path `/`, a year long, SameSite Lax, not HttpOnly so the settings menu can write it. Match device deletes it. It holds no identity and is read only by Onset's own pages. A player keeps their theme in every room on that browser, the big screen included; another browser or device has its own
> - **No flash of the other theme.** The layout renders the chosen theme on `<html>` from the cookie, so the first paint is already right, and Match device is pure CSS (the media query), so it needs no script either. The page's `color-scheme` follows the theme, so form fields and scrollbars match it
> - **Picking a theme applies at once**, to the page it is picked on, with no reload. Other open tabs of the same browser take it on their next page load
> - **The theme never reaches a broadcast.** Turbo Stream partials (§7) are rendered once for every screen in a room, so nothing in them depends on the viewer's theme: every themed color comes from CSS keyed on `<html>`, never from markup rendered per theme
> - **Same in both themes:** the cards (the `_card` partial is never restyled, its near-white face and border included; on light surfaces the design pass may give the card's wrapper an edge so it reads), the card palettes (which one shows is the card colors setting, Palette above, not the theme), the player colors, what each color means (the meaning table above; the light theme may use other shades of the same color for contrast), the QR tile (dark modules on white), the layouts, sizes and animations
> - **Every page the app renders** takes the theme: the landing, How to play, the join page, the big screen, the player screen and the byline footer, which uses the light logo colours in the light theme and the dark ones in the dark theme (§8, Byline footer). The static error pages in `public/` stay dark

What this means for the drawing: every themed color must be expressible as one CSS value per theme on the same markup. A light board may not add, remove or move an element the dark one has; it changes colors (and may add the card wrapper's edge).

### SPEC §10 Visual system, surfaces and contrast

> Two themes, dark and light, on every page the app renders (Themes below). In the dark theme the cards are the only bright surfaces.

> Surfaces, dark theme: page `gray-950`, panels `gray-900`, borders `gray-700`/`gray-800`. Secondary text `gray-400`, muted `gray-500` (not `gray-600`, which fails contrast on `gray-950`). The light theme's surfaces, borders and text shades come from the design pass (`docs/design-system.md`), held to the same contrast: body and secondary text at least 4.5:1 on their ground, as the white-on-color rules in the meaning table below are.

> Each color means one thing everywhere:
>
> | Color | Meaning |
> |---|---|
> | blue-600 | SET! and primary actions |
> | violet-600 | quick game |
> | yellow-400 | a claim in progress (big screen panel, scoreboard entries, player screen claim bar) |
> | purple | No Set. It used to be red; red now only means wrong or locked |
> | red | wrong claim, timeout, lockout |
> | green | ready, correct, start, play again (`green-700` for white text; `green-600` is only about 3.3:1) |
> | orange | deck empty and the End game vote (`orange-700` for white text; `orange-600` is only about 3.3:1) |
>
> Player colors are the 8 presets in `PlayersController::PRESET_COLORS`, deliberately apart from both card palettes (Palette above). They show as dots, the player screen's top border strip and podium bars.

> QR codes: dark modules on a white tile. Inverted codes fail on some phone cameras.

### SPEC §10 Palette

> Two card palettes. Each browser picks one in the settings menu (§8, Settings menu), under **Card colors**:
>
> - **Classic** (the default): Set's own red, green and purple, far apart in hue so they read at a glance. The exact shades come from the design pass (`docs/design-system.md`). Each stays clearly apart from the other two, reads on the card face, and stays apart from the player colors, which already hold a red, a green and a purple of their own (`PlayersController::PRESET_COLORS`).
> - **Color-blind**: the IBM colorblind-safe palette, the one every card used before Classic: **Blue** `#648FFF`, **Orange** `#FE6100`, **Magenta** `#DC267F`. It also draws a **color mark** on every card: one small mark per color, the same on every card of that color, so the three colors can be told apart without seeing color at all. The mark never changes the shapes, their number or their shading, the card's other three features, and cannot be mistaken for one of them. It sits inside the card's SVG, so card sizes and every layout stay as they are. Its form and place come from the design pass.
>
> Card color 0, 1 and 2 (§4, Card) are red, green and purple in Classic and blue, orange and magenta in Color-blind, so a Set is the same Set under both.
>
> - **Stored per browser**, as the theme is (Themes below): a `card_colors` cookie, `colorblind`, path `/`, a year long, SameSite Lax, not HttpOnly so the settings menu can write it. Classic deletes it. The layout renders the choice on `<html>`, so the first paint already has the right colors
> - **Never in a broadcast.** Cards render inside Turbo Stream partials shared by every screen in a room (§7), so the `_card` partial draws the same markup for every viewer: the card colors come from CSS keyed on `<html>`, and the color mark is always in the markup, shown only under Color-blind
> - **Picking applies at once** to every card on the page, with no reload, as a theme does. Other open tabs take it on their next page load
> - **Independent of the theme**: each palette, and the color mark, is the same in the dark and light themes
> - **Everywhere a card renders**: the big screen board and announcement band, the player screen board, tray and found-set banner, the landing's fanned cards and the How to play diagrams. Words that name a card color follow the setting the same way, both versions in the markup and CSS showing the one that matches: How to play's color captions (red, green, purple or blue, orange, magenta) and its Not a Set example ("two red, one green" or "two blue, one orange")
>
> Card face, the same under both palettes: near-white (`#FAFAFA`). Card border: subtle, `#E5E5E5`. Selected card on the player screen: `ring-4 ring-blue-400 scale-95`.

Player presets (`PlayersController::PRESET_COLORS`), which the Classic shades must stay apart from: `#E74C3C #2ECC71 #F1C40F #9B59B6 #1ABC9C #E91E63 #00BCD4 #8BC34A`.

SPEC §16 Open items: "Color presets for player choice (8 distinct hex values that don't collide with the card palettes; the Classic card shades are picked apart from them, §10 Palette)."

### SPEC §10 Component (the card)

> Single ERB partial: `app/views/cards/_card.html.erb` taking a `card:` local. Renders an SVG with a `viewBox` of `0 0 200 280`. Inside:
>
> - Rounded rect background.
> - Stack of `card.number + 1` shapes (1, 2, or 3) centered vertically.
> - Each shape is one of:
>   - **Oval**: ellipse.
>   - **Squiggle**: a fixed `<path>` with the canonical Set squiggle curve (hardcoded).
>   - **Diamond**: rotated square (rhombus path).
> - Shading:
>   - **Solid**: `fill=color`.
>   - **Outline**: `fill=none stroke=color stroke-width=5`.
>   - **Striped**: `fill="url(#stripes-#{color}-#{suffix})"`, a 40° hatch of 3.5px lines on a 7px pitch. [...]
>
> The SVG fills its wrapper; wrappers set the size with a 5:7 aspect ratio. The partial is never restyled, only sized; its colors and color mark follow the card colors setting through CSS alone (Palette above).

The card's geometry as built, so the mark can be placed: the face is a 200×280 rect with 12 corner radius, `#FAFAFA` fill and a 2-unit `#E5E5E5` stroke. Shapes are 110 wide (x 45 to 155) and 56 tall, 72 apart, centred on y 140: with three shapes they span y 40 to 240, so the free space is the bands y 0 to 40 and 240 to 280, full width, and the side strips x 0 to 45 and 155 to 200. The mark must survive at a 54×76 card (about 0.27 scale, so 40 units is about 11 px), and its shading-free look must not read as a fourth shape, a number or a stripe.

### SPEC §8 Views & UX, shared

> Colors, type, animations and the two themes are in §10. Hook ids and Stimulus attributes that must survive markup changes are in §7. Every page the app renders carries the settings menu (Settings menu below).
>
> **Width.** The game screens, the big screen and the player screen, use the whole window. A content page, today only How to play (`/how-to-play`, §5), holds its content in a centred 944px box (`mx-auto max-w-[944px]`) with the side gutter on an outer wrapper (`px-5 sm:px-8 lg:px-10`: 20px, 32px from 640px, 40px from 1024px), so the gutter never narrows the box; below 1024px wide the box is the window less the two gutters. [...] Running prose on a content page (the intro under the headline, a section's intro line, the statement under What makes a Set) is capped at `max-w-[65ch]`, so its lines stay readable at any width; headings, the card diagrams and the panels that hold them use the whole box, and text inside a panel, already narrower than 65ch, takes no cap of its own. The byline footer sits in the same box (Byline footer below).

### SPEC §8 Landing

> One page for phones and desktops, split at `lg:` (1024px and up): the actions card is 448px wide, and the brand column needs that much room for the wordmark and the fanned cards. Below `lg:` the phone layout stacks, tablets included. Side by side, nothing in the brand column runs past its own width into the actions card: the fanned cards and the wordmark shrink with the column at narrow desktop widths and are full size from 1280px. Brand on the left: the **Onset** wordmark, a one-line tagline and three fanned cards that form a Set, with a caption saying why. [...]
>
> - A two-option toggle, **Standard** (selected by default) and **First to 5**, above one **Start a game** button with the sub-line "Play from this screen, then invite the others". [...]
> - **Have a room code?** field plus **Join**. `GET /join?code=` upcases the code and redirects to the room's join page, or back to the landing with "Room not found" under the field, which comes back empty with a red border.
>
> On phones the join form comes first, since joining is what phones come here for.

### SPEC §8 Join page

> Portrait. "Joining room" with the code in large type, since the code is what people check. [...] **Your name** (max 20). **Pick a color**: a 4×2 grid of swatches that select with a white ring and ✓, no JS. Taken colors are faded with the taker's initial. [...] With every color taken the room is full: none is selected, the red base error box says "This room is full" and **Join** is disabled. [...] **Join** sits at the bottom, under the thumb. In the browser that created the room (its `host_game` cookie matches), a **Use this screen as the big screen instead** text link sits under Join [...]. Field errors show under their field; base errors (game already started) in a red box.

In the light theme the selected swatch's "white ring offset by `gray-950`" and the taken swatch's "preset blended 30% over `gray-950`" need light counterparts: say which in the light theme sheet.

### How to play (`/how-to-play`), as built

No board exists. From SPEC §5: "The rules page, linked from the landing and the player screen. With `?game=` holding a room code, **← Back** and the closing **Back to the game** go to that room's player screen; with anything else, or no code, Back goes to `/` and the closing section offers **Start a game** and **Join with a room code** instead." Draw it in the content-page box above (944px, prose at 65ch). Top to bottom, as the code renders it today (dark):

- A nav row: "← Back" (`gray-300`, 14px semibold) on the left, the "Onset" wordmark (display, 20px extrabold) on the right
- Header: "HOW TO PLAY" (14px uppercase, widest tracking, `gray-400`); h1 "Find three cards that make a Set." (display, 48px, 72px from `md:`, extrabold, 1.05 leading); intro "Onset is the card game Set, played live. Everyone plays on their own phone or computer, sees the same cards and races to spot a Set. A big screen the whole table can see is optional." (18px, 20px from `md:`, `gray-300`)
- "Every card has four features" (display h2, 30px, 36px from `md:`), "Each feature comes in three versions, which makes 81 different cards." (`gray-400`), then four `gray-900` panels (24px radius) in a 2-column grid from `md:`: Number, Shape, Shading, Color, each a small uppercase `gray-400` label and three cards (112px tall, 144px from `md:`) with captions (14px `gray-300`): 1, 2, 3; oval, squiggle, diamond; solid, striped, outline; and the Color captions, which follow the card colors setting (red, green, purple or blue, orange, magenta)
- "What makes a Set", the statement "Three cards where each feature is either **all the same** or **all different**." (display 24px/30px bold, the two phrases `green-400`), then two `gray-900` panels with a `green-500` ring at 40%: "✓ A Set: some features the same" and "✓ A Set: everything different" (`green-400` semibold), each three cards (128px, 160px from `md:`) and a list of the four features, label `gray-400`, value `gray-200` ("all different", "all the same") with a `green-400` ✓
- "Almost, but not a Set": one `gray-900` panel with a `red-500` ring at 40%, three cards beside "✗ Not a Set" (`red-400`) and the four features, Color highlighted on a `red-500` 10% row with `red-300` label and `red-200` value "two red, one green" (Classic) or "two blue, one orange" (Color-blind) and a `red-400` ✗; under it two `blue-500` 10% panels with a `blue-500` ring at 40%: "Quick check" ("If two cards share something and the third doesn't, it's not a Set.") and "Tip" ("Pick any two cards. Only one card in the whole deck completes them, so look for that one."), titles `blue-300`, text `gray-200`
- "Playing Onset": four numbered `gray-900` panels (number in display 36px `blue-400`, title 20px bold, text `gray-400`): 1 "Join on your screen", 2 "Look for a Set", 3 "Tap [SET! pill, `blue-600`]", 4 "Score" with "Right: +1" in `green-400` and "Wrong or out of time: −1, but never below 0" in `red-400`; under them two outlined panels: "No Set on the table?" (`purple-800` ring, title `purple-300`) and "End of the game" (`gray-800` ring)
- "Ready to play?": a `gray-900` panel, centred, with "Start a game" (`blue-600`, 56px tall, 16px radius) and "Join with a room code" (`gray-800`), or with a room code, "Back to the game" alone
- The byline footer

### SPEC §8 Byline footer

> A small muted footer, the same across all of joaotorr.es's apps, so its look and behaviour follow that shared design rather than this spec's palette. It must stay quiet and never compete with the Onset wordmark.
>
> - **Where**: after `main` on the landing, How to play and the join page, centred in the content-page box [...]. On the page's own ground, `gray-950` in the dark theme (§10, Themes). [...] The big screen and the player screen have none [...]
> - **What**: "by joaotorr.es", one link to https://joaotorr.es that opens in a new tab [...]
> - **At rest**: `gray-400`, 14px, weight 500, the body font, with one continuous 1px red underline under the whole phrase. The link is 44px tall for touch.
> - **Hover (devices with hover) or keyboard focus**: [...] the dot hops up and lands with a small bounce, turning gold, while "joaotorr" fades to a green to blue gradient and "es" to a red, gold, red stripe. [...] Keyboard focus adds a 2px `blue-500` outline.
> - **Logo colours**: the dark values in the dark theme: green `#22C35E`, blue `#5B8CFF`, red `#FF4F5E`, gold `#FFD21F`. The light values in the light theme: `#009C3B`, `#002776`, `#C60B1E`, `#E08A00`, the ones on `:root`. The at-rest `gray-400` text and the red underline take the light theme's shades from the design pass, at the same contrast.

### SPEC §8 Player screen

> Full height, no page scroll. A strip of the player's color across the top, "Room CODE" footer. The player screen stands alone (§1): in every playing state it shows the board, the scoreboard and the deck count, so a room needs no big screen. [...] Three layouts, chosen by the viewport alone, whatever the input:
>
> - **Portrait** (narrower than tall, under 1024px wide): the scoreboard across the top, the board under it at the full width, then the state's panel, SET! and its pill at the bottom, under the thumb.
> - **Landscape** (wider than tall, under 1024px wide): three columns, the board on the left, a 9rem action column, a scores column.
> - **Computer** (1024px wide and up, Tailwind `lg:`): a board-sized card grid on the left and a side column with the scoreboard stacked above the state's panel, SET! and its pill, so the board keeps the width.

> - **Deck**: "N cards left in the deck" under the board, centred on it, or an orange "Deck is empty" pill once it runs out. In the computer layout the "Room CODE" footer sits directly under that line, centred on the board as well, so the two lines share one centre and nothing sits under the side column. Portrait and landscape keep the footer centred on the screen, and so do waiting and game over in every layout, since they show no board.
> - With 8 players and 18 cards there is no page scroll at 375×667 portrait, 667×375 landscape and 1024×640 computer, in every state: the cards shrink to fit.
>
> SET! sits in the same fixed slot across idle, locked out, someone else claiming and the No Set countdown, so the thumb never has to move.

Waiting (state 1): "With 8 players and the invite there is no page scroll at 375×667 portrait, 667×375 landscape and 1024×640." The QR sheet: "Any room update (someone joins or votes) re-renders `#controller_status` and closes the sheet" (the settings menu, outside it, does not close). Game over (state 8): "With 8 players, one per preset color, the screen keeps no page scroll at 375×667 portrait, 667×375 landscape and 1024×640 computer."

Locked out (state 6): "SET! becomes the lockout countdown with "Locked": `Game::CLAIM_TIMEOUT` seconds" (15 s). Game over winner line: "★ Alex wins with 9", "★ You win with 9" when the player is the sole winner, or "★ Tied for first at 9"; "The rank is the shared one on a tie, a plain ordinal ("1st", never "=1st")".

### SPEC §8 Big screen

> Full screen, built for a TV at 2m, and must also fit a laptop down to 1280px wide. Two columns: the play area (`#board` over `#announcement`) and a 26rem right rail with the room tile (room code and the site address to open, `join_host`, no QR) and the **Players** scoreboard. The room tile is hidden while waiting, since the join hero carries the code, and appears once the game starts without a reload. The join hero holds the only QR on the screen [...].
>
> - **Scoreboard**: rows sorted by score, dot, name, big score. The claiming player's row turns solid yellow. A locked-out player is greyed with a red **Locked** tag.
> - **Waiting**: a join hero with a 288px QR and, under it, a **Join from this computer →** link [...]. Beside the QR, "Scan to join, or open HOST and enter" and the room code at up to 10rem, shrinking with the viewport [...]. Player pills with a ✓ once ready. `#start_button`: **Start game** with "n of m ready" beside it, or disabled with "Need at least 2 players".
> - **Playing**: "N cards left in the deck" top right, or an orange "Deck is empty" pill. The card grid (§10). Cards dealt by the last replace get a green outline that fades over 3s.
> - **Announcement band**: always 9rem tall so the grid never jumps. Empty while playing: "Spot a Set? Hit SET! on your screen." Otherwise one tinted panel:
>   - Claiming (yellow): countdown ring, "Alex is calling SET!".
>   - No Set (purple): ring, "Alex called No Set", "Agree on your screen, or find one first", and "n/m agreed".
>   - Refused (purple): ring counting the block down, "Alex says there's a Set", "No Set is back when the ring runs out". [...]
>   - Correct (green): the three cards, "Alex found a Set", "+1". Fades after 3s.
>   - Wrong / Time's up (red): the cards for a wrong claim, the reason with the lockout length, "−1".
> - **Ended**: "Game over", then "Alex wins" or "It's a tie". Podium in 2-1-3 order; bars carry the real rank, so a tie reads #1 #1, and only a sole winner gets the ★. **Play again**, which restarts the room at once whatever the player screens have voted.

The big screen as built (dark), for the boards with no dark counterpart: `gray-950` page, 40px padding, 40px gap, the play column and a 26rem rail. Waiting: a white QR tile (24px radius, 24px padding, 288px QR) with "Join from this computer →" under it (24px semibold `blue-400`); beside it "Scan to join, or open **onset.joaotorr.es** and enter" (30px `gray-300`, host in white semibold), the code (display bold, up to 160px, 0.12em tracking) and "New to Set? The rules are at **onset.joaotorr.es/how-to-play**" (24px `gray-400`); under them player pills (`gray-900`, 16px radius, 30px semibold, a 20px dot, not-ready names `gray-400`, a `green-400` ✓ once ready); then Start game (`green-700`, 96px tall, 24px radius, display 36px bold) with "**2** of 4 ready" (30px `gray-400`), or disabled `gray-800` with `gray-500` text and "Need at least 2 players". Rail: "PLAYERS" (18px uppercase `gray-400`) over score rows (30px semibold names, display 48px scores; claiming row solid `yellow-400` with `gray-950` text; locked row `gray-500` with a `red-500` 15% pill "Locked" in `red-400`); "No one yet" in `gray-500` when empty; once playing, the room tile above it (`gray-900` panel, "ROOM" label, code in display 48px, host in `gray-400`). Band panels: 24px radius, 2px inset ring, tints at 10% (yellow-400, purple-500, green-500, red-500) with names in the 400 shade, display 48 to 60px headlines, `gray-300` 24px sub-lines, `+1` and `−1` in display 72px `green-400` and `red-400`; the empty band text is 24px `gray-500`. Deck line: "**N** cards left in the deck" (20px `gray-400`, the number display 30px white) or an `orange-500` 15% pill with an `orange-500` ring at 40%, "Deck is empty · play out the remaining cards" in `orange-400`. Ended: "GAME OVER" (24px, 0.3em tracking, `gray-400`), "Alex wins" or "It's a tie" (display 96px extrabold), the podium (224px columns, a `yellow-400` ★ over the sole winner, name, "N pts" in `gray-400`, bars in the player's color at 85% with the rank "#1" in display bold, heights 224/144/96), then Play again (`green-700`, 80px tall, display 30px bold).

### SPEC §17 Custom events (no visual effect, for the menu's behaviour)

> | `theme_changed` | `theme`: `device`, `light` or `dark`, the option picked | The settings menu (§8), when the player picks a theme other than the one already chosen |
> | `card_colors_changed` | `card_colors`: `classic` or `colorblind`, the option picked | The settings menu (§8), when the player picks card colors other than the ones already chosen |

## Design rules, quoted from docs/design-system.md v5

Note: the `Shared: Visual rules` part below quotes SPEC §10 as it stood before tickets 40 and 41. Where it differs from the Spec facts above (the palette, "Dark UI", the surfaces), the Spec facts win; the design entry after this brief updates it.

### Shared: Tokens

> From `app/assets/tailwind/application.css` (`@theme`), on top of the Tailwind default palette:
>
> | Token | Value | Use |
> |---|---|---|
> | `--font-display` | Bricolage Grotesque, ui-sans-serif, system-ui, sans-serif | Display text only |
> | `--animate-shake` | `shake 0.4s ease-in-out 1`, ±8px | Locked-out player screen panel |
> | `--animate-arrive` | `arrive 3s ease-out forwards`, green-400 outline to transparent from 50% | Cards dealt by the last replace |
> | `.found-set-flash` | `found-set-fade-out 3s`, opaque until 50% | Correct-claim panels and the found-set banner |
>
> Card palette (`app/views/cards/_card.html.erb`): blue `#648FFF`, orange `#FE6100`, magenta `#DC267F`.
>
> Player colors (`PlayersController::PRESET_COLORS`): `#E74C3C #2ECC71 #F1C40F #9B59B6 #1ABC9C #E91E63 #00BCD4 #8BC34A`.
>
> Byline logo colours (v3, `--wm-*`): light on `:root` green `#009C3B`, blue `#002776`, red `#C60B1E`, gold `#E08A00`; dark on `.byline-footer`, the values every Onset screen uses: green `#22C35E`, blue `#5B8CFF`, red `#FF4F5E`, gold `#FFD21F`.
>
> v2 adds no tokens: every new color is from the Tailwind default palette.

### Shared: Rules added in v2

> - White text on green uses `green-700` (`#15803D`); `green-600` is about 3.3:1, as with `orange-700`. I'm ready and Play again on the player screen
> - Filled purple pills (No Set, I agree, no Set) use `purple-700` with white text. The waiting text after agreeing is outlined `purple-500` with `purple-200` text
> - Card face `#FAFAFA` with a `#E5E5E5` border. Selected: a 4px `blue-400` ring and scale 0.95. Arrive: a 3px `green-400` ring
> - Taken color swatch: the preset blended 30% over `gray-950` with the initial in `gray-300`, not opacity, which would fade the initial too
> - Player screen card size, in every layout: `cw = floor(min((boardW - (cols - 1) * gap) / cols, ((boardH - 2 * gap) / 3) * 5 / 7))`, `cols = cards / 3`, gap 5px on phones and 12px on computer. At 8 players and 18 cards: portrait 54×76, landscape 55×77, computer 106×148. Portrait at 3 players and 12 cards: 71×99. Landscape shrinks the cards to fit the width, with no sideways scroll; at 12 cards they fill the height
> - SET! slot 128×128 in every layout, the button 104px (108px on computer). Ring states put a 128px ring around a 100px disabled `gray-800` button
> - Portrait keeps the status slot at 64px in every state, so the board never resizes on a state change
> - Copy link feedback stays neutral gray: green and red are reserved by the meaning table

### Shared: Rules added in v5

> - A disabled filled pill keeps its label legible: the fill at 35% with the light tint of its color as text at full opacity (blocked No Set: `purple-700` at 35%, `purple-200`; disabled Submit: `blue-600` at 35%, `blue-200`), never the whole button faded

### Shared: Visual rules (quoting SPEC §10 before tickets 40 and 41)

> #### Palette
>
> Colorblind-safe (IBM 3-color palette):
>
> - **Blue**: `#648FFF`
> - **Orange**: `#FE6100`
> - **Magenta**: `#DC267F`
>
> Background: near-white (`#FAFAFA`). Card border: subtle, `#E5E5E5`. Selected card on the player screen: `ring-4 ring-blue-400 scale-95`.

> - **Big screen grid**: 3 rows flowing into columns, centered, no horizontal scroll at 18 cards. Cards are `15rem` tall at 1080px and shrink with the viewport (`min(15rem, (100dvh - 22rem) / 3)`) so the third row never runs under the announcement band.
> - **Player screen, portrait**: in every playing state the grid fits the width (`auto-cols-fr`) and shrinks to the height left, so SET! and its pill never leave the screen.
> - **Player screen, landscape**: 3 rows flowing into columns, the cards shrinking to fit the board's width and height, with no sideways scroll; at 12 cards they fill the height.
> - **Player screen, computer**: 3 rows flowing into columns, sized to the board's width and height, no horizontal scroll at 18 cards.
>
> On the player screen, in every layout, a card takes the largest size at which `cards / 3` columns fit the board's width and 3 rows its height, with a 5px gap on phones and 12px on computer.

> #### Visual system
>
> Dark UI where the cards are the only bright surfaces. Tailwind default palette plus these tokens in `app/assets/tailwind/application.css`:
>
> - `font-display`: Bricolage Grotesque (Google Fonts link in the layout). Only for display text: wordmark, room code, scores, SET!, headlines, countdown digits. Body copy stays on the default sans.
> - `animate-shake`: once, 0.4s. Locked-out player screen panel.
> - `animate-arrive`: green outline that holds 1.5s and fades by 3s. Cards dealt by the last replace (`Game#last_dealt`), on the big screen and the player screen board.
> - `.found-set-flash`: holds 1.5s, fades by 3s. Correct-claim panels on the big screen and the player screen.
>
> Surfaces: page `gray-950`, panels `gray-900`, borders `gray-700`/`gray-800`. Secondary text `gray-400`, muted `gray-500` (not `gray-600`, which fails contrast on `gray-950`).

> Countdown rings: `r=45` in a 100 viewBox, gray track, colored progress with round caps, rotated -90° so they drain clockwise from the top. Seconds sit inside the ring, or inside the button the ring surrounds.
>
> QR codes: dark modules on a white tile. Inverted codes fail on some phone cameras.

### Components

> ERB partials, no component library.
>
> - `cards/_card`: the card SVG, 200×280 viewBox, sized only by its 5:7 wrapper
> - `games/_ring`: big screen countdown ring, size-24, seconds inside
> - `games/_scoreboard`: big screen score rows, sorted by score
> - `games/_start_button`: Start game with "n of m ready", or disabled with the reason
> - `games/_announcement`: the 9rem announcement band and its tinted panels. Refused (v4): the No Set panel's tint, ring and type; the ring counts the block down (`purple-400` progress, `purple-300` seconds), "Alex says there's a Set" in 48px display bold with the name in `purple-400`, "No Set is back when the ring runs out" in 24px `gray-300`, nothing on the right. At 1280px wide the headline wraps onto two balanced lines inside the band, as "Alex called No Set" does
> - `players/controller/_header`: header with dot, name and score, on Waiting and Game over
> - `players/controller/_board_strip`: the play card grid with the deck line, sized by the card size rule in portrait and landscape
> - `players/controller/_button_ring`: thin ring around the round SET! button
> - `players/controller/_small_ring`: countdown ring with seconds, any size
> - `players/controller/_secondary_action`: the pill under SET!: No Set, the End game vote, or during a No Set countdown I agree, no Set (filled purple) or the waiting text (outlined purple). v4 variants:
>   - refusal pair, while the player may refuse: two equal pills side by side, There's a Set on the left (outlined, 2px `purple-400` border, no fill, white bold text), I agree, no Set on the right (filled `purple-700`, white text). The pair fills its column: portrait the status slot's width (351px at 375, 8px gap, 16px labels), landscape the 9rem column (two 69×44 pills, 6px gap, 13px labels on two lines), computer 248×46 (two 120px pills, 8px gap, 15px labels). SET! does not move. Once this board's refusal is used, the lone I agree, no Set sits as before (220×44 in portrait, centered)
>   - blocked No Set, after a refusal: the No Set pill at its usual size (portrait 220×44, landscape 144×44, computer 248×46), disabled, `purple-700` at 35% with `purple-200` text, "No Set in 12 s" with the seconds in display type. The block's seconds show only here, not in the status panel
> - `players/controller/_submit` (v5): the Submit pill in the pill slot during the player's own claim, at the slot's usual size (portrait 220×44, landscape 144×44, computer 248×46), body font 16px/700 (15px in landscape). States:
>   - disabled, fewer than 3 picks: `blue-600` at 35% with `blue-200` text, "Submit"
>   - enabled, exactly 3 picks: `blue-600`, white text, "Submit", glow `0 0 24px rgba(37, 99, 235, 0.55)` (SET!'s glow without the 8px ring)
>   - submitted, from the tap until the resolving broadcast: `blue-600`, white text, disabled, an inline check icon (18px, stroke 3) then "Submitted", `aria-label` "Submitted, waiting for the result". Full strength, not the disabled look, so a frozen screen reads as sent, not as not yet allowed
> - `players/controller/_scoreboard` (v2): the play scoreboard, every player in score order. Portrait: chips, 4 per row, at most 2 rows, the Locked tag a red badge on the chip's top-right corner. Landscape and computer: one row per player, the Locked tag inline before the score. Own entry `gray-800` with a `gray-500` border; claiming entry solid `yellow-400` with `gray-950` text; locked entry content at 45% opacity
> - `players/controller/_status_panel` (v2): one fixed slot above SET!, portrait 64px tall, landscape 144×104, computer 248×76. Variants:
>   - claim bar: `yellow-400`, ring, "Your SET!", "Tap 3 cards", n/3
>   - someone else claiming: `gray-900` with a `yellow-400` border, "Alex is calling SET!"
>   - No Set: `purple-950` with a `purple-500` border, ring, "No Set called by Alex", "n/m agreed"
>   - locked out: `red-950` with a `red-600` border, "Wrong! −1" or "Time's up! −1", `animate-shake`
>   - refused (v4): `gray-900` with a `purple-500` border, laid out as someone else claiming in each layout: the refuser's dot, the name bold and "says there's a Set" in `gray-300`. No ring. `gray-900`, not `purple-950`, so it does not read as a call still running
>   - idle: empty, the slot keeps its size
> - `players/controller/_found_banner` (v2): `green-950` panel with a `green-500` border, the 3 cards small, the caller's dot, "Alex found a Set" and "+1" in `green-400`. Absolutely positioned over the top of the board area, over the scoreboard in portrait. `pointer-events: none`, `.found-set-flash`
> - `players/controller/_roster` (v2): the Waiting roster, two columns, each a dot, the name, "you" for the player and a `green-400` ✓ once ready
> - `players/controller/_invite` (v2): the room code in display type, "or open onset.joaotorr.es and enter the code" (`join_host`), the link button (Copy link, Copied ✓, Couldn't copy, Share link), a Show QR button and the "Show on a big screen →" text link
> - `players/controller/_qr_sheet` (v2): overlay `gray-950` at 85%. Portrait: a bottom sheet. Landscape: a centered card, QR on the left, code and Done on the right. Computer: a centered 352px modal. QR on a white tile, 288px in portrait and computer, 300px in landscape, the code under it, Done in `blue-600`
> - `players/controller/_standings` (v2): game over rows, each rank, dot, truncated name, "you" for the player, score. Own row `gray-800` with a `gray-600` border, other rows transparent. Rows 32px portrait, 34px landscape, 44px computer (computer list in a `gray-900` panel)
> - Landing mode toggle (v2): two radios styled as a segmented control inside the Start a game form, on a `gray-950` (desktop) or `gray-900` (phone) track with a `gray-700` border. Selected Standard `gray-700`, selected First to 5 `violet-600`, unselected `gray-400` text on transparent
> - `layouts/_byline_footer` (v3): "by joaotorr.es" after `main` on the landing, How to play and the join page, never on the big screen or player screen. `gray-400` 14px weight 500 with a 1px red underline; on hover or keyboard focus the dot hops and the domain fades into the logo colours (`--wm-*`), held until the next page load. Styles in `app/assets/tailwind/application.css` (`.byline`, `.wm-*`), fixed across joaotorr.es apps
> - Stimulus: `card-selection` (picks sent to the server, tray, count, Submit and the freeze after it), `countdown` (rings and seconds)

### Screens

> Drawn for v2. Sizes are the boards': portrait 375×667, landscape 667×375, computer 1024×640, landing desktop 1280×800.
>
> #### Landing (ticket 08)
>
> - Desktop: brand on the left (wordmark 136px, tagline 24px `gray-300`, three fanned cards with the caption in `gray-400`), actions on the right in a 448px `gray-900` card with a `gray-800` border: the mode toggle, Start a game (`blue-600`, 60px, display type), its sub-line in `gray-400`, a divider, then "Have a room code?", the code field and a `gray-800` Join button
> - Phone, top to bottom: wordmark and tagline, the join form, a divider, the mode toggle and Start a game, then the fanned cards and caption at the bottom
> - Room not found: "Room not found" in `red-400` under the code field, the field empty with a `red-500` border
>
> #### Join page (ticket 08)
>
> - "Joining room" in `gray-400`, the code at 60px in display type
> - Base error (game already started): a `red-950` box with a `red-700` border and `red-200` text, under the code
> - Field errors in `red-400` under their field, the field with a `red-500` border
> - Color grid 4×2, 56px swatches. Selected: a white ring offset by `gray-950`, with a white ✓. Taken: the preset blended 30% over `gray-950`, the taker's initial in `gray-300` in display type
> - Join at the bottom (`blue-600`, 56px). For the creating browser, "Use this screen as the big screen instead" under it as a `blue-300` text link
> - Full room (every color taken, triage 08): "This room is full" in the base error box, no swatch selected, Join disabled as `gray-800` with `gray-500` text, as the big screen's disabled Start game. Wins over the join-full board, which shows no message
>
> #### Player screen, Waiting (ticket 10)
>
> - Header, then "You're in", the roster, the invite and I'm ready (`green-700`). Once voted: "Ready ✓ · waiting for n more" as outlined `green-700` text on a 12% `green-700` tint, `green-300` text
> - Landscape and computer put the roster and the invite side by side
> - The link button's feedback states (Copied ✓, Couldn't copy) stay neutral gray
> - The QR sheet is `_qr_sheet`; the "Room CODE" footer stays
>
> #### Player screen, during play (ticket 09)
>
> - Portrait, top to bottom: the scoreboard, the board at full width, the status slot (64px, empty in idle), the 128×128 SET! slot and its pill
> - Landscape: the board on the left, a 9rem action column (status panel, SET!, pill), a scores column
> - Computer: the board on the left; a 248px side column with the scoreboard stacked above the status panel, SET! and its pill
> - Deck: "N cards left in the deck" with the board, or an orange "Deck is empty" pill
> - Claiming (mine): portrait, the claim bar takes the status slot and the 3-slot tray and Submit replace SET! and its pill. Landscape and computer: one yellow block replaces the panel and SET!, and Submit takes the pill slot (v5)
> - Portrait tray (v5): a 128px row of three 72×101 slots, 14px apart, above the 44px pill slot holding Submit, 4px between, 176px in all, the height SET! and its pill take, so nothing else moves. An empty slot is a dashed `gray-700` box with its number (1, 2, 3) centred in display type, 22px/700, `gray-500`; a filled slot shows the picked card. Slots fill in pick order
> - Submitted (v5): the board's cards are disabled, the three picks keep the selected ring, the tray and the n/3 count stay as at 3/3, the countdown ring keeps draining and Submit shows its submitted state. The board never dims, at 3 picks or after the tap
> - Someone else claiming: the disabled SET! shows the seconds large with a small "SET!" label under them, inside the yellow ring
> - Read-only boards (someone else claiming, No Set, locked out) are not dimmed
> - No Set countdown, may refuse (v4): the No Set status panel, SET!, and the refusal pair in the pill slot. Locked out at the same time: the No Set panel keeps the status slot, since the call is the news; SET! shows the lockout ring with the seconds and "Locked", as in Locked out, and the chip shows the Locked tag
> - No Set blocked after a refusal (v4): idle with the refused status panel and the blocked No Set pill; SET! stays round blue and enabled
> - Found-set banner: in portrait it covers the scoreboard for its 3s; the board under it shows the replaced cards with the arrive outline
>
> #### Player screen, Game over (ticket 07)
>
> - Header, the rank in display type (64px portrait, 60px landscape, 120px computer), "of N players · P points" in `gray-400`, the winner line, the standings, Play again (`green-700`) or "Ready ✓ · waiting for n more" as on Waiting
> - Landscape: rank, winner line and Play again in a 250px left column, the standings on the right
> - Computer: a 360px left column, the standings in a `gray-900` panel on the right
> - The standings scroll inside themselves when they do not fit; the page never does

### Open questions in the design system that touch these boards

> - The Locked out boards (`-wrong`, `-timeup`) still draw the 5-second ring, though lockout is 15 s since ticket 20. Redraw them in the next brief that touches lockout
> - Answered by triage 07 in SPEC §8 Player screen > 8. Game over: a tied rank stays a plain "1st", and the winner line reads "★ You win with 7" when the viewer wins, as the code already does. Redraw the -win boards to match in the next brief that touches game over

On the new light boards, draw the lockout ring at 15 s and the winner line as SPEC says. Leave the dark `-wrong`, `-timeup` and `-win` boards alone.

## Boundaries

- Change no existing board. Every board in this brief is new, placed beside the existing ones under new section titles in `project/canvas.json`
- The existing dark boards keep their layout and are the source for each light board, except where the code has moved on since they were drawn. For those parts the code is the truth, as described here: the byline footer under the landing and the join page (Spec facts, Byline footer), the landing's fanned cards shrinking with the brand column at narrow desktop widths, the computer layout's "Room CODE" footer directly under the deck line and centred on the board, the 15 s lockout ring, the -win winner line, and How to play's 944px content box
- The light theme recolours only: no element added, removed, moved or resized, apart from the card wrapper's edge SPEC allows. Dark stays exactly as the existing boards draw it, apart from the settings button
- The cards' face, border, shapes and shading are never restyled. The color mark is added inside the card and changes nothing else on it
- The QR tile stays dark modules on white in both themes. Player colors stay the 8 presets
- The settings button never moves SET!, the pill slot or the board, and adds no page scroll to the player screen or the big screen at their board sizes, with 8 players and 18 cards
- Static error pages are out of scope: they stay dark

## Return format

At the end of the work, return exactly this:

```
Design return for tickets 40, 41.

## New tokens
## New components
## New or changed rules
## Decisions the spec does not cover
## Open questions
## Artboards added or changed
```

Write `None` under a heading with nothing in it. Begin the return with the `Design return` line: no command such as `/request` or `/design-entry`, since a pasted command does not run. Under New tokens give every light-theme value and every Classic shade as hex with its contrast ratio; under New components the settings button, the settings menu and the color mark (each mark's form, size and place in the 200×280 viewBox); under Artboards each board's file and the screen and state it shows.

## How every reply ends

```
End every reply with:

1. **Pending decisions:** what you need from me before going on, each
   a bullet with a bold title, explained so I can decide without opening
   anything else, its options numbered with your recommendation first.
   The numbers run on through all the decisions, never restarting, so I
   can answer with numbers alone ("1, 4"). `None` when there are none.
2. Only once the design is done: the line `Paste this into Claude
   Code:`, then the return alone, in the format above, in a fenced
   block of its own. Nothing after that block.
```
