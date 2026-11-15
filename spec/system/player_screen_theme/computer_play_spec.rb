require "rails_helper"

# SPEC §8 Settings menu and Player screen: on a computer during play the
# settings button sits at the right end of the Room footer under the deck
# line, on the board column's right edge, the menu opening above it.
RSpec.describe "Settings button on the player screen during play, computer", type: :system do
  include_context "player screen theme"
  include_context "player screen with 8 players and 18 cards", 1024, 640

  def board_column_right = 1024 - rect("[data-board]")["right"]

  it "sits at the board column's right edge during play without moving the board" do
    play_states.each do |name|
      play_state!(name)
      visit game_controller_path(game.code)
      expect(page).to have_css("[data-card-id]", count: 18)
      expect_settings_in_footer(right: board_column_right)
      width, height = card_size
      expect(width).to be_within(3).of(106)
      expect(height).to be_within(3).of(148)
    end

    open_settings
    menu = rect("#settings_menu")
    button = rect('button[aria-label="Settings"]')
    expect(menu["right"]).to be_within(1).of(button["right"])
    expect(button["top"] - menu["bottom"]).to be_within(1).of(8)
  end
end
