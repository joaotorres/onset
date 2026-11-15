require "rails_helper"

# SPEC §8 Settings menu and Player screen: on a computer the settings button
# sits 40px from the right of the footer while waiting and at game over.
# During play: computer_play_spec.rb.
RSpec.describe "Settings button on the player screen, computer", type: :system do
  include_context "player screen theme"
  include_context "player screen with 8 players and 18 cards", 1024, 640

  it "sits 40px from the right while waiting and at game over, 40x32" do
    waiting!
    visit game_controller_path(game.code)
    expect(page).to have_content("You're in")
    expect_settings_in_footer(right: 40, height: 32)

    game_over!
    visit game_controller_path(game.code)
    expect(page).to have_css("[data-rank]")
    expect_settings_in_footer(right: 40, height: 32)
  end
end
