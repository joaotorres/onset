# Set — Online Multiplayer Spec

A web implementation of the card game **Set**, designed for the "shared screen + phones as controllers" pattern (Jackbox-style). The board displays on a TV or laptop; players connect their phones via QR code and use them to call and submit Sets.

This document is the source of truth for the v1 MVP. It is intentionally tight; favor it over guesses, but flag ambiguities back to the spec rather than inventing.

---

## 1. Overview

**What it is.** Real-time multiplayer Set. One device acts as the **board** (rendering the 12+ cards, scores, and announcements). Each player connects a **phone** (the controller) to claim Sets and pick the three cards.

**Stack.** Ruby on Rails 8, SQLite, Hotwire (Turbo + Stimulus), Action Cable with Solid Cable adapter, Solid Queue, Tailwind CSS, deployed to Render's free tier.

**Non-goals for v1.** No accounts, no AI opponent, no solo/practice mode, no cross-room matchmaking, no native apps.

---

## 2. Game Rules

### The deck

81 unique cards, each defined by four attributes with three values:

- **Number**: 1, 2, or 3 shapes per card.
- **Shape**: oval, squiggle, diamond.
- **Color**: blue, orange, magenta. (See palette in §10.)
- **Shading**: solid, striped, outline.

A card can be encoded as an integer `0..80`, with each base-3 digit corresponding to one attribute. This makes Set validity checkable by digit-wise sum mod 3 (see §4).

### What is a Set

Three cards form a Set if, for **each** of the four attributes, the three values are either **all the same** or **all different**. Equivalently: for cards `a`, `b`, `c` with each attribute value in `{0,1,2}`, `(a + b + c) ≡ 0 (mod 3)` digit-wise.

### Round flow

1. The board shows 12 face-up cards drawn from the deck.
2. Players race to spot a Set.
3. A player taps **"SET!"** on their phone. Server timestamps the request and atomically locks the claim to the first arrival.
4. The claiming player has **5 seconds** to tap 3 cards on their phone.
   - **Correct Set**: +1 point, those 3 cards are removed, 3 new cards are dealt from the deck. Board unfreezes.
   - **Wrong Set**: −1 point, claiming player is locked out for 5 seconds (cannot claim again). Board unfreezes immediately for everyone else.
   - **Timeout (no submission within 5s)**: claim is released. No score change. Board unfreezes.
5. **No Set on the board**: any player can tap **"No Set"**. A 15-second countdown begins, visible on the board and all phones. Resolution:
   - If **all currently active players** join the call before the countdown ends, it resolves immediately.
   - Otherwise, the countdown expires.
   - On resolution: deal 3 additional cards from the deck (board grows to 15, then 18 if called again). Hard cap at **18 cards**.
   - If anyone calls **"SET!"** during the countdown, the No-Set call is **cancelled** and the claim flow begins.
6. **Game end**: when the deck is empty and **no valid Set exists** on the remaining board cards. Show final scoreboard and a "Play again" button (rotates host).

### Edge cases

- A player can call No Set even if they were never going to find one — that's the point.
- Wrong-claim lockout (5s) only prevents that player from calling SET; they can still observe and join No-Set votes.
- If the board grows beyond 12 (after No-Set draws), it stays oversized until a Set is found and removed; replacement cards only re-fill up to 12. Concretely: if board has 15 and a Set is found, board shrinks to 12 (no replacements).
- If the deck runs out mid-game, the board is not refilled. Game continues until no Sets remain on the board.

---

## 3. Architecture

### High-level

- **One Rails process.** Serves HTML, JSON, WebSockets, and background jobs from a single Render web service.
- **SQLite** for primary, cable (Solid Cable), queue (Solid Queue), and cache (Solid Cache) databases. All four files live on the mounted persistent disk.
- **Turbo Streams** drive realtime UI. The server renders ERB partials and broadcasts diffs over Action Cable. Minimal custom JS.
- **Stimulus** for client-only interactions: the 3-card selection on the phone, button countdown timers, the QR widget.

### Why this works on Render free

Solid Cable removes the Redis dependency. SQLite removes the managed Postgres dependency. The whole app is one process, one disk, one deploy.

### Process model

- `web` (Puma): handles HTTP and Action Cable.
- `worker`: Solid Queue worker for cleanup jobs. On free tier, run in-process via the `SOLID_QUEUE_IN_PUMA=true` setting (Rails 8 supports this) so we don't pay for a second service.

---

## 4. Data Model

All models are top-level (no namespacing). Use Rails 8 defaults: `id` as primary key, `created_at`/`updated_at` on every table.

