require "rails_helper"

# DESIGN Settings button placement: on the player screen on a computer the open
# menu sits on the board column's right edge, 46px from the bottom, during
# play, and 40px from the right and 48px from the bottom while waiting and at
# game over.
RSpec.describe "Settings menu offsets on the player screen, computer", type: :system do
  include_context "player screen theme"
  include_context "player screen with 8 players and 18 cards", 1024, 640

  def expect_menu_offsets(state, right:, bottom:)
    open_settings
    menu = rect("#settings_menu")
    width, height = page.evaluate_script("[window.innerWidth, window.innerHeight]")
    expect(width - menu["right"]).to be_within(1).of(right), state
    expect(height - menu["bottom"]).to be_within(1).of(bottom), state
  end

  it "opens on the board column's right edge, 46px from the bottom, during play" do
    visit game_controller_path(game.code)
    expect(page).to have_css("[data-card-id]", count: 18)
    expect_menu_offsets("play", right: 1024 - rect("[data-board]")["right"], bottom: 46)
  end

  it "opens 40px from the right and 48px from the bottom while waiting and at game over" do
    waiting!
    visit game_controller_path(game.code)
    expect(page).to have_content("You're in")
    expect_menu_offsets("waiting", right: 40, bottom: 48)

    game_over!
    visit game_controller_path(game.code)
    expect(page).to have_css("[data-rank]")
    expect_menu_offsets("game over", right: 40, bottom: 48)
  end
end
