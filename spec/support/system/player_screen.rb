# Shared by the spec files in spec/system/player_screen/: the player screen during play.
module PlayerScreenStates
  EIGHT_NAMES = ["Bartholomew Ashworth", "Alexandria Pemberton", "Samuel Wainwright", "Priya Ramanathan",
    "Jonas Oppenheimer", "Mei Lin Takahashi", "Tomás Villanueva", "Leopold Fairweather"].freeze

  # Each runs inside the example, so it sees game, me, other and resolve.
  ALL = {
    "idle" => proc {},
    "deck empty" => proc { game.update!(deck: []) },
    "claiming (mine)" => proc { game.try_claim!(me) },
    "someone else claiming" => proc { game.try_claim!(other) },
    "No Set countdown" => proc { game.call_no_set!(other) },
    "No Set countdown, agreed" => proc {
      game.call_no_set!(other)
      game.join_no_set!(me)
    },
    "No Set countdown, locked out" => proc {
      me.update!(locked_until: 5.seconds.from_now)
      game.call_no_set!(other)
    },
    "No Set blocked" => proc {
      game.call_no_set!(other)
      game.refuse_no_set!(game.players.order(:id).third)
    },
    "locked out, wrong" => proc { resolve(me, :wrong) },
    "locked out, time's up" => proc { resolve(me, :expired) },
    "found-set banner" => proc {
      claim = game.claims.create!(player: other, result: :correct, card_ids: game.board.first(3), started_at: Time.current, resolved_at: Time.current)
      game.update!(flash_claim_id: claim.id, last_dealt: game.board.last(3))
    }
  }.freeze
end

RSpec.shared_context "player screen" do
  include_context "resizable window"

  let(:game) { Game.create! }
  let(:me) { game.players.order(:id).first }
  let(:other) { game.players.order(:id).second }

  def play_state(name) = instance_exec(&PlayerScreenStates::ALL.fetch(name))

  # The page itself, and main inside it (h-dvh, overflow hidden), must not overflow.
  def overflow
    page.evaluate_script(<<~JS)
      (() => {
        const d = document.documentElement, m = document.querySelector("main")
        return [d.scrollHeight - window.innerHeight, d.scrollWidth - window.innerWidth, m.scrollHeight - m.clientHeight]
      })()
    JS
  end

  # The board must never scroll sideways: its scroll width equals its client width.
  def board_overflow
    page.evaluate_script("(() => { const b = document.querySelector('[data-board]'); return [b.scrollWidth - b.clientWidth, b.scrollHeight - b.clientHeight]; })()")
  end

  def board_height
    page.evaluate_script("document.querySelector('[data-board]').clientHeight")
  end

  def card_size = rect("[data-card-id]").values_at("width", "height")

  def scoreboard_rows
    page.evaluate_script("new Set([...document.querySelectorAll('[data-scoreboard] li')].map(li => Math.round(li.getBoundingClientRect().top))).size")
  end

  # Left edges of the board, the action column and the scores column, in that order.
  def column_lefts
    page.evaluate_script("['[data-board]', '[data-action-column]', '[data-scoreboard]'].map(s => Math.round(document.querySelector(s).getBoundingClientRect().left))")
  end

  def scoreboard_bottom
    page.evaluate_script("Math.max(...[...document.querySelectorAll('[data-scoreboard] li')].map(li => li.getBoundingClientRect().bottom)) <= window.innerHeight")
  end

  # The computer layout: the board left, a 248px side column right with the scoreboard above the status slot (or the claim block).
  def expect_computer_layout(panel: "[data-status-slot]")
    board = rect("[data-board]")
    scores = rect("[data-scoreboard]")
    status = rect(panel)
    expect(scores["width"]).to be_within(1).of(248)
    expect(scores["left"]).to be >= board["right"]
    expect(status["left"]).to be_within(1).of(scores["left"])
    expect(status["top"]).to be >= scores["bottom"]
  end

  def centre(selector)
    r = rect(selector)
    r["left"] + r["width"] / 2
  end

  # The "Room CODE" footer centres on the board, directly under the deck line, during play (§8, Deck).
  def expect_footer_on_board
    footer = rect("main > p")
    deck = rect("[data-board] + p")
    expect(centre("main > p")).to be_within(1).of(centre("[data-board] + p"))
    expect(centre("main > p")).to be_within(1).of(centre("[data-board]"))
    expect(footer["top"] - deck["bottom"]).to be_between(0, 8)
  end

  def start_with(names, cards:)
    visit join_game_players_path(game.code)
    fill_in "player[name]", with: names.first
    all("label.cursor-pointer").first.click
    click_button "Join"
    expect(page).to have_current_path(game_controller_path(game.code))

    taken = game.players.pluck(:color)
    names.drop(1).zip(Player::PRESET_COLORS - taken).each do |name, color|
      game.players.create!(name: name, color: color, last_seen_at: Time.current)
    end
    game.start!
    game.update!(board: (0...cards).to_a, deck: (cards..80).to_a)
  end

  def resolve(player, result)
    claim = game.try_claim!(player)
    claim.update!(result: result, resolved_at: Time.current, card_ids: (result == :wrong) ? game.board.first(3) : [])
    game.release_claim!
    player.update!(locked_until: 5.seconds.from_now)
  end
