# Shared by the spec files in spec/system/stimulus_polish/.
RSpec.shared_context "stimulus polish" do
  before { driven_by :selenium, using: :headless_chrome }

  # Creates a started game through the UI (committed to DB so the browser can see it),
  # then joins a player and puts the game into claim-active state.
  def setup_claim_state
    visit root_path
    click_button "Start a game"
    expect(page).to have_current_path(%r{\A/games/\w+/players/join\z})
    game_code = current_path.split("/")[2]

    fill_in "player[name]", with: "Alice"
    all("label.cursor-pointer").first.click
    click_button "Join"
    expect(page).to have_current_path(game_controller_path(game_code))

    game = Game.find_by!(code: game_code)
    game.start!

    player = game.players.find_by!(name: "Alice")
    game.claims.create!(player: player, result: :pending, started_at: Time.current)
    game.update!(claim_player_id: player.id, claim_started_at: Time.current)

    visit game_controller_path(game_code)
    player
  end
end
