require "rails_helper"

RSpec.describe "Stimulus polish", type: :system do
  before { driven_by :selenium, using: :headless_chrome }

  # Creates a started game through the UI (committed to DB so the browser can see it),
  # then joins a player and puts the game into claim-active state.
  def setup_claim_state
    visit root_path
    click_button "Start a game"
    game_code = find("p.text-5xl").text

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
    expect(countdown["data-countdown-duration-value"]).to eq("5")
    expect(countdown["data-countdown-started-at-value"]).to be_present
    expect(page).to have_css("[data-countdown-target='ring']")
    expect(page).to have_css("[data-countdown-target='display']")
  end
end
