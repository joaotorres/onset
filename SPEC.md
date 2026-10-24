# Set — Online Multiplayer Spec

A web implementation of the card game **Set**, played devices-first: each player plays on their own device, a phone or a computer, and a shared big screen (a TV or laptop the whole table can see) is optional. `docs/adr/0001-devices-first-play.md` records why this replaced the Jackbox-style design, where a shared screen showed the cards and phones were only controllers.

This document is the source of truth for the v1 MVP. It is intentionally tight; favor it over guesses, but flag ambiguities back to the spec rather than inventing.

---

## 1. Overview

**What it is.** Real-time multiplayer Set. Each player plays on their own **player screen** (`/games/:code/controller`), on a phone or a computer, from which they call SET!, pick the three cards and vote. A **big screen** (`/games/:code`) is an optional shared display of the same room: the board, the scores and the announcements, for everyone at the table. Any room can open it at any time, before or during play; it is a URL, not a mode stored on the game, so every game is the same. Since the big screen is optional, the player screen is meant to stand alone; §8 says what each screen shows.

**Terms.** This spec and every user-facing text say **player screen** and **big screen** (`GLOSSARY.md`), never "phone", "controller" or "TV" for the screens. **Board** means the face-up cards. Code names predate these terms and stay: `ControllersController`, the `controller` route, `#controller_status`, the `board` column and `#board`.

**Stack.** Ruby on Rails 8, SQLite, Hotwire (Turbo + Stimulus), Action Cable with Solid Cable adapter, Solid Queue, Tailwind CSS, deployed with Kamal to a VPS.

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
3. A player taps **"SET!"** on their player screen, or a card on the board their player screen shows (§8, Player screen), which also selects that card. Server timestamps the request and atomically locks the claim to the first arrival.
4. The claiming player has **15 seconds** (`Game::CLAIM_TIMEOUT`) to pick 3 cards on their player screen and submit them. A tap picks a card, a second tap unpicks it, and the server keeps the current picks (§11). With exactly 3 picks the player taps **Submit** and the server judges those 3 at once; if the 15 seconds run out first, the server judges the picks it holds. Either way one of three outcomes:
   - **Correct Set** (3 picks that form a Set): +1 point, those 3 cards are removed, 3 new cards are dealt from the deck. Board unfreezes.
   - **Wrong Set** (3 picks that do not): −1 point, claiming player is locked out (cannot claim again) for **15 seconds**, as long as the claim window. The lockout reads `Game::CLAIM_TIMEOUT`, the same constant, so the two never drift. Board unfreezes. History: 5 seconds until ticket 20; that barely outlasted the announcement, so a wrong claim cost little more than the point.
   - **Time's up** (fewer than 3 picks): same penalty as a wrong Set: −1 point and the same lockout. Board unfreezes.