### `Game`

The room.

| Field | Type | Notes |
| --- | --- | --- |
| `code` | string(6) | Uppercase letters/digits, unique, indexed. URL identifier. |
| `status` | enum | `waiting`, `playing`, `ended` |
| `deck` | json | Array of remaining card ids `0..80`, in draw order |
| `board` | json | Array of card ids currently face-up (length 12, 15, or 18) |
| `discard` | json | Array of card ids already collected |
| `host_player_id` | bigint | nullable; the player who created the room |
| `claim_player_id` | bigint | nullable; the player currently holding the claim lock |
| `claim_started_at` | datetime | nullable; for 5s claim window |
| `no_set_started_at` | datetime | nullable; for 15s No-Set countdown |
| `no_set_caller_id` | bigint | nullable; the player who called No Set |
| `no_set_voters` | json | Array of player ids who joined the call (default `[]`) |
| `last_activity_at` | datetime | for 24h idle cleanup |
| `ended_at` | datetime | nullable |

**Validations**: `code` present, unique, matches `/\A[A-Z2-9]{6}\z/` (no `0/O/1/I` to avoid confusion).

**Methods**: `claim_active?`, `no_set_active?`, `can_call_set?(player)`, `valid_set_on_board?`, `dealable?` (deck non-empty AND board < 12).

### `Player`

A participant in a Game.

| Field | Type | Notes |
| --- | --- | --- |
| `game_id` | bigint | indexed |
| `user_id` | bigint | **nullable**; reserved for v1.5 accounts. Designed in now. |
| `session_token` | string | Random hex, stored in player's cookie. Unique per game. |
| `name` | string | 1–20 chars, displayed |
| `color` | string | Hex code, chosen at join. UI offers 8 distinct presets. |
| `score` | integer | default 0 |
| `locked_until` | datetime | nullable; the timestamp until which the player cannot call SET (5s lockout) |
| `last_seen_at` | datetime | updated on every WebSocket ping |
| `left_at` | datetime | nullable; for graceful disconnect |

**Validations**: `name` present, length 1..20. `color` matches a hex pattern. `(game_id, name)` unique-case-insensitive (no two players in the same game can share a name).

**Methods**: `active?` (last_seen within 30s), `locked?`, `host?`.

### `Claim`

Audit record of every claim attempt. Useful for stats, debugging, and replay.

| Field | Type | Notes |
| --- | --- | --- |
| `game_id` | bigint | indexed |
| `player_id` | bigint | indexed |
| `card_ids` | json | Array of 3 ints, nullable until submission |
| `result` | enum | `pending`, `correct`, `wrong`, `expired` |
| `started_at` | datetime | from server clock |
| `resolved_at` | datetime | nullable |

**Validations**: `card_ids`, when present, is an array of exactly 3 distinct integers in `0..80`.

### Card (PORO, no DB)

```ruby
class Card
  ATTRS = %i[number color shape shading].freeze

  attr_reader :id

  def initialize(id) = @id = id

  def number  = id / 27
  def color   = (id / 9) % 3
  def shape   = (id / 3) % 3
  def shading = id % 3

  def self.deck = (0..80).map { |i| new(i) }

  def self.valid_set?(a, b, c)
    ATTRS.all? do |attr|
      vs = [a.public_send(attr), b.public_send(attr), c.public_send(attr)]
      vs.uniq.size == 1 || vs.uniq.size == 3
    end
  end

  def self.any_set_on?(cards)
    cards.combination(3).any? { |trio| valid_set?(*trio) }
  end
end
```

The board and deck columns store integer ids; instantiate `Card` objects in the views as needed.

---

## 5. Routes

```ruby
Rails.application.routes.draw do
  root "lobbies#new"

  resources :games, only: [:create, :show], param: :code do
    member do
      post :start
      post :restart
    end
    resources :players, only: [:new, :create] do
      collection { get :join } # QR landing page
    end
    resource :controller, only: [:show], controller: "controllers" # phone view
    resources :claims, only: [:create, :update]
    resource :no_set, only: [:create, :update, :destroy]
  end

  # Action Cable + health
  mount ActionCable.server => "/cable"
  get "up" => "rails/health#show"
end
```

