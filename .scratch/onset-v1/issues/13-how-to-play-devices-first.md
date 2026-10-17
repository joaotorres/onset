# 13: How to play describes devices-first play

Status: deployed
Kind: behavioural
Blocked by: 16
Model:
Effort:
Changelog: How to play explains that everyone plays on their own phone or computer, with the big screen optional.

## Request

How to play: describe devices-first play with the big screen optional

Found while building ticket 12: `app/views/lobbies/how_to_play.html.erb` still describes the old setup (cards "on the big screen", players "from their phone"). ADR 0001 and SPEC §1 now say each player plays on their own screen, phone or computer, with the big screen optional. Use the glossary's "player screen" and "big screen".

## Spec references

No spec change. SPEC §1 Overview > What it is and Terms already cover it: each player plays on their own player screen, phone or computer, the big screen is optional, and every user-facing text says "player screen" and "big screen". §2 Round flow covers the rules the page restates.

## Scope

Only strings in `app/views/lobbies/how_to_play.html.erb`, in elements that already exist: the header paragraph and the bodies and titles of steps 1 to 3 under "Playing Onset". Plus the `GET /how-to-play` request specs in `spec/requests/lobbies_spec.rb`.

Do not touch the card sections, step 4, the No Set and End of the game boxes, the "Ready to play?" section, `LobbiesController#how_to_play`, the landing page or the player screen's "How to play" link. No new elements, classes or layout.

## Acceptance criteria

`GET /how-to-play`:

- The header paragraph reads "Onset is the card game Set, played live. Everyone plays on their own phone or computer, sees the same cards and races to spot a Set. A big screen the whole table can see is optional."
- Step 1 is titled "Join on your screen", body "Start a game, or join one with its room code, link or QR, then pick a name and a color."
- Step 2 body reads "Twelve cards go up on every player screen, and on the big screen if you use one. Everyone sees the same cards at the same time."
- Step 3 body reads "Tap SET! on your screen, then pick the three cards within 15 seconds. Nobody else can call while you pick."
- The page contains none of "Join from your phone", "Scan the code on the big screen", "on your phone", "from their phone"
- The existing `GET /how-to-play` specs (four section headings, Back to the game, unsafe return_to) still pass

## Verification

`bundle exec rspec`

Write first: in `spec/requests/lobbies_spec.rb` under `GET /how-to-play`, one example asserting the four new strings above (header paragraph, step 1 title and body, step 2 body, step 3 body) and the absence of the four old phrases. Assert on text with HTML escaping in mind (`CGI.escapeHTML` or `response.parsed_body`).

## Out of scope

- Mentioning that tapping a card calls SET!
- Telling players how to open the big screen (ticket 08's join page link, ticket 10's invite link)
- Any new box, note or layout on the page, and any other copy on it
- The landing page copy (ticket 08)

## Comments

Decided: no spec change, citing §1 What it is and Terms, because §1 already says how play works and that every user-facing text uses the glossary terms; the page restates §1 and §2 in copy. Instead of: a new §8 How to play heading.

Decided: only existing strings change, with the big screen's optionality folded into the header paragraph and step 2, so the ticket stays behavioural. Instead of: a new "Playing on a big screen" box, which would need the design pass.

Decided: the exact copy in the acceptance criteria, saying "phone or computer" for devices as §1 does and "player screen" and "big screen" for the screens. Instead of: leaving the wording to the builder.

Decided: step 3 says only "Tap SET! on your screen", because card taps call SET! in landscape today and reach every layout only with ticket 09. Instead of: "or tap a card", which would be wrong in portrait until 09 ships.

Decided: blocked by 09, because the copy promises the board on every player screen and portrait player screens hide it outside a claim until 09 ships (`players/controller/_board_strip` is `portrait:hidden`). Not by 08 or 10, since the copy names nothing they add. Instead of: shipping copy that is wrong on phones held upright.