5. **No Set on the board**: any player can tap **"No Set"**. A 15-second countdown (`Game::NO_SET_TIMEOUT`) begins, visible on the big screen and every player screen. Resolution:
   - If **all currently active players** join the call before the countdown ends, it resolves immediately.
   - Otherwise, the countdown expires.
   - On resolution: deal 3 additional cards from the deck (board grows to 15, then 18 if called again). Hard cap at **18 cards**.
   - If anyone calls **"SET!"** during the countdown, the No-Set call is **cancelled** and the claim flow begins.
   - **Refusal**: any other active player who has not agreed can tap **"There's a Set"** to refuse the call. The call is cancelled at once and nobody, the refuser included, can call No Set for **15 seconds** (`Game::NO_SET_TIMEOUT`, the countdown's own length, so the two never drift): time to find the Set the refuser says is there. SET! stays open throughout. Refusing costs nothing. One refusal per board: the next No Set call on the same board cannot be refused, and the refusal comes back once the board changes (a Set removed or cards dealt).
6. **Game end**: when the deck is empty and **no valid Set exists** on the remaining board cards. Once the deck is empty, players can also end early: every active player taps **"End game"**. In quick mode the game ends when a player reaches 5 points (`Game::QUICK_WIN_SCORE`). The big screen shows the podium and a "Play again" button that restarts the room at once. Each player screen shows **Play again** as a ready vote: the room restarts once every active player has voted (§8, Player screen, Game over).

### Edge cases

- A player can call No Set even if they were never going to find one — that's the point.
- Wrong-claim lockout (15s, `Game::CLAIM_TIMEOUT`) only prevents that player from calling SET; they can still observe, call No Set, join No-Set votes and refuse a call.
- If the board grows beyond 12 (after No-Set draws), it stays oversized until a Set is found and removed; replacement cards only re-fill up to 12. Concretely: if board has 15 and a Set is found, board shrinks to 12 (no replacements).
- If the deck runs out mid-game, the board is not refilled. Game continues until no Sets remain on the board.

---

## 3. Architecture

### High-level

- **One Rails process.** Serves HTML, JSON, WebSockets, and background jobs from a single container.
- **SQLite** for primary, cable (Solid Cable), queue (Solid Queue), and cache (Solid Cache) databases. All four files live on the mounted persistent disk.
- **Turbo Streams** drive realtime UI. The server renders ERB partials and broadcasts diffs over Action Cable. Minimal custom JS.
- **Stimulus** for client-only interactions: the 3-card selection on the player screen, button countdown timers, the QR widget.

### Why this works in one container

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
| `host_player_id` | bigint | nullable; unused. The host is the browser that created the room, marked by its `host_game` cookie (§8 Landing), not a player |
| `claim_player_id` | bigint | nullable; the player currently holding the claim lock |
| `claim_started_at` | datetime | nullable; for the 15s claim window |
| `no_set_started_at` | datetime | nullable; for 15s No-Set countdown |
| `no_set_caller_id` | bigint | nullable; the player who called No Set |
| `no_set_voters` | json | Array of player ids who joined the call (default `[]`) |
| `no_set_refuser_id` | bigint | nullable; the player who refused the No Set call on this board |
| `no_set_refused_at` | datetime | nullable; when they refused. No Set is blocked for `NO_SET_TIMEOUT` from it, and no second refusal is accepted while it is set. Both cleared when the board changes (a Set removed or cards dealt) |
| `mode` | enum | `standard`, `quick` (first to `QUICK_WIN_SCORE` points) |
| `start_voters` | json | Player ids who tapped "I'm ready" while waiting, or "Play again" once ended (default `[]`) |
| `end_game_voters` | json | Player ids who voted to end once the deck is empty (default `[]`) |
| `flash_claim_id` | bigint | nullable; the just-resolved claim the screens announce for 3s |
| `last_dealt` | json | Card ids dealt by the last replace, outlined on the big screen and every player screen for 3s (default `[]`) |
| `last_activity_at` | datetime | unused; idle cleanup uses `updated_at` |
| `ended_at` | datetime | nullable |

**Validations**: `code` present, unique, matches `/\A[A-Z2-9]{6}\z/` (no `0/O/1/I` to avoid confusion).

**Methods**: `claim_active?`, `no_set_active?`, `no_set_blocked?` (refused less than `NO_SET_TIMEOUT` ago), `can_refuse_no_set?(player)` (a call is active, `no_set_refused_at` is nil, the player is active, not the caller and has not agreed), `can_call_set?(player)`, `valid_set_on_board?`, `dealable?` (deck non-empty AND board < 12).

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
| `locked_until` | datetime | nullable; the timestamp until which the player cannot call SET (the `Game::CLAIM_TIMEOUT` lockout) |
| `last_seen_at` | datetime | updated on every player screen request via `Player#seen!`, which skips callbacks so it never broadcasts |
| `left_at` | datetime | nullable; for graceful disconnect |

**Validations**: `name` present, length 1..20. `color` matches a hex pattern. `(game_id, name)` unique-case-insensitive (no two players in the same game can share a name). `(game_id, color)` unique (no two players in the same game can share a color).

**Methods**: `active?` (last_seen within 30s), `locked?`, `host?`.

### `Claim`

Audit record of every claim attempt. Useful for stats, debugging, and replay.

| Field | Type | Notes |
| --- | --- | --- |
| `game_id` | bigint | indexed |
| `player_id` | bigint | indexed |
| `card_ids` | json | The current picks, 0 to 3 ints, replaced on every tap while pending (§11); the picks judged, at submit or at expiry, once resolved |
| `result` | enum | `pending`, `correct`, `wrong`, `expired` |
| `started_at` | datetime | from server clock |
| `resolved_at` | datetime | nullable |

**Validations**: `card_ids`, when present, is an array of distinct integers in `0..80`: at most 3 while `pending` or `expired`, exactly 3 once `correct` or `wrong`.

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
  get "join" => "lobbies#join", :as => :join_by_code
  get "how-to-play" => "lobbies#how_to_play", :as => :how_to_play

  resources :games, only: [:create, :show], param: :code do
    member do
      post :start
      post :restart
      post :ready
    end
    resources :players, only: [:new, :create] do
      collection { get :join }
    end
    resource :controller, only: [:show], controller: "controllers"
    resources :claims, only: [:create, :update] do
      member { post :submit }
    end
    resource :no_set, only: [:create, :update, :destroy] do
      post :refuse
    end
    resource :end_game, only: [:create]
  end

  get "clock" => "clocks#show"

  mount ActionCable.server => "/cable"
  get "up" => "rails/health#show", :as => :rails_health_check
end
```

URL surface. Every action a player screen or the big screen POSTs answers `204 No Content`; the broadcast updates the screens (§7).

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/` | Landing: start a game, standard or first to 5, or join by code |
| GET | `/join?code=` | Find the room by code, redirect to its join page or back with "Room not found" |
| GET | `/how-to-play?game=` | The rules page, linked from the landing and the player screen. With `?game=` holding a room code (`Game::CODE_FORMAT`), **← Back** and the closing **Back to the game** go to that room's player screen `/games/:code/controller`; with anything else, or no code, Back goes to `/` and the closing section offers **Start a game** and **Join with a room code** instead. Only a code is ever accepted, never a path or URL, so Back cannot leave the site |
| POST | `/games` | Create room (`mode=quick` for first to 5), give this browser the `host_game` cookie, redirect to the creator's join page `/games/:code/players/join` |
| GET | `/games/:code` | Big screen, optional: any room can open it at any time |
| GET | `/games/:code/players/join` | Join page, after starting a game, the QR scan or a code: name + color form |
| POST | `/games/:code/players` | Create player, set cookie, redirect to the player screen |
| GET | `/games/:code/controller` | Player screen |
| POST | `/games/:code/ready` | A player votes to start; the game starts when every player (2+) has voted. Once ended, a player votes to play again; the room restarts when every active player has voted |
| POST | `/games/:code/start` | The host (the browser holding `host_game`) starts the game from the big screen |
| POST | `/games/:code/restart` | Play again from the big screen (host): reset deck, clear scores and votes, status `playing`, at once |
| POST | `/games/:code/claims` | Try to take the claim lock; a lost race changes nothing, and one lost to a running claim is logged (§6 Lost races are logged) |
| PATCH | `/games/:code/claims/:id` | Replace the picks (`card_ids`, 0 to 3 board cards) of a held claim; nothing is judged until Submit or the time runs out (§11) |
| POST | `/games/:code/claims/:id/submit` | Submit the claim: `card_ids` carries the whole selection, exactly 3 board cards, and the server judges them at once under the game lock, correct or wrong (§2 Round flow). Ignored, still `204`, when the claim is no longer pending or the selection is not 3 distinct board cards; `403` from a player who does not hold the claim, as the PATCH |
| POST | `/games/:code/no_set` | Initiate No-Set countdown OR join existing call |
| DELETE | `/games/:code/no_set` | Withdraw your vote (rare; no UI button v1) |
| POST | `/games/:code/no_set/refuse` | Refuse the running call: cancel it and block No Set for `NO_SET_TIMEOUT` (§2). Once per board. Ignored from the caller, from a player who agreed and once this board's refusal is used (`can_refuse_no_set?`, §4) |
| POST | `/games/:code/end_game` | Vote to end once the deck is empty; ends when every active player has voted |
| GET | `/clock` | The server's current time, JSON `{"now": <milliseconds since the epoch>}`, uncached. Screens measure their clock offset against it (§6 Server-side timers) |

---

## 6. Round State Machine

A round is the period between deals. Transitions are owned by the `Game` model and **always run inside a transaction with `game.lock!`** to serialize concurrent claim attempts.

```
                     ┌──────────────────────────────────────┐
                     │                                      │
   ┌─── (idle) ──────┼─── claim_lock_acquired ──→ claim_locked
   │                 │                              │ pick / unpick (0..3 cards, stored)
   │                 │                              │
   │                 │                              │ submit (3 picks) or 15s timeout: judge the picks
   │                 │                              ↓
   │                 │                          ┌────┐
   │                 │                          │ ✓  │ 3 picks, a Set → score+1, deal
   │                 │                          │ ✗  │ 3 picks, no Set → score-1, lockout
   │                 │                          │ ⏰ │ timeout, fewer than 3 → score-1, lockout
   │                 │                          └────┘
   │                 │                              │
   │                 │                              ↓ (back to idle)
   │                 │
   ├─── no_set_called ──→ no_set_pending
   │                              │
   │                              ├─ refused (once per board) → cancel,
   │                              │     No Set blocked 15s (back to idle)
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
- A No-Set call cannot be initiated while a claim is active, nor while the refusal block runs (`no_set_refused_at` less than `NO_SET_TIMEOUT` ago).
- A refusal is accepted only while a call is active and `no_set_refused_at` is nil; `no_set_refuser_id` and `no_set_refused_at` are cleared whenever the board changes.
- Lockout (`Player#locked_until`) is checked **inside** the claim acquisition transaction.

**Lost races are logged.** A SET! call that arrives while another claim runs loses the race and changes nothing (§5), but the server logs how late it was: one `info` line, `near_tie game=<code> winner=<player id> loser=<player id> late_ms=<n>`, where `late_ms` is the losing call's arrival minus the running claim's `claim_started_at`, in whole ms. Arrival is stamped as soon as the request reaches the app, before the game and player are looked up and before the lock is taken, so a wait for the lock does not inflate the gap; a negative value means the call reached the app before the winner's claim was stamped and the lock order decided. Only a call that lost on the running claim alone is logged: a call from a locked-out player, or outside play, is refused for its own reason and logs nothing. The line carries ids, never names. Why: the server already judges claims in arrival order, so the unfairness, if any, comes before it (network differences between phones, `click` firing on finger release, an occasional cold connection), and the arrival gap is the signal for whether the order could have flipped. §14 Claim fairness says what the lines are for.

### Server-side timers

Use Solid Queue jobs scheduled with `set(wait: ...)` to enforce timeouts: `ExpireClaimJob` after `Game::CLAIM_TIMEOUT`, `ExpireNoSetJob` after `Game::NO_SET_TIMEOUT`, `UnlockBroadcastJob` after the lockout (`Game::CLAIM_TIMEOUT`), `UnblockNoSetJob` after a refusal's block (`Game::NO_SET_TIMEOUT`, broadcasting so No Set comes back on every screen), `ClearClaimFlashJob` and `ClearLastDealtJob` after 3s. The job re-checks state inside a transaction (claim could have been resolved already) and only acts if still applicable. Do not rely on client-side timers for correctness: they are display-only.

**Countdowns follow the server's clock.** Every ring and seconds display counts from a `started_at` the server stamped, so a device whose clock is n seconds off would show every countdown off by n seconds. To keep the rings on every screen in step, each page measures its offset from the server's clock once per page load, NTP-style: it fetches `GET /clock` a few times, keeps the sample with the shortest round trip and takes `offset = server_now - (sent + received) / 2`. Countdowns then read the time as `Date.now() + offset`. One offset per page, shared by every countdown on it and kept across the stream redraws that replace rings (§7). Until the first sample lands, countdowns use the device clock as is, and they correct on their own once it does. Tens of ms of residual error from an asymmetric network path are expected and fine: the rings are display only, the server still judges every deadline.

---

## 7. Realtime: Action Cable + Turbo Streams

Use Turbo Streams via `broadcasts_to` for almost all updates. Drop down to a custom Action Cable channel only if needed for player-specific signals.

### Streams

- **`game:#{code}`** — broadcast to everyone in the room. Used for: board state, scoreboard, claim/no-set announcements, game phase transitions.
- **`player:#{player.id}`** — broadcast to a single player screen. Used for: lockout-state UI, "your claim is active, pick 3 cards", error toasts.

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

The big screen subscribes to `game:CODE` only. The player screen subscribes to **both** `game:CODE` (so it sees the game state) **and** `player:ID`.

### Actions answer 204, broadcasts update the screen

Every POST from a player screen or the big screen (SET!, a card pick, Submit, No Set, agree, End game, ready, Start game, Play again) answers `204 No Content`. Turbo leaves the page alone, and the broadcast the action triggers updates every screen, including the one that acted.

Do not redirect back to the same page. A redirect reloads it, which drops its stream subscriptions for about 500 ms, and any broadcast in that window is lost. Do not send per-player broadcasts for bookkeeping either (see `last_seen_at`): a broadcast per heartbeat is traffic with nothing new to show. `Player#seen!` writes `last_seen_at` without callbacks for that reason; the guard against a stale message is the version check below, not the bookkeeping.

### Screens ignore broadcasts older than what they show

Action Cable hands each message to a pool of worker threads, so two broadcasts to one stream can reach a screen out of order: the first ready vote's `board` (still waiting) can land after the game start's and leave the big screen and every player screen on the waiting state. Each replaced region therefore carries a version, and a screen drops a replace older than what it shows.

- Every hook root listed below carries `data-version`: an `updated_at` as integer microseconds since the epoch. `#announcement`, `#room_tile` and the playing and finished `#board` show game state alone and carry the game's. The others also show player state, and a lockout or a join writes the player without touching the game, so they carry the newer of the game's and every room player's: `#scoreboard` (scores, lockouts), `#controller_status` (that player's lockout, the roster while waiting, the standings during play) and the waiting `#board` and `#start_button` (the roster and the player count). A join's broadcasts therefore carry the new player's version, so two joins delivered out of order cannot leave the roster or the count one join behind.
- A global `turbo:before-stream-render` listener compares a `replace` stream's root `data-version` with that of the element it targets on the page and drops the stream when its version is strictly older. A stream with no version, or whose target is not on the page, renders as before.
- Equal versions render. `UnblockNoSetJob` and `UnlockBroadcastJob` rebroadcast because time passed, with no write, so their version equals the one on the page and the No Set pill, the big screen band and the SET! button come back.
- The version is `updated_at`, not a counter column: SQLite's single writer and Rails 8's immediate transactions keep it monotonic within a room, and no migration is needed. A column named `lock_version` would turn on optimistic locking, so a counter is ruled out by name as well.

