require "rails_helper"

RSpec.describe "Player screen during play, portrait", type: :system do
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

  def scoreboard_rows
    page.evaluate_script("new Set([...document.querySelectorAll('[data-scoreboard] li')].map(li => Math.round(li.getBoundingClientRect().top))).size")
  end

  def card_size
    page.evaluate_script("(() => { const r = document.querySelector('[data-card-id]').getBoundingClientRect(); return [r.width, r.height]; })()")
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
      resize(375, 667)
    end

    states.each do |name, setup|
      it "keeps no page scroll at 375x667 while #{name}" do
        instance_exec(nil, &setup)
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

  context "with 3 players and 12 cards" do
    before do
      start_with(%w[Ada Alex Sam], cards: 12)
      resize(375, 667)
    end

    it "makes the cards larger" do
      visit game_controller_path(game.code)
      expect(page).to have_css("[data-card-id]", count: 12)
      width, height = card_size
      expect(width).to be >= 65
      expect(height).to be_within(2).of(width * 7 / 5)
      expect(overflow).to eq([0, 0, 0])
    end

    it "opens the claim at 1/3 with the tapped card selected" do
      visit game_controller_path(game.code)
      expect(page).to have_css("turbo-cable-stream-source[connected]", count: 2, visible: :all)
      find("[data-card-id='4']").click

      expect(page).to have_content("Your SET!")
      expect(find("[data-card-id='4']")["aria-pressed"]).to eq("true")
      counts = all("[data-card-selection-target='count']", visible: true).map(&:text)
      expect(counts).to eq(["1"])
      expect(overflow).to eq([0, 0, 0])
    end
  end
end
