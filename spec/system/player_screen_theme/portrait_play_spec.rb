require "rails_helper"

# SPEC §8 Settings menu and Player screen: the settings button in the
# "Room CODE" footer row during play, adding no height, at 375x667.
RSpec.describe "Settings button on the player screen during play, portrait", type: :system do
  include_context "player screen theme"
  include_context "player screen with 8 players and 18 cards", 375, 667

  it "sits in the footer during play without moving the board" do
    play_states.each do |name|
      play_state!(name)
      visit game_controller_path(game.code)
      expect(page).to have_css("[data-card-id]", count: 18)
      expect_settings_in_footer(right: 8)
      expect_card_size_unchanged(name)
    end
  end
end