### Hooks that must survive any markup change

Turbo Streams replace these by id, so each stays the outermost element of its region, and each carries `data-version` (above):

- Big screen: `#board` (holds the waiting state and `#start_button`), `#scoreboard`, `#announcement`, `#start_button`, `#room_tile`
- Player screen: `#controller_status` (wraps the header or scoreboard, the deck count, the state body and the found-set banner)

Stimulus attributes stay on whatever element plays the role:

- `card-selection`: `card` targets with `data-card-id`, `aria-pressed` (the server renders `true` for a picked card) and `click->card-selection#toggle`, plus `slot` and `count` targets, the `submit` target (the Submit button, `click->card-selection#submit`, `disabled` until three picks), the claim's PATCH URL in `data-card-selection-url-value` and its submit URL in `data-card-selection-submit-url-value`
- Idle board, in every player screen layout: each card carries `data-card-id` and its tap posts the SET! claim (§8, Player screen, Idle). `card-tap`: `data-controller="card-tap"` on the claim form around the cards, each card a submit button with `click->card-tap#tap`. It remembers the tapped card in memory, and `card-selection` selects it on connect
- Waiting invite (§8, Player screen, Waiting): `data-controller="invite"` around the invite with `url` (the join page URL) and `code` values. The Copy link / Share link button is the `link` target with `click->invite#share`; the QR sheet is a `<dialog>`, the `sheet` target, inside `#controller_status`, opened by Show QR with `click->invite#open` and closed by Done with `click->invite#close`
- Telemetry (§17): the hidden `game-events` element stays inside `#controller_status`, so every room update re-renders it, and the layout keeps `tracked_events_tag` at the top of `<body>`
- `countdown`: `data-controller="countdown"` with `started-at` and `duration` values, and `ring` and `display` targets. Rings keep `r="45"` and `stroke-dasharray="282.74"`. Elapsed time is measured on the server's clock, through the page's clock offset (§6 Server-side timers), which lives outside the controller instance so a redraw keeps it.

### Why this works

The server is the single source of truth. Every state change flows through model callbacks and emits HTML diffs to all subscribers. Clients have minimal logic — they apply patches and run small Stimulus controllers for input.

---

## 8. Views & UX

Colors, type and animations are in §10. Hook ids and Stimulus attributes that must survive markup changes are in §7.

### Landing (`/`)

One page for phones and desktops, split at `lg:` (1024px and up): the actions card is 448px wide, and the brand column needs that much room for the wordmark and the fanned cards. Below `lg:` the phone layout stacks, tablets included. Side by side, nothing in the brand column runs past its own width into the actions card: the fanned cards and the wordmark shrink with the column at narrow desktop widths and are full size from 1280px. Brand on the left: the **Onset** wordmark, a one-line tagline and three fanned cards that form a Set, with a caption saying why. The tagline says each player plays on their own screen and a big screen is optional, in the §1 terms. Actions on the right:

- A two-option toggle, **Standard** (selected by default) and **First to 5**, above one **Start a game** button with the sub-line "Play from this screen, then invite the others". Both sit in one form, with no JS: the toggle submits `mode` (`quick` for First to 5). Start a game creates the room in that mode, gives this browser the `host_game` cookie and opens the creator's join page (Join page below). Every room is the same: nothing about a big screen is stored on it.
- **Have a room code?** field plus **Join**. `GET /join?code=` upcases the code and redirects to the room's join page, or back to the landing with "Room not found" under the field, which comes back empty with a red border.

On phones the join form comes first, since joining is what phones come here for.

### Big screen (`/games/:code`)

Full screen, built for a TV at 2m, and must also fit a laptop down to 1280px wide. Two columns: the play area (`#board` over `#announcement`) and a 26rem right rail with the room tile (room code and the site address to open, `join_host`, no QR) and the **Players** scoreboard. The room tile is hidden while waiting, since the join hero carries the code, and appears once the game starts without a reload. The join hero holds the only QR on the screen: once play starts, late joining is blocked, so nothing needs one.