end

RSpec.shared_context "player screen with 8 players and 18 cards" do |width, height|
  before do
    start_with(PlayerScreenStates::EIGHT_NAMES, cards: 18)
    game.players.where.not(id: [me.id, other.id]).first.update!(locked_until: 5.seconds.from_now)
    resize(width, height)
  end
end

RSpec.shared_context "player screen with 3 players and 12 cards" do |width, height|
  before do
    start_with(%w[Ada Alex Sam], cards: 12)
    resize(width, height)
  end
end

RSpec.shared_examples "fits the portrait screen" do |*names|
  names.each do |name|
    it "keeps no page scroll at 375x667 while #{name}" do
      play_state(name)
      visit game_controller_path(game.code)
      expect(page).to have_css("[data-scoreboard] li", count: 8)
      expect(page).to have_css("[data-card-id]", count: 18)
      expect(scoreboard_rows).to eq(2)
      expect(overflow).to eq([0, 0, 0])
      expect(page).to have_css("[data-status-slot]")
      expect(page).to have_no_css("header")
    end
  end
end

RSpec.shared_examples "fits the landscape screen" do |*names|
  names.each do |name|
    it "keeps no page or board scroll at 667x375 while #{name}" do
      play_state(name)
      visit game_controller_path(game.code)
      expect(page).to have_css("[data-scoreboard] li", count: 8)
      expect(page).to have_css("[data-card-id]", count: 18)
      expect(overflow).to eq([0, 0, 0])
      expect(board_overflow).to eq([0, 0])
      lefts = column_lefts
      expect(lefts).to eq(lefts.sort)
      expect(scoreboard_bottom).to be(true)
      width, height = card_size
      expect(width).to be >= 50
      expect(height).to be_within(2).of(width * 7 / 5)
      expect(page).to have_no_css("header")
    end
  end
end

RSpec.shared_examples "fits the computer screen" do |*names|
  names.each do |name|
    it "keeps no page or board scroll at 1024x640 while #{name}" do
      play_state(name)
      visit game_controller_path(game.code)
      expect(page).to have_css("[data-scoreboard] li", count: 8)
      expect(page).to have_css("[data-card-id]", count: 18)
      expect(overflow).to eq([0, 0, 0])
      expect(board_overflow).to eq([0, 0])
      if name == "claiming (mine)"
        expect_computer_layout(panel: "[data-claim-block]")
        expect(find("[data-pill-slot]").text).to eq("Submit")
      else
        expect_computer_layout
        status = rect("[data-status-slot]")
        expect([status["width"], status["height"]]).to eq([248, 76])
      end
      width, height = card_size
      expect(width).to be_within(3).of(106)
      expect(height).to be_within(3).of(148)
      expect(page).to have_no_css("header")
    end
  end
end

RSpec.shared_examples "centres the footer on the board" do |width, height|
  ["idle", "claiming (mine)", "No Set countdown", "deck empty"].each do |name|
    it "centres the footer on the board at #{width}x#{height} while #{name}" do
      resize(width, height)
      play_state(name)
      visit game_controller_path(game.code)
      expect(page).to have_css("[data-card-id]", count: 18)
      expect_footer_on_board
      expect(overflow).to eq([0, 0, 0])
    end
  end
end
