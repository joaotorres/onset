require "rails_helper"

RSpec.describe "Stimulus polish", type: :system do
  before { driven_by :selenium, using: :headless_chrome }

  # Creates a started game through the UI (committed to DB so the browser can see it),
  # then joins a player and puts the game into claim-active state.
  def setup_claim_state
    visit root_path
    click_button "Start a game"
    expect(page).to have_current_path(%r{\A/games/\w+\z})
    game_code = current_path.split("/").last

    visit join_game_players_path(game_code)
    fill_in "player[name]", with: "Alice"
    all("label.cursor-pointer").first.click
    click_button "Join"
    # browser is now on the controller page with player_token cookie set

    game = Game.find_by!(code: game_code)
    game.start!

    player = game.players.find_by!(name: "Alice")
    game.claims.create!(player: player, result: :pending, started_at: Time.current)
    game.update!(claim_player_id: player.id, claim_started_at: Time.current)

    visit game_controller_path(game_code)
    player
  end

  it "highlights a card on tap and removes highlight on re-tap (deselect)" do
    setup_claim_state

    cards = all("[data-card-id]")
    first_card = cards.first

    first_card.click
    expect(first_card[:class]).to include("ring-4")

    first_card.click
    expect(first_card[:class]).not_to include("ring-4")
  end

  it "selecting two cards and deselecting one leaves only one highlighted" do
    setup_claim_state

    cards = all("[data-card-id]")
    cards[0].click
    cards[1].click
    expect(cards[0][:class]).to include("ring-4")
    expect(cards[1][:class]).to include("ring-4")

    cards[0].click
    expect(cards[0][:class]).not_to include("ring-4")
    expect(cards[1][:class]).to include("ring-4")
  end

  it "countdown ring is present in the DOM with correct data attributes" do
    setup_claim_state

    countdown = find("[data-controller='countdown']")
    expect(countdown["data-countdown-duration-value"]).to eq(Game::CLAIM_TIMEOUT.to_s)
    expect(countdown["data-countdown-started-at-value"]).to be_present
    expect(page).to have_css("[data-countdown-target='ring']")
    expect(page).to have_css("[data-countdown-target='display']")
  end

  describe "striped cards after a tap" do
    # Returns the problems found: duplicate ids in the document, and url(#id)
    # fills in any SVG that do not resolve to an element inside that SVG.
    def svg_id_problems = page.evaluate_script("(() => { #{svg_id_problems_js} })()")

    def svg_id_problems_js = <<~JS
      const problems = []
      const seen = {}
      document.querySelectorAll("[id]").forEach(el => {
        if (seen[el.id]) problems.push("duplicate id " + el.id)
        seen[el.id] = true
      })
      document.querySelectorAll("svg").forEach(svg => {
        svg.querySelectorAll("[fill^='url(']").forEach(el => {
          const id = el.getAttribute("fill").slice(5, -1) // url(#id)
          if (!svg.querySelector("[id='" + id + "']")) problems.push("fill " + id + " not inside its own svg")
        })
      })
      return problems
    JS

    # Ids 1, 4 and 7 are blue striped, 10 orange striped.
    def setup_striped_claim(width:, height:)
      page.driver.browser.manage.window.resize_to(width, height)
      player = setup_claim_state
      player.game.update!(board: (0..11).to_a)
      visit game_controller_path(player.game.code)
    end

    def striped_cards_resolve!
      expect(page).to have_css("[data-card-id='4'] svg")
      expect(page.evaluate_script("document.querySelectorAll(\"[data-card-selection-target='card'] svg [fill^='url(']\").length")).to be > 0
      expect(svg_id_problems).to eq([])
    end

    it "keeps ids unique and fills inside their own SVG in a landscape window" do
      setup_striped_claim(width: 1280, height: 800)

      find("[data-card-id='4']").click
      expect(find("[data-card-id='4']")[:class]).to include("ring-4")
      striped_cards_resolve!
    end

    it "points the tray copy at a pattern inside the copy in a portrait window" do
      setup_striped_claim(width: 420, height: 900)

      find("[data-card-id='4']").click
      expect(page).to have_css("[data-slot-card-id='4'] svg pattern", visible: :all)
      striped_cards_resolve!
    end

    it "leaves no duplicate ids after deselecting and re-selecting" do
      setup_striped_claim(width: 1280, height: 800)

      card = find("[data-card-id='7']")
      card.click
      card.click
      card.click
      expect(page).to have_css("[data-slot-card-id='7'] svg", visible: :all)
      striped_cards_resolve!
    end
  end
end
