require "rails_helper"

# DESIGN Settings button placement: on the player screen in portrait the open
# menu sits 8px from the right and 46px from the bottom in every state.
RSpec.describe "Settings menu offsets on the player screen, portrait", type: :system do
  include_context "player screen theme"
  include_context "player screen with 8 players and 18 cards", 375, 667

  def expect_menu_offsets(state, right:, bottom:)
    open_settings
    menu = rect("#settings_menu")
    width, height = page.evaluate_script("[window.innerWidth, window.innerHeight]")
    expect(width - menu["right"]).to be_within(1).of(right), state
    expect(height - menu["bottom"]).to be_within(1).of(bottom), state
  end

  it "opens 8px from the right and 46px from the bottom during play, waiting and at game over" do
    visit game_controller_path(game.code)
    expect(page).to have_css("[data-card-id]", count: 18)
    expect_menu_offsets("play", right: 8, bottom: 46)

    waiting!
    visit game_controller_path(game.code)
    expect(page).to have_content("You're in")
    expect_menu_offsets("waiting", right: 8, bottom: 46)

    game_over!
    visit game_controller_path(game.code)
    expect(page).to have_css("[data-rank]")
    expect_menu_offsets("game over", right: 8, bottom: 46)
  end
end