URL surface:

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/` | Landing: "Start a game" / "Join with code" |
| POST | `/games` | Create room, redirect to `/games/:code` |
| GET | `/games/:code` | Board view (TV) |
| GET | `/games/:code/players/join` | Phone landing after QR scan: name + color form |
| POST | `/games/:code/players` | Create player, set cookie, redirect to controller |
| GET | `/games/:code/controller` | Phone controller view |
| POST | `/games/:code/start` | Host transitions `waiting` → `playing` |
| POST | `/games/:code/restart` | Reset deck, clear scores, status `playing` |
| POST | `/games/:code/claims` | Atomic claim lock (returns 201 or 409) |
| PATCH | `/games/:code/claims/:id` | Submit `card_ids` for a held claim |
| POST | `/games/:code/no_set` | Initiate No-Set countdown OR join existing call |
| DELETE | `/games/:code/no_set` | Withdraw your vote (rare; no UI button v1) |

---

## 6. Round State Machine

A round is the period between deals. Transitions are owned by the `Game` model and **always run inside a transaction with `game.lock!`** to serialize concurrent claim attempts.

```
                     ┌──────────────────────────────────────┐
                     │                                      │
   ┌─── (idle) ──────┼─── claim_lock_acquired ──→ claim_locked
   │                 │                              │
   │                 │  ↑                           │ submit_set
   │                 │  └─── 5s timeout ────────────┤
   │                 │                              ↓
   │                 │                          ┌────┐
   │                 │                          │ ✓  │ correct → score+1, deal
   │                 │                          │ ✗  │ wrong → score-1, lockout
   │                 │                          │ ⏰ │ expired → no change
   │                 │                          └────┘
   │                 │                              │
   │                 │                              ↓ (back to idle)
   │                 │
   ├─── no_set_called ──→ no_set_pending
   │                              │
   │                              │ all_active_voted | 15s elapsed
   │                              ↓
   │                       deal 3 more (cap 18)
   │                              │
   │                              ↓ (back to idle)
   │
   └─── deck_empty AND no_set_on_board ──→ ended
```

### Key invariants

- At most one of `claim_player_id` and `no_set_caller_id` is non-null at any time.
- A claim cannot be acquired while `no_set_started_at` is active. (Calling SET cancels the No-Set countdown atomically.)
- A No-Set call cannot be initiated while a claim is active.
- Lockout (`Player#locked_until`) is checked **inside** the claim acquisition transaction.

### Server-side timers

Use Solid Queue jobs scheduled with `set(wait: 5.seconds)` to enforce timeouts. The job re-checks state inside a transaction (claim could have been resolved already) and only acts if still applicable. Do not rely on client-side timers for correctness — they are display-only.

---

## 7. Realtime: Action Cable + Turbo Streams

Use Turbo Streams via `broadcasts_to` for almost all updates. Drop down to a custom Action Cable channel only if needed for player-specific signals.

### Streams

- **`game:#{code}`** — broadcast to everyone in the room. Used for: board state, scoreboard, claim/no-set announcements, game phase transitions.
- **`player:#{player.id}`** — broadcast to a single phone. Used for: lockout-state UI on the controller, "your claim is active, pick 3 cards", error toasts.

### Pattern

In `Game`:

```ruby
after_update_commit -> {
  broadcast_replace_to "game:#{code}", target: "board",       partial: "games/board",       locals: { game: self }
  broadcast_replace_to "game:#{code}", target: "scoreboard",  partial: "games/scoreboard",  locals: { game: self }
  broadcast_replace_to "game:#{code}", target: "announcement",partial: "games/announcement",locals: { game: self }
}
```

In `Player`:

```ruby
after_update_commit -> {
  broadcast_replace_to "player:#{id}", target: "controller_status", partial: "players/controller_status", locals: { player: self }
}
```

The board view subscribes to `game:CODE` only. The phone view subscribes to **both** `game:CODE` (so it sees the board state) **and** `player:ID`.

### Why this works

The server is the single source of truth. Every state change flows through model callbacks and emits HTML diffs to all subscribers. Clients have minimal logic — they apply patches and run small Stimulus controllers for input.

---

## 8. Views & UX

### Pages

#### Landing (`/`)

Two big buttons: **Start a game** (POST `/games`) and **Join with code** (form posting to `/games/:code/players/join`).

#### Board view (`/games/:code`)

Full-screen, dark background, optimized for a TV at 6+ feet viewing distance.

Layout:
- **Top left**: Room code in huge type, plus QR code image (uses `rqrcode` gem to render SVG at request time).
- **Top right**: Scoreboard. Players listed with name, color dot, score. Active claim highlighted.
- **Center**: 4×3 grid of cards (or 5×3 / 6×3 when board grows to 15/18). Cards are SVG, equal sizing, generous padding.
- **Bottom**: Announcement strip. "Waiting for players…" / "Alex is calling SET! 4… 3…" / "No Set called by Alex — 12… 11…" / "Alex found a Set!" (animated)

