require "rails_helper"

# SPEC §8 Settings menu and Player screen: the settings button in the
# "Room CODE" footer row while waiting and at game over, at 667x375.
# During play: landscape_play_spec.rb.
RSpec.describe "Settings button on the player screen, landscape", type: :system do
  include_context "player screen theme"
  include_context "player screen with 8 players and 18 cards", 667, 375

  it "sits in the footer while waiting and at game over, the menu opening above it" do
    waiting!
    visit game_controller_path(game.code)
    expect(page).to have_content("You're in")
    expect_settings_in_footer(right: 8)

    game_over!
    visit game_controller_path(game.code)
    expect(page).to have_css("[data-rank]")
    expect_settings_in_footer(right: 8)
    open_settings
    menu = rect("#settings_menu")
    expect(rect('button[aria-label="Settings"]')["top"] - menu["bottom"]).to be_within(1).of(8)
    expect(menu["top"]).to be >= 0
  end
end