- **Scoreboard**: rows sorted by score, dot, name, big score. The claiming player's row turns solid yellow. A locked-out player is greyed with a red **Locked** tag.
- **Waiting**: a join hero with a 288px QR and, under it, a **Join from this computer →** link that opens the join page in a new tab, for someone playing on the same computer as the big screen. A browser holds one player (one `player_token` cookie), so a second player on that computer needs a private window or another browser. Beside the QR, "Scan to join, or open HOST and enter" and the room code at up to 10rem, shrinking with the viewport so it never runs past the play area into the rail. The hero's text wraps or shrinks the same way. Player pills with a ✓ once ready. `#start_button`: **Start game** with "n of m ready" beside it, or disabled with "Need at least 2 players".
- **Playing**: "N cards left in the deck" top right, or an orange "Deck is empty" pill. The card grid (§10). Cards dealt by the last replace get a green outline that fades over 3s.
- **Announcement band**: always 9rem tall so the grid never jumps. Empty while playing: "Spot a Set? Hit SET! on your screen." Otherwise one tinted panel:
  - Claiming (yellow): countdown ring, "Alex is calling SET!".
  - No Set (purple): ring, "Alex called No Set", "Agree on your screen, or find one first", and "n/m agreed".
  - Refused (purple): ring counting the block down, "Alex says there's a Set", "No Set is back when the ring runs out". The name is truncated with an ellipsis so the headline stays within two lines at 1280px wide. Shown for the `NO_SET_TIMEOUT` block after a refusal (§2) while no claim runs (a claim shows the Claiming panel instead), then the empty-band text returns.
  - Correct (green): the three cards, "Alex found a Set", "+1". Fades after 3s.
  - Wrong / Time's up (red): the cards for a wrong claim, the reason with the lockout length, "−1".
- **Ended**: "Game over", then "Alex wins" or "It's a tie". Podium in 2-1-3 order; bars carry the real rank, so a tie reads #1 #1, and only a sole winner gets the ★. **Play again**, which restarts the room at once whatever the player screens have voted.

### Join page (`/games/:code/players/join`)

Portrait. "Joining room" with the code in large type, since the code is what people check. The creator sees the same page after **Start a game**. **Your name** (max 20). **Pick a color**: a 4×2 grid of swatches that select with a white ring and ✓, no JS. Taken colors are faded with the taker's initial. The first free color, in preset order, comes selected, so a player can join with a name alone. If the chosen color was taken between render and submit, the form comes back with the color error and the next free color after it selected (preset order, wrapping); any other re-render keeps the player's free choice. With every color taken the room is full: none is selected, the red base error box says "This room is full" and **Join** is disabled. The page does not update live as others join. **Join** sits at the bottom, under the thumb. In the browser that created the room (its `host_game` cookie matches), a **Use this screen as the big screen instead** text link sits under Join and opens the room's big screen `/games/:code` in the same tab; other browsers do not show it. Joining does not make the creator `host_player_id`: hosting stays with the browser, which gets the big screen's **Start game** and **Play again**, and on player screens everyone starts and plays again by the ready vote. Field errors show under their field; base errors (game already started) in a red box.

### Player screen (`/games/:code/controller`)

Full height, no page scroll. A strip of the player's color across the top, "Room CODE" footer. The player screen stands alone (§1): in every playing state it shows the board, the scoreboard and the deck count, so a room needs no big screen. Waiting and game over keep a header with dot, name and score, since their bodies already list every player. Three layouts, chosen by the viewport alone, whatever the input:

- **Portrait** (narrower than tall, under 1024px wide): the scoreboard across the top, the board under it at the full width, then the state's panel, SET! and its pill at the bottom, under the thumb.
- **Landscape** (wider than tall, under 1024px wide): three columns, the board on the left, a 9rem action column, a scores column.
- **Computer** (1024px wide and up, Tailwind `lg:`): a board-sized card grid on the left and a side column with the scoreboard stacked above the state's panel, SET! and its pill, so the board keeps the width.

Shared by all three during play:

- **Scoreboard**: every player in score order, ties in join order, each a dot, the name (truncated) and the score. The claiming player's entry turns solid yellow and a locked-out player's is greyed with a red **Locked** tag, as on the big screen. The player's own entry has a surface tint, as in the game over standings. Portrait fits 8 players in at most two rows.
- **Deck**: "N cards left in the deck" under the board, centred on it, or an orange "Deck is empty" pill once it runs out. In the computer layout the "Room CODE" footer sits directly under that line, centred on the board as well, so the two lines share one centre and nothing sits under the side column. Portrait and landscape keep the footer centred on the screen, and so do waiting and game over in every layout, since they show no board.
- **Board**: cards dealt by the last replace get the green outline that fades over 3s (§10 `animate-arrive`), in every state that shows the board. The board is read-only in every state but idle and claiming (mine).
- Other players' wrong claims and time's ups show only on the scoreboard (their Locked tag and score), with no banner.
- With 8 players and 18 cards there is no page scroll at 375×667 portrait, 667×375 landscape and 1024×640 computer, in every state: the cards shrink to fit.

SET! sits in the same fixed slot across idle, locked out, someone else claiming and the No Set countdown, so the thumb never has to move. The pill slot under it holds the state's secondary action: **No Set**, the **End game** vote or **I agree, no Set**, with **There's a Set** (the refusal) beside it while the player may refuse.

1. **Waiting**: "You're in", a two-column roster with "you" and ✓ marks, then **I'm ready** (the ready vote, §5 `POST /games/:code/ready`). Once voted: "Ready ✓ · waiting for n more". Alone in the room, a player cannot vote: "Waiting for more players to join…" takes the place of I'm ready, so the voted line never reads "waiting for 0 more".

   Every player's waiting screen also carries the **invite**, so anyone in the room can bring in the next player; it goes once play starts, since late joining stays blocked, remote players included:
   - The room code in large type, with "or open HOST and enter the code" (`join_host`), as on the big screen.
   - **Copy link**: copies the join page URL (`/games/:code/players/join`, the URL the big screen QR encodes) and reads "Copied ✓" for 2s. Where the browser has the Web Share API and a touch screen (`pointer: coarse`), it reads **Share link** and opens the native share sheet with that URL and "Room CODE" instead. A cancelled share changes nothing; a failed copy reads "Couldn't copy" for 2s, the code and host staying on screen to share by hand.
   - **Show QR**: opens a sheet over the player screen with the join URL's QR on a white tile, as large as fits up to 18rem, the room code under it and **Done** to close it. The QR stays behind this tap so the waiting screen fits without it. Any room update (someone joins or votes) re-renders `#controller_status` and closes the sheet; one tap reopens it.
   - **Show on a big screen →**: a text link that opens the room's big screen `/games/:code` in a new tab, as **Join from this computer →** does, so the player screen stays open.

   With 8 players and the invite there is no page scroll at 375×667 portrait, 667×375 landscape and 1024×640. The exact layout comes from the design pass.