#### Phone landing (`/games/:code/players/join`)

Mobile-first, portrait. Form with:
- Name input (max 20 chars)
- Color picker — 8 large swatch buttons, distinct enough from the card palette to avoid confusion.
- "Join" button.

After submit: POST creates player, sets cookie, redirects to `/games/:code/controller`.

#### Phone controller (`/games/:code/controller`)

Three states the same view handles:

1. **Idle** (no claim, no No-Set countdown): one giant **"SET!"** button filling most of the screen. Below it, a smaller **"No Set"** button. Player's score and color shown at top.
2. **Claim active (mine)**: SET button replaced with the 12+ card grid (mirroring the board). Tap a card to highlight; tap again to deselect. Top of screen shows a 5-second countdown ring. After 3 cards selected, an auto-submit fires (or "Submit" button appears, depending on §11 decision — default: auto-submit on third tap with 250ms delay so the player can correct a misclick).
3. **Claim active (someone else's)**: Big banner "Alex is calling SET!" with a countdown. Buttons disabled.
4. **No-Set countdown**: Banner "No Set called by Alex — 12s". Big "I agree" button (joins the vote). SET button still available — tapping it cancels the No-Set call.
5. **Locked out**: After a wrong claim, SET button greyed out for 5s with a countdown ring.

Use Stimulus for: card selection state, countdown ring rendering, button enable/disable.

#### End screen

When `status: :ended`: board view replaces the grid with a final scoreboard, top-3 podium, and a "Play again" button (host-only). Phones show "Game over — final score: X" and a "Ready for next game" toggle.

---

## 9. Action Cable channel (optional, only if Turbo Streams is insufficient)

For v1, **avoid a custom channel**. Turbo Streams over `broadcasts_to` covers all state changes. Only introduce `GameChannel` if we hit a use case Turbo can't express (likely: smooth countdown animations driven by ticks rather than re-renders — but those should be CSS animations triggered by data attributes, not server-driven).

---

## 10. Card Rendering (SVG)

### Palette

Colorblind-safe (IBM 3-color palette):

- **Blue**: `#648FFF`
- **Orange**: `#FE6100`
- **Magenta**: `#DC267F`

Background: near-white (`#FAFAFA`). Card border: subtle, `#E5E5E5`. Selected card on phone: blue glow ring (`box-shadow: 0 0 0 4px #648FFF`).

### Component

Single ERB partial: `app/views/cards/_card.html.erb` taking a `card:` local. Renders an SVG with a `viewBox` of `0 0 200 280`. Inside:

- Rounded rect background.
- Stack of `card.number + 1` shapes (1, 2, or 3) centered vertically.
- Each shape is one of:
  - **Oval**: ellipse.
  - **Squiggle**: a fixed `<path>` with the canonical Set squiggle curve (hardcoded).
  - **Diamond**: rotated square (rhombus path).
- Shading:
  - **Solid**: `fill=color`.
  - **Outline**: `fill=none stroke=color stroke-width=4`.
  - **Striped**: `fill="url(#stripes-#{color})"` where `<pattern>` is defined once per page using the card's color, drawing 3-4px diagonal lines.

Cards on the **board** scale to fit the grid (CSS `width: 100%`, aspect ratio fixed). Cards on the **phone selection grid** are smaller but use the same SVG.

---

## 11. Selection submission UX (decision)

After the third tap on the phone, **auto-submit with a 250ms delay** so a player can deselect a misclick before commit. Show a subtle "Submitting…" pulse during the delay.

---

## 12. Background Jobs

- **`CleanupIdleGamesJob`** — runs hourly via `recurring.yml`. Deletes Games with `last_activity_at < 24.hours.ago`. Cascades to Players and Claims.
- **`ExpireClaimJob`** — enqueued with `wait: 5.seconds` when a claim is acquired. If the claim is still `pending`, mark it `expired`, clear the lock, broadcast.
- **`ExpireNoSetJob`** — enqueued with `wait: 15.seconds` when a No-Set is called. If still active, draw 3 cards (or end game), clear the call, broadcast.
- **`ExpirePlayerLockoutJob`** — optional; the lockout is enforced by checking `locked_until` at claim time, but a job that broadcasts UI updates when the lockout expires is nice-to-have.

All jobs are idempotent: they re-check the relevant state inside a transaction and no-op if no longer applicable.

---

## 13. Deployment (Render)

### `render.yaml`

```yaml
services:
  - type: web
    name: setgame
    runtime: ruby
    plan: free
    buildCommand: ./bin/render-build.sh
    startCommand: ./bin/rails server
    envVars:
      - key: RAILS_MASTER_KEY
        sync: false
      - key: RAILS_ENV
        value: production
      - key: SOLID_QUEUE_IN_PUMA
        value: "true"
      - key: DATABASE_URL
        value: sqlite3:///var/data/production.sqlite3
    disk:
      name: data
      mountPath: /var/data
      sizeGB: 1
    healthCheckPath: /up
```

### `bin/render-build.sh`

```bash
#!/usr/bin/env bash
set -o errexit
bundle install
./bin/rails assets:precompile
./bin/rails db:prepare
```

### Notes

- `database.yml` uses four SQLite files all under `/var/data/`: `production.sqlite3`, `cable.sqlite3`, `queue.sqlite3`, `cache.sqlite3`.
- Render free tier sleeps after 15 minutes of no inbound traffic (HTTP **or** WebSocket messages). Once a game is active, the WebSocket pings keep it warm; first visitor of the day eats a ~60s cold start. Acceptable for MVP; document in the README.
- No Redis, no Postgres, no separate worker service. All four storage concerns share one disk.

---

## 14. Future Work (post-v1)

### Accounts (v1.5)

The MVP `Player` model already includes a nullable `user_id`. To add accounts:

1. `bin/rails generate authentication` (Rails 8 built-in) to scaffold `User`, sessions, password reset.
2. Switch primary auth flow to **magic links** (use the `passwordless` gem or adapt the scaffold). Email delivery via Resend (free 100/day, 3000/month).
3. Add a "Claim profile" flow: when an authenticated User joins a Game, find-or-create a Player and set `user_id`. Existing guest Players can be retroactively claimed via session token if cookies match.
4. Add stats views: sets found, win rate, fastest claim. Backed by aggregations over the `Claim` table.

The Game logic does not change. `Player` continues to be the in-game identity; `User` is the optional persistent identity behind it.

### AI opponent (v2)

Brute-force solver runs in `Card.any_set_on?` already. A "bot player" is a `Player` row with no `session_token` and no User, animated by a background job that, after a configurable delay, attempts to claim a random valid Set. Difficulty = delay distribution.

### Other

- Solo/practice mode: same UI, no claim phase, infinite deck shuffle.
- Replays: `Claim` records already form the timeline; build a scrubber UI.
- Spectator mode: join URL with `?spectate=1` skips the name form.

---

## 15. Suggested implementation order

1. **App skeleton.** `rails new setgame -j importmap -c tailwind --database=sqlite3`, add Hotwire (default), `solid_cable`, `solid_queue`, `rqrcode`.
2. **Pure-Ruby game logic.** `Card`, deck shuffle, set validation, board manipulation. Unit tests with Minitest. This is the only part with non-trivial algorithms and the only part worth testing exhaustively.
3. **Models.** `Game`, `Player`, `Claim` with migrations and validations from §4.
4. **State machine methods.** `Game#try_claim!(player)`, `#submit_claim!(claim, card_ids)`, `#call_no_set!(player)`, `#join_no_set!(player)`, `#deal_more!`, `#deal_replacements!`, `#end?`. All operate inside transactions. Unit-test these.
5. **Controllers and views.** Routes from §5. Lobbies, board view, phone landing, phone controller. ERB partials only.
6. **Card SVG partial.** Palette from §10. Render to confirm visually before continuing.
7. **Turbo Streams.** Add `broadcasts_to` callbacks. Wire `turbo_stream_from` in views.
8. **Stimulus controllers.** Card-selection on phone, countdown rings, button states.
9. **Background jobs.** Claim/no-set expiry, idle game cleanup. Configure Solid Queue in `recurring.yml`.
10. **Polish.** Card deal/remove animations (CSS only). Claim countdown ring (CSS @keyframes driven by data attribute). Sound effects? (defer.)
11. **Render deploy.** `render.yaml`, build script, env vars. First push, debug, iterate.
12. **Real-game test.** Get 3 friends on a real TV. Watch what breaks. Fix.

---

## 16. Open items to confirm during implementation

- **Color presets for player choice** (8 distinct hex values that don't collide with the card palette).
- **Squiggle SVG path** — the canonical Set squiggle is a specific bezier; pick one and commit to it.
- **Striped pattern density** — visually tune in browser; aim for clearly distinguishable from solid at TV viewing distance.
- **Auto-submit timing** — 250ms feels right; tune with real users.
- **Cold-start mitigation** — consider a "Wake the server" splash on the landing page that does a low-cost ping while the user reads instructions.

---

End of spec.
