require "rails_helper"

RSpec.describe "Player screen during play, computer", type: :system do
  before { driven_by :selenium, using: :headless_chrome }
  # Later specs expect the default window size.
  after { page.driver.browser.manage.window.resize_to(1400, 1400) }

  let(:game) { Game.create! }
  let(:me) { game.players.order(:id).first }
  let(:other) { game.players.order(:id).second }

  def resize(width, height)
    page.driver.browser.manage.window.resize_to(width, height)
    # Headless Chrome sizes the window, not the viewport: pad until the viewport matches.
    inner = page.evaluate_script("[window.innerWidth, window.innerHeight]")
    page.driver.browser.manage.window.resize_to(2 * width - inner[0], 2 * height - inner[1])
  end

  # The page itself, and main inside it (h-dvh, overflow hidden), must not overflow.
  def overflow
    page.evaluate_script(<<~JS)
      (() => {
        const d = document.documentElement, m = document.querySelector("main")
        return [d.scrollHeight - window.innerHeight, d.scrollWidth - window.innerWidth, m.scrollHeight - m.clientHeight]
      })()
    JS
  end

  def board_overflow
    page.evaluate_script("(() => { const b = document.querySelector('[data-board]'); return [b.scrollWidth - b.clientWidth, b.scrollHeight - b.clientHeight]; })()")
  end

  def rect(selector)
    page.evaluate_script("(() => { const r = document.querySelector(#{selector.to_json}).getBoundingClientRect(); return {left: r.left, right: r.right, top: r.top, bottom: r.bottom, width: r.width, height: r.height}; })()")
  end

  def card_size
    r = rect("[data-card-id]")
    [r["width"], r["height"]]
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

  def start_with(names, cards:)
    visit join_game_players_path(game.code)
    fill_in "player[name]", with: names.first
    all("label.cursor-pointer").first.click
    click_button "Join"
    expect(page).to have_current_path(game_controller_path(game.code))

    taken = game.players.pluck(:color)
    names.drop(1).zip(PlayersController::PRESET_COLORS - taken).each do |name, color|
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

  states = {
    "idle" => ->(_) {},
    "deck empty" => ->(_) { game.update!(deck: []) },
    "claiming (mine)" => ->(_) { game.try_claim!(me) },
    "someone else claiming" => ->(_) { game.try_claim!(other) },
    "No Set countdown" => ->(_) { game.call_no_set!(other) },
    "No Set countdown, agreed" => ->(_) {
      game.call_no_set!(other)
      game.join_no_set!(me)
    },
    "No Set countdown, locked out" => ->(_) {
      me.update!(locked_until: 5.seconds.from_now)
      game.call_no_set!(other)
    },
    "No Set blocked" => ->(_) {
      game.call_no_set!(other)
      game.refuse_no_set!(game.players.order(:id).third)
    },
    "locked out, wrong" => ->(_) { resolve(me, :wrong) },
    "locked out, time's up" => ->(_) { resolve(me, :expired) },
    "found-set banner" => ->(_) {
      claim = game.claims.create!(player: other, result: :correct, card_ids: game.board.first(3), started_at: Time.current, resolved_at: Time.current)
      game.update!(flash_claim_id: claim.id, last_dealt: game.board.last(3))
    }
  }

  context "with 8 players and 18 cards" do
    before do
      start_with(["Bartholomew Ashworth", "Alexandria Pemberton", "Samuel Wainwright", "Priya Ramanathan",
        "Jonas Oppenheimer", "Mei Lin Takahashi", "Tomás Villanueva", "Leopold Fairweather"], cards: 18)
      game.players.where.not(id: [me.id, other.id]).first.update!(locked_until: 5.seconds.from_now)
      resize(1024, 640)
    end

    states.each do |name, setup|
      it "keeps no page or board scroll at 1024x640 while #{name}" do
        instance_exec(nil, &setup)
        visit game_controller_path(game.code)
        expect(page).to have_css("[data-scoreboard] li", count: 8)
        expect(page).to have_css("[data-card-id]", count: 18)
        expect(overflow).to eq([0, 0, 0])
        expect(board_overflow).to eq([0, 0])
        if name == "claiming (mine)"
          expect_computer_layout(panel: "[data-claim-block]")
          expect(find("[data-pill-slot]", visible: :all).text).to eq("")
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

    it "lays the found-set banner over the top of the board area" do
      instance_exec(nil, &states["found-set banner"])
      visit game_controller_path(game.code)
      banner = rect("[data-found-banner]")
      board = rect("[data-board]")
      scores = rect("[data-scoreboard]")
      expect(banner["left"]).to be_within(2).of(board["left"])
      expect(banner["right"]).to be <= scores["left"]
      expect(banner["top"]).to be_within(16).of(board["top"])
    end

    it "shows the 108px SET! while idle" do
      visit game_controller_path(game.code)
      button = rect("[data-set-slot] button")
      expect(button["width"]).to be_within(1).of(108)
    end
  end

  context "with 3 players and 12 cards" do
    before do
      start_with(%w[Ada Alex Sam], cards: 12)
      resize(1024, 640)
    end

    it "calls SET! on an idle card tap and opens the claim block at 1/3" do
      visit game_controller_path(game.code)
      expect(page).to have_css("turbo-cable-stream-source[connected]", count: 2, visible: :all)
      find("[data-card-id='4']").click

      expect(page).to have_css("[data-claim-block]", text: "Your SET!")
      expect(find("[data-card-id='4']")["aria-pressed"]).to eq("true")
      counts = all("[data-card-selection-target='count']", visible: true).map(&:text)
      expect(counts).to eq(["1"])
      expect(page).to have_no_button("SET!")
      expect(page).to have_no_css("[data-card-selection-target='slot']", visible: true)
      expect(overflow).to eq([0, 0, 0])
    end

    it "uses the computer layout in a 1024x1366 portrait viewport" do
      resize(1024, 1366)
      visit game_controller_path(game.code)
      expect_computer_layout
      expect(overflow).to eq([0, 0, 0])
    end

    it "keeps the landscape layout at 1023x640" do
      resize(1023, 640)
      visit game_controller_path(game.code)
      lefts = page.evaluate_script("['[data-board]', '[data-action-column]', '[data-scoreboard]'].map(s => Math.round(document.querySelector(s).getBoundingClientRect().left))")
      expect(lefts).to eq(lefts.sort)
      expect(rect("[data-scoreboard]")["width"]).to be_within(1).of(132)
      expect(overflow).to eq([0, 0, 0])
    end
  end

  # The "Room CODE" footer centres on the board, directly under the deck line, during play (§8, Deck).
  def centre(selector)
    r = rect(selector)
    r["left"] + r["width"] / 2
  end

  def expect_footer_on_board
    footer = rect("main > p")
    deck = rect("[data-board] + p")
    expect(centre("main > p")).to be_within(1).of(centre("[data-board] + p"))
    expect(centre("main > p")).to be_within(1).of(centre("[data-board]"))
    expect(footer["top"] - deck["bottom"]).to be_between(0, 8)
  end

  context "with the Room CODE footer" do
    before { start_with(["Bartholomew Ashworth", "Alexandria Pemberton", "Samuel Wainwright"], cards: 18) }

    [[1024, 640], [1280, 800]].each do |width, height|
      ["idle", "claiming (mine)", "No Set countdown", "deck empty"].each do |name|
        it "centres the footer on the board at #{width}x#{height} while #{name}" do
          resize(width, height)
          instance_exec(nil, &states[name])
          visit game_controller_path(game.code)
          expect(page).to have_css("[data-card-id]", count: 18)
          expect_footer_on_board
          expect(overflow).to eq([0, 0, 0])
        end
      end
    end

    it "keeps the footer on the board after a Turbo update" do
      resize(1024, 640)
      visit game_controller_path(game.code)
      expect(page).to have_css("turbo-cable-stream-source[connected]", count: 2, visible: :all)
      game.try_claim!(other)
      expect(page).to have_css("[aria-label=\"SET! unavailable, #{other.name} is claiming\"]")
      expect_footer_on_board
    end

    it "keeps the footer centred on the screen at 375x667 and 667x375" do
      [[375, 667], [667, 375]].each do |width, height|
        resize(width, height)
        visit game_controller_path(game.code)
        expect(page).to have_css("[data-card-id]", count: 18)
        expect(centre("main > p")).to be_within(1).of(page.evaluate_script("window.innerWidth") / 2.0)
      end
    end
  end

  it "keeps the footer centred on the screen while waiting" do
    visit join_game_players_path(game.code)
    fill_in "player[name]", with: "Ada"
    all("label.cursor-pointer").first.click
    click_button "Join"
    resize(1024, 640)
    expect(page).to have_text("You're in")
    expect(centre("main > p")).to be_within(1).of(512)
  end
end