2. **Idle**: round blue **SET!** with a halo, a purple **No Set** pill under it. During the block after a refusal (§2), No Set is disabled and shows the seconds left ("No Set in 12 s"), the status slot reads "Alex says there's a Set" ("You say there's a Set" on the refuser's own screen, with their own dot) and SET! stays as it is; the pill comes back on its own when the block ends. Once the block ends the refusal stays used until the board changes: No Set works again, but a call on this board cannot be refused. Deck empty: an orange **End game** vote with "Deck empty · n/m voted". Tapping a card on the board, in every layout, calls SET! and, once the claim is this player's, starts it with that card selected. Only the first tap counts until the screen changes. If someone else wins the race the tap does nothing, and it never selects a card in a later claim. Accepted risk: a stray tap starts a 15-second claim and can cost −1, the same as a stray SET!.
3. **Claiming (mine)**: a solid yellow bar with the countdown ring, "Your SET!", "Tap 3 cards" and an n/3 count, and a **Submit** button. Portrait puts the bar in the status slot above SET! and a tray of three slots, which fill as cards are tapped, in place of SET! and its pill. Landscape and computer show the bar as one block in place of the panel and SET!, the pill slot left empty. Where Submit sits in each layout comes from the design pass. No Set is not offered during the player's own claim. A claim started by tapping a card opens with that card picked (1/3) if it is still on the board. Tap a card to pick it, tap again to unpick, up to three; three picks stay changeable until Submit is tapped or the time runs out. Submit is shown disabled below three picks and enabled at exactly three, in one fixed place, as SET! keeps its slot. Tapping it sends the three picks and the server judges them at once (§11): correct or wrong, announced on every screen exactly as a claim judged at expiry (the found-set banner, or state 6). From the tap on the screen takes no more picks and Submit takes no second tap, until the broadcast that resolves the claim replaces the screen; the countdown ring keeps running, since the timer stays the fallback. A submit request that never reaches the server (a network error) gives the board and Submit back, and the player taps again. A redraw of the screen during the claim (any room update, §7) shows the picks again, tray and count included, the latest ones even with a pick still on its way to the server (§11).
4. **Someone else claiming**: caller's dot and name, "is calling SET!", a yellow ring around the disabled SET! with the seconds inside. No Set disabled.
5. **No Set countdown**: a purple status panel (ring, "No Set called by Alex", n/m agreed in every layout) above the round blue **SET!**, which cancels the call, and a purple **I agree, no Set** pill under SET!. A player who may refuse (§4 `can_refuse_no_set?`: not the caller, has not agreed, and no refusal used on this board) also gets **There's a Set**, the refusal, in the pill slot; how the two pills share it comes from the design pass. After agreeing, or for the caller, the pill slot shows "You agreed · waiting for n more". Locked out, the No Set panel keeps the status slot and SET! shows the lockout countdown as in state 6 (ring, seconds, "Locked"); the refusal stays available. A refusal returns every screen to idle with No Set blocked (state 2).
6. **Locked out** (after a wrong claim or a timeout): the panel tints red and shakes once. "Wrong! −1" or "Time's up! −1". SET! becomes the lockout countdown with "Locked": `Game::CLAIM_TIMEOUT` seconds, the same length as the claim ring. The pill slot keeps the idle secondary action, **No Set** or the **End game** vote, enabled: lockout only blocks SET! (§2 Edge cases). Locked out during the block after a refusal, the refused panel takes the status slot (state 2), SET! keeps its lockout countdown and the pill is the blocked No Set.
7. **Found-set banner**: when anyone finds a Set, a banner across the top shows the cards, "Alex found a Set" and "+1", then fades. It ignores taps.
8. **Game over**: the player's rank ("2nd"), "of N players · P points", the winner line ("★ Alex wins with 9", "★ You win with 9" when the player is the sole winner, or "★ Tied for first at 9"), the standings, then a green **Play again** button, the ready vote (§5 `POST /games/:code/ready`). Once voted: "Ready ✓ · waiting for n more", n being the active players who have not voted. The room restarts with the same mode, fresh deck and zero scores once every active player has voted, straight into play. Accepted risk: active means seen in the last 30s and only a player's own requests refresh it, so after 30s on this screen the first tap may restart the room alone.

   The standings list every player in the room, as many as "of N players" counts, one compact row each: rank, dot, name and score. Rows run by score, ties in join order, and tied players share a rank ("1, 1, 3"), as on the big screen podium. No ★, Locked tag or ready marks in the rows: the winner line carries the ★. Names truncate with an ellipsis. The player's own row is highlighted with a surface tint, not a color from the §10 meaning table, and says "you" after the name, as the waiting roster does. The rank is the shared one on a tie, a plain ordinal ("1st", never "=1st"): the winner line and the standings already say who tied. Portrait stacks everything; landscape and computer put the rank, the winner line and Play again in a left column and the standings on the right. With 8 players, one per preset color, the screen keeps no page scroll at 375×667 portrait, 667×375 landscape and 1024×640 computer. On a shorter screen the list scrolls inside itself, never the page.

Stimulus: `card-selection` (picks sent to the server, tray, count, Submit), `countdown` (every ring and seconds display) and `invite` (shares or copies the invite link, opens the QR sheet), its attributes listed in §7.

### Byline footer

A small muted footer, the same across all of joaotorr.es's apps, so its look and behaviour follow that shared design rather than this spec's palette. It must stay quiet and never compete with the Onset wordmark.

- **Where**: after `main` on the landing, How to play and the join page, centred in the How to play container (`max-w-5xl`, `px-5`, `md:px-10`), on `gray-950`. Nothing between it and `main`; below it 16px or the bottom safe area, whichever is bigger. It fits inside the first screen: the page is a viewport-tall column in which `main` grows and the footer comes last, so when the content fits the screen the footer sits at the bottom edge and the page does not scroll, and when the content is taller the footer follows it. The footer never overlaps content. The landing's centred content and the join page's Join button therefore sit above the footer, not at the bottom of the window. The big screen and the player screen have none: they are full-screen views with no page scroll. Static error pages and emails have none.
- **What**: "by joaotorr.es", one link to https://joaotorr.es that opens in a new tab, so the player keeps their place. A hidden "(Opens in a new tab)" completes the accessible name; the coloured copies of the domain are hidden from screen readers so it is read once. English only, like the rest of the app.
- **At rest**: `gray-400`, 14px, weight 500, the body font, with one continuous 1px red underline under the whole phrase. The link is 44px tall for touch.
- **Hover (devices with hover) or keyboard focus**: "by" and the underline stay as they are. Over 1s the dot hops up and lands with a small bounce, turning gold, while "joaotorr" fades to a green to blue gradient and "es" to a red, gold, red stripe. It stays coloured until the next page load; hovering again replays the hop. Reduced motion: no hop, the colours still fade in. Keyboard focus adds a 2px `blue-500` outline.
- **Logo colours**: the dark values, since every Onset screen is dark: green `#22C35E`, blue `#5B8CFF`, red `#FF4F5E`, gold `#FFD21F`. The light values (`#009C3B`, `#002776`, `#C60B1E`, `#E08A00`) sit on `:root` for any light ground.

### Search engines

- **Public**: the landing (`/`) and How to play (`/how-to-play`), the pages meant to be found in search. Each carries a canonical link to its production URL without a query, so `/how-to-play?game=` folds into `/how-to-play`. English only, so no hreflang. `/sitemap.xml` lists the two, and `/robots.txt` allows everything and points to it, because a crawler cannot see the noindex on a page robots.txt blocks.
- **Everything else is noindex by default**, through an `X-Robots-Tag` header: the big screen, the join and player screens, `/join` and anything added later. A new public page has to opt out explicitly and be added to the sitemap.

---

## 9. Action Cable channel (optional, only if Turbo Streams is insufficient)

For v1, **avoid a custom channel**. Turbo Streams over `broadcasts_to` covers all state changes. Only introduce `GameChannel` if we hit a use case Turbo can't express (likely: smooth countdown animations driven by ticks rather than re-renders — but those should be CSS animations triggered by data attributes, not server-driven).

---

## 10. Cards and visual system

### Palette

Colorblind-safe (IBM 3-color palette):

- **Blue**: `#648FFF`
- **Orange**: `#FE6100`
- **Magenta**: `#DC267F`

Background: near-white (`#FAFAFA`). Card border: subtle, `#E5E5E5`. Selected card on the player screen: `ring-4 ring-blue-400 scale-95`.

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
  - **Outline**: `fill=none stroke=color stroke-width=5`.
  - **Striped**: `fill="url(#stripes-#{color}-#{suffix})"`, a 40° hatch of 3.5px lines on a 7px pitch. Each SVG defines its own `<pattern>`, with an id unique to that rendered SVG, never to the card alone: the same card can appear twice on one page, and a browser resolves `url(#id)` to the first element with that id, so a duplicate inside a hidden element paints the shape empty. A copy made in the browser (the player screen tray, §11) gets fresh ids too.

The SVG fills its wrapper; wrappers set the size with a 5:7 aspect ratio. The partial is never restyled, only sized.

- **Big screen grid**: 3 rows flowing into columns, centered, no horizontal scroll at 18 cards. Cards are `15rem` tall at 1080px and shrink with the viewport (`min(15rem, (100dvh - 22rem) / 3)`) so the third row never runs under the announcement band.
- **Player screen, portrait**: in every playing state the grid fits the width (`auto-cols-fr`) and shrinks to the height left, so SET! and its pill never leave the screen.
- **Player screen, landscape**: 3 rows flowing into columns, the cards shrinking to fit the board's width and height, with no sideways scroll; at 12 cards they fill the height.
- **Player screen, computer**: 3 rows flowing into columns, sized to the board's width and height, no horizontal scroll at 18 cards.

On the player screen, in every layout, a card takes the largest size at which `cards / 3` columns fit the board's width and 3 rows its height, with a 5px gap on phones and 12px on computer.

### Visual system

Dark UI where the cards are the only bright surfaces. Tailwind default palette plus these tokens in `app/assets/tailwind/application.css`:

- `font-display`: Bricolage Grotesque (Google Fonts link in the layout). Only for display text: wordmark, room code, scores, SET!, headlines, countdown digits. Body copy stays on the default sans.
- `animate-shake`: once, 0.4s. Locked-out player screen panel.
- `animate-arrive`: green outline that holds 1.5s and fades by 3s. Cards dealt by the last replace (`Game#last_dealt`), on the big screen and the player screen board.
- `.found-set-flash`: holds 1.5s, fades by 3s. Correct-claim panels on the big screen and the player screen.

Surfaces: page `gray-950`, panels `gray-900`, borders `gray-700`/`gray-800`. Secondary text `gray-400`, muted `gray-500` (not `gray-600`, which fails contrast on `gray-950`).

Each color means one thing everywhere:

| Color | Meaning |
|---|---|
| blue-600 | SET! and primary actions |
| violet-600 | quick game |
| yellow-400 | a claim in progress (big screen panel, scoreboard entries, player screen claim bar) |
| purple | No Set. It used to be red; red now only means wrong or locked |
| red | wrong claim, timeout, lockout |
| green | ready, correct, start, play again (`green-700` for white text; `green-600` is only about 3.3:1) |
| orange | deck empty and the End game vote (`orange-700` for white text; `orange-600` is only about 3.3:1) |

Player colors are the 8 presets in `PlayersController::PRESET_COLORS`, deliberately apart from the card palette. They show as dots, the player screen's top border strip and podium bars.

Countdown rings: `r=45` in a 100 viewBox, gray track, colored progress with round caps, rotated -90° so they drain clockwise from the top. Seconds sit inside the ring, or inside the button the ring surrounds.

QR codes: dark modules on a white tile. Inverted codes fail on some phone cameras.

---

## 11. Selection submission UX (decision)

A claim is judged when the claiming player submits exactly three picks, or when its 15 seconds run out, whichever comes first. Every tap on the board picks or unpicks a card, up to three, and sends the current picks to the server at once (`PATCH /games/:code/claims/:id`, §5): one request at a time, each carrying the whole selection, so a quick sequence of taps arrives in order. The server stores them on the pending claim (`Claim#card_ids`) and broadcasts nothing: the picks are private to the claiming player.

**Submit** (`POST /games/:code/claims/:id/submit`, §5) is an explicit tap, enabled only at three picks. Its request carries the whole selection, and the server judges that selection, not the picks it stored earlier: it validates three distinct board cards, writes them to `Claim#card_ids` and resolves the claim under the game lock, correct or wrong (§2, Round flow), with the same broadcasts as at expiry. The submit therefore never waits for an earlier pick request to land, which is what made the v1 auto-submit race a mid-claim redraw. A submit that arrives once the claim is no longer pending (the timer got there first, or a second tap) changes nothing and answers 204 (§7); a pick that lands after the claim resolved is ignored the same way, as today. **The timer stays as the fallback**: `ExpireClaimJob` judges the picks it finds when the claim is still pending (§2, Round flow): three that form a Set score as a correct Set, three that do not as a wrong Set, fewer than three as time's up. A tap still in flight at expiry is lost. Client timers stay display-only (§6).

On the player screen each tap also copies the card into the portrait tray's next free slot and updates the n/3 count. The board never dims and three picks stay changeable until Submit is tapped or the time runs out. Submit is rendered disabled and the controller enables it at exactly three picks; on the tap it sends the submit at once, whatever pick request is in flight, and freezes the screen (no pick, no second submit) until the resolving broadcast replaces it. The freeze is lifted only when the request fails to reach the server, so the player can tap again; a response of any kind leaves the screen to the broadcast, or to the timer. The picks are server state, so a redraw of the player screen mid-claim (a room update, §7) renders the picked cards picked and the controller continues from them, refilling the tray and the count. A pick can still be on its way when the redraw lands, so the page also keeps the latest picks of the current claim in memory, and the one-at-a-time sending with them: a redrawn screen shows those latest picks rather than the rendered ones, and the pick that is sent next is the selection the screen shows. After a page reload the memory is gone and the rendered picks are the picks. The pick and submit requests are `fetch` calls carrying the page's CSRF token, not form submits, so they do not depend on `form.requestSubmit`.

History: v1 auto-submitted 250 ms after the third tap, the grid dimmed during the delay. Dropped (ticket 19): the third tap was seen not to submit on a phone, and judging only at the timeout removed the submit step and its race with a mid-claim redraw. That left every claim, a correct one included, waiting out the full 15 seconds, so ticket 37 brought a submit back as an explicit button whose request carries the whole selection: it cannot miss like the third tap did, and it does not depend on the pick requests, so the race is gone too.

---

## 12. Background Jobs

- **`CleanupIdleGamesJob`** — runs hourly via `recurring.yml`. Deletes Games with `updated_at < 24.hours.ago` (every gameplay action goes through `Game#update!`). Cascades to Players and Claims.
- **`ExpireClaimJob`** — enqueued with `wait: Game::CLAIM_TIMEOUT` when a claim is acquired. The fallback for a claim never submitted (§11): if the claim is still `pending`, judge the picks it holds: `correct`, `wrong` or `expired` with fewer than three. Clear the lock, broadcast. A submitted claim is already resolved, so the job no-ops.
- **`ExpireNoSetJob`** — enqueued with `wait: Game::NO_SET_TIMEOUT` when a No-Set is called. If still active, draw 3 cards (or end game), clear the call, broadcast.
- **`UnblockNoSetJob`** — enqueued with `wait: Game::NO_SET_TIMEOUT` when a call is refused. Broadcasts so the No Set pill and the big screen band return to idle; the block itself is enforced by `no_set_refused_at` at call time.
- **`ExpirePlayerLockoutJob`** — optional; the lockout is enforced by checking `locked_until` at claim time, but a job that broadcasts UI updates when the lockout expires is nice-to-have.

All jobs are idempotent: they re-check the relevant state inside a transaction and no-op if no longer applicable.

---

## 13. Deployment (Kamal to the Hostinger VPS)

The app deploys with Kamal to the Hostinger VPS shared with the other joaotorr.es apps, as `onset.joaotorr.es`. The runbook is `docs/deploy.md`.

### `config/deploy.yml`

- One `web` server, the VPS. kamal-proxy, already on the host, terminates SSL with a Let's Encrypt certificate and routes by hostname. Rails runs with `assume_ssl` and `force_ssl`, `/up` excluded from the redirect for the proxy health check.
- Image on GitHub Container Registry as `joaotorres/onset`, built for amd64.
- Env: `RAILS_MASTER_KEY` and `SENTRY_DSN` (secret), `APP_NAME: onset` and `SOLID_QUEUE_IN_PUMA: true` (clear). `APP_NAME` and `SENTRY_DSN` are for telemetry (§17).
- Volume `onset_storage:/rails/storage` holds the four SQLite files.
- No accessories.

### `.kamal/secrets`

Reads the registry token and the Sentry DSN from the macOS Keychain (items `onset-registry-pat` and `onset-sentry-dsn`) and `RAILS_MASTER_KEY` from `config/master.key`. Nothing is stored in the file.

### Notes

- `database.yml` uses four SQLite files under `storage/`: `production.sqlite3`, `production_cable.sqlite3`, `production_queue.sqlite3`, `production_cache.sqlite3`. The container entrypoint runs `db:prepare` on boot.
- The container runs Thruster in front of Puma. Solid Queue runs inside Puma, so one container serves HTML, WebSockets and jobs.
- No Redis, no Postgres, no separate worker service. All four storage concerns share one volume.
- Always on: no cold starts, unlike the Render free tier this app started on.

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

### Claim fairness

Once enough games have been played, read the `near_tie` lines (§6 Lost races are logged; `bin/kamal logs`, `docs/deploy.md`) and decide from them whether the claim race needs changing. Today the rule is "first to reach the server", and a `late_ms` well above the spread of a phone's network path says the order could not have flipped. If the gaps are small and frequent, these are the options, with their trade-offs:

- **Claim on pointerdown**: removes the release delay that varies per player, but fires on a scroll start or a brush (stray claims cost −1), loses slide-off-to-cancel, risks a card being picked twice when the click lands on the redrawn screen (§8 "only the first tap counts"), and needs `click` kept for the keyboard. If done, SET! button only.
- **Claims over the WebSocket**: skips a possible handshake and HTTP overhead, but the gain is unmeasured, mobile browsers drop the socket on suspended tabs so HTTP stays as a fallback (two claim paths), and it needs the custom channel §9 says to avoid.
- **Lag compensation** (tap timestamps plus a short collection window): the only option that cancels network differences, but every claim starts about 150 ms later, it trusts device-reported tap times (needs clock sync for correctness and a clamp against faked early stamps), still misses device input speed and is harder to test.

Also worth weighing then: players see a new board at different moments, a head start none of these fix; and "first to reach the server" is a defensible rule for a casual party game.

### Other

- Solo/practice mode: same UI, no claim phase, infinite deck shuffle.
- Replays: `Claim` records already form the timeline; build a scrubber UI.
- Spectator mode: join URL with `?spectate=1` skips the name form.

---

## 15. Implementation plan (vertical slices)

Complete. Kept as history: new work runs as skills-loop tickets.

Each step delivers a **small but end-to-end-working** increment. The app should be deployable and demoable after every step. One commit per step, pushed to `main`, deployed with `bin/kamal deploy`. Sections referenced by number are normative; do not re-derive their content here.

> Step 0 has already been done manually outside Claude Code: `rails new . --database=sqlite3 --css=tailwind --javascript=importmap` produced the vanilla skeleton committed as the first commit on `main`. Steps below build on that.

### Step 1 — Walking skeleton in production
**Goal:** the app is publicly reachable at its production URL before any feature code is written.

- Add gems: `solid_cable`, `solid_queue`, `solid_cache`, `rqrcode`, `standard`. Run `bundle install`.
- Configure Action Cable to use the `solid_cable` adapter (`config/cable.yml`).
- Configure SQLite paths for primary, cable, queue, cache per §3 and §13.
- Set `SOLID_QUEUE_IN_PUMA=true` so we don't run a second worker service.
- Add `config/deploy.yml` and `.kamal/secrets` per §13.
- Replace the default root with a placeholder `LobbiesController#new` that renders a single page reading "Set" and the Rails version.
- **Acceptance:** `https://onset.joaotorr.es` loads in production.

### Step 2 — Card primitives (pure Ruby + tests)
**Goal:** the only algorithmically interesting part of the app is correct and exhaustively tested.

- Implement `app/models/card.rb` (PORO) per §4.
- Minitest coverage:
  - For every pair of distinct cards, exactly one third card completes a Set.
  - The canonical 20-card cap set (any documented one) contains no Set.
  - `valid_set?` smoke tests on hand-picked positive and negative trios.
- **Acceptance:** `bin/rails test` passes. No UI changes.

### Step 3 — Game and Player models
**Goal:** rooms exist as DB records, but no game logic yet.

- Migrations for `games` and `players` per §4. **Skip** claim/no-set columns for now — added in Step 7.
- Validations, the `code` generator (uppercase, 6 chars, excludes confusable glyphs).
- Model tests covering invariants only (uniqueness, format, name length, name-uniqueness-within-game).
- **Acceptance:** in `bin/rails console`, `Game.create!` returns a game with a 6-letter code; duplicate codes are impossible by construction.

### Step 4 — Create-and-show a game (no realtime)
**Goal:** a host can create a game and see a placeholder board at a public URL.

- Routes: `root`, `POST /games`, `GET /games/:code`.
- `LobbiesController#new`, `GamesController#create`, `GamesController#show`.
- Board view: room code in big type, placeholder card boxes (text labels like "1·blue·oval·solid"), no SVG yet.
- **Acceptance:** visit `/`, click "Start a game", land on `/games/ABC123` with a static placeholder board.

### Step 5 — Phone joins via QR
**Goal:** two devices can sit in the same room.

- Render QR on the board view via `rqrcode`, linking to `/games/:code/players/join`.
- Phone landing: name input + 8 color swatches.
- `PlayersController#new` and `#create`; cookie-based session token; redirect to `/games/:code/controller`.
- Phone controller view: shows player's name and a placeholder "SET!" button. No game state yet.
- **Acceptance:** scan QR, join with a name, see your controller view; refresh the board and your name appears in the (still-static) scoreboard.

### Step 6 — SVG card rendering
**Goal:** the board *looks* like Set.

- `app/views/cards/_card.html.erb` per §10. IBM colorblind-safe palette. Stripe pattern. Three shapes.
- Replace placeholder boxes with the real partial.
- **Acceptance:** a freshly created game shows 12 visually correct Set cards on the board.

### Step 7 — Game lifecycle: deal 12 cards
**Goal:** a host can start a game and the deck is dealt.

- Add `Game#status` enum (`waiting`, `playing`, `ended`) and `Game#deck`, `#board`, `#discard` JSON columns. Migration.
- `POST /games/:code/start` (host only): shuffle deck, deal 12 cards into `board`.
- "Start" button on the board view, host-only.
- **Acceptance:** create game, host clicks Start, board shows 12 real cards.

### Step 8 — Claim flow (single device, full-page reload)
**Goal:** one player can call SET, pick 3 cards, and score — even if other devices need to refresh to see updates.

- Migration: claim/no-set columns on `games`, `claims` table, `Player#locked_until`, `Player#score`.
- `Game#try_claim!(player)` (atomic, with `lock!`) per §6.
- `Claim#submit!(card_ids)` validates the Set, updates score, replaces cards.
- Phone controller states from §8: idle, claim-active-mine (12-card grid). Auto-submit on third tap (with the 250ms delay from §11).
- **Acceptance:** one phone calls SET, picks 3, sees score change after refresh. Wrong picks lower the score. The board reflects updates after refresh.

### Step 9 — Realtime sync via Turbo Streams
**Goal:** updates propagate instantly to every connected device. No more refreshes.

- `Game.broadcasts_to` and `Player.broadcasts_to` per §7.
- `turbo_stream_from "game:#{code}"` in board and controller views; `turbo_stream_from "player:#{id}"` in controller view.
- `bin/rails test:system` covering: claim on one phone updates the board on another within 1 second.
- **Acceptance:** with two phones and a board open, action on any device propagates live everywhere.

**Resolved issue:** `spec/system/realtime_sync_spec.rb` was skipped as flaky. Two causes, both fixed:
phone and board actions redirected, and the page reload dropped the stream subscription for about
500 ms, losing any broadcast in that window. Every request also touched `last_seen_at`, which
broadcast a stale controller state that the `async` adapter could deliver after the real one. Actions
now answer `204 No Content` and rely on the broadcast, and `Player#seen!` records `last_seen_at`
without callbacks.

### Step 10 — Claim timeout (15s)
**Goal:** a held claim that doesn't submit auto-expires server-side.

- `ExpireClaimJob` enqueued on claim creation (`set(wait: Game::CLAIM_TIMEOUT.seconds)`). Idempotent: re-checks state on run.
- Countdown ring on phone (CSS animation driven by `data-claim-started-at`).
- Phone state from §8: claim-active-others ("Alex is calling SET! 4… 3…").
- **Acceptance:** call SET, ignore the timer, watch it auto-expire and unfreeze the board within 1s of the deadline.

### Step 11 — Wrong-claim lockout
**Goal:** a wrong submission penalizes the player and bars them for 15s.

- On wrong claim, set `Player#locked_until = Game::CLAIM_TIMEOUT.seconds.from_now` inside the same transaction.
- Server rejects further claims from a locked player.
- Phone state: locked-out (SET button greyed out with countdown ring).
- **Acceptance:** deliberately submit a wrong Set, see your SET button disabled for 15s while others remain free.

### Step 12 — No-Set mechanic
**Goal:** the table can collectively decide there is no Set, draw 3 more cards.

- "No Set" button in the controller's idle state.
- `Game#call_no_set!`, `#join_no_set!`, `#cancel_no_set!`. New SET claim cancels an active No-Set.
- `ExpireNoSetJob` (`wait: 15.seconds`); resolves immediately if all currently active players have joined.
- On resolution: deal 3 more cards (cap at 18 per §2).
- **Acceptance:** with a contrived board having no Set, call No Set, watch 3 cards deal at expiry. With multiple players, joining the call all-around resolves immediately.

### Step 13 — Game end + Play again
**Goal:** the game has a clean stop and restart.

- `Game#ended?` per §6 (deck empty AND no Set on board).
- End screen on board (final scoreboard, top-3 podium); end screen on phone ("Game over — final score: X").
- `POST /games/:code/restart` resets deck/scores, status → `playing`.
- "Play again" button (host only).
- **Acceptance:** play to deck exhaustion, see end screen, click Play Again, new game starts in the same room with fresh state.

### Step 14 — Stimulus polish
**Goal:** phone interactions feel instant and forgiving.

- `card_selection_controller` — local highlight state, deselect on re-tap, auto-submit at 3 with 250ms grace window.
- `countdown_ring_controller` — smooth visual, decoupled from server tick rate.
- Button enable/disable transitions tied to data attributes the server already broadcasts.
- **Acceptance:** misclicks during selection are recoverable; countdown rings render smoothly across devices.

### Step 15 — Idle game cleanup
**Goal:** dead rooms don't accumulate forever.

- `CleanupIdleGamesJob` per §12, scheduled hourly via `config/recurring.yml`.
- Cascading destroy on Game removes Players and Claims.
- **Acceptance:** in console, `Game.first.update_column(:updated_at, 25.hours.ago)`, run the job, the game is gone.

### Step 16 — Visual + UX polish (real screens)
**Goal:** the game looks and feels correct on a TV across the room and on a phone in hand.

- Card deal/remove CSS transitions.
- Tune palette saturation, stripe density, type sizes for TV viewing distance.
- Mobile layout tuning with a real phone, not just devtools.
- Cold-start mitigation: optional "Wake server" splash on the landing page (§16-decisions).
- **Acceptance:** subjective — sit on a couch with the board on a TV and a phone in hand; if it feels right, ship.

### Step 17 — Real-game test with humans
**Goal:** find the bugs only real play surfaces.

- 3+ friends, real TV, real phones, real network.
- Document what breaks; open issues, fix, re-test.
- **Acceptance:** a full game finishes without intervention.

### Conventions for every step

- Commit message starts with `Step N:` and references the step's goal.
- Tests added or updated as part of the step (not deferred to a "tests later" pass).
- After every step, `bin/rails test` passes locally and `bin/kamal deploy` succeeds.

---

## 16. Open items to confirm during implementation

- **Color presets for player choice** (8 distinct hex values that don't collide with the card palette).
- **Squiggle SVG path** — the canonical Set squiggle is a specific bezier; pick one and commit to it.
- **Striped pattern density** — visually tune in browser; aim for clearly distinguishable from solid at TV viewing distance.
- **Auto-submit timing** — resolved: no auto-submit. An explicit Submit at three picks judges the claim at once, and the picks are judged when the time runs out otherwise (§11).
- **Cold-start mitigation** — consider a "Wake the server" splash on the landing page that does a low-cost ping while the user reads instructions.

---

## 17. Telemetry

Analytics go to PostHog and errors to Sentry through the [`jt_telemetry`](https://github.com/joaotorres/jt-telemetry) gem, shared by the joaotorr.es apps. How it works, its settings and its defaults are in its [README](https://github.com/joaotorres/jt-telemetry#readme); this section covers only what Onset adds.

### Setup

- The layout calls `jt_telemetry_tags` in `<head>`, before the importmap tags. Telemetry is on in production only.
- `APP_NAME` is `onset` (clear env, §13): the `app` property on every PostHog event and the `app` tag in Sentry.
- `SENTRY_DSN` is a secret: `.kamal/secrets` reads it from the Keychain item `onset-sentry-dsn` (§13, `docs/deploy.md`).
- The image build's `assets:precompile` needs no telemetry setting: the gem turns itself off under `SECRET_KEY_BASE_DUMMY`.

### Custom events

Every event goes through `window.jtTrack(name, props)`, which the gem defines in every environment, so app code calls it as `window.jtTrack?.(...)`. Names and properties are snake_case.

| Event | Properties | Fires |
|---|---|---|
| `game_created` | `mode` (`standard` or `quick`) | `GamesController#create`, sent from the creator's join page |
| `player_joined` | `player_count` (the room's players, the new one included), `is_creator` (this browser holds the room's `host_game` cookie), `mode` | `PlayersController#create`, sent from the new player's player screen |
| `invite_shared` | `method`: `web_share` (the share sheet completed), `copy` (the link was copied) or `qr` (Show QR opened) | The waiting invite (`invite` controller, §8 Player screen) |
| `game_started` | `mode`, `player_count` | Status `waiting` to `playing`: the host's Start game or the ready vote |
| `game_restarted` | `mode`, `player_count` | Status `ended` to `playing`: the big screen's Play again or the ready vote |
| `game_finished` | `mode`, `player_count`, `end_reason` (`quick_win`, `vote` or `deck_exhausted`), `is_tie` (no sole winner), `duration_seconds` when known | Status `playing` to `ended` |

**Server actions ride the flash.** `game_created` and `player_joined` happen in an action that redirects, so no page is there to send them. `track_event` (`TracksEvents`, included in `ApplicationController`) appends the event to `flash[:tracked_events]`. The next page's layout renders it into a hidden `track` controller element, which sends each event once on connect and then empties its value, so a Turbo restoration visit to the cached page does not send it again. Nothing calls PostHog from the server.

**Game state events come from one player screen.** The status reaches every screen by broadcast (§7), so no request marks a game starting, restarting or finishing. `#controller_status` carries a hidden `game-events` element (`TrackingHelper#game_events_tag`) with the room code, the status, the event properties and whether this player is the reporter. On each render the `game-events` controller compares the status with the last one this tab saw for the room; an event is a change it saw. Every player screen keeps track, and only the reporter sends: the player at the top of the standings (`Game#standings.first`, ties in join order), so each event is counted once. If the reporter's screen is not open at that moment, the event is not sent. The big screen sends no game events.

**`duration_seconds` is measured on the screen.** Each player screen notes when it saw play start, and `game_finished` carries the seconds from then to the finish. A reporter screen opened fresh mid-game (a closed and reopened tab, another browser) did not see play start, so its `game_finished` leaves `duration_seconds` out. `Game` has no `started_at` column; adding one would make the duration exact, from the server, for every game.

**Not tracked, on purpose.**

- `start_method` on `game_started`: the screen sees only the change of status, so it cannot tell whether the host pressed Start game or everyone voted ready.
- `set_found`: it fires many times per game.
- `claim_submitted`: a Submit tap (§11) happens once per claim, many times per game, for the same reason. Whether claims are submitted or left to the timer can be read from the `Claim` records (`resolved_at` well before `started_at` plus the timeout) without an event.

### Privacy

PostHog runs with memory persistence: it sets no cookies and keeps nothing in browser storage, so there is no consent banner. Onset's own browser state is unchanged by telemetry, apart from one `sessionStorage` entry per room for the `game-events` controller (`onset.game.<code>`: the last status this tab saw and when it saw play start), which never leaves the browser.

---

End of spec.
