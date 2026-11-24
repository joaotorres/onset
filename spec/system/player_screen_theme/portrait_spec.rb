require "rails_helper"

# SPEC §8 Settings menu and Player screen: the settings button in the
# "Room CODE" footer row while waiting and at game over, and the menu
# opening above it, at 375x667. During play: portrait_play_spec.rb.
RSpec.describe "Settings button on the player screen, portrait", type: :system do
  include_context "player screen theme"
  include_context "player screen with 8 players and 18 cards", 375, 667

  it "sits in the footer while waiting and at game over" do
    waiting!
    visit game_controller_path(game.code)
    expect(page).to have_content("You're in")
    expect_settings_in_footer(right: 8)

    game_over!
    visit game_controller_path(game.code)
    expect(page).to have_css("[data-rank]")
    expect_settings_in_footer(right: 8)
  end

  it "opens the menu above the button and turns the screen light with no reload" do
    emulate_color_scheme("dark")
    visit game_controller_path(game.code)
    expect(page_background).to eq(color("gray-950"))
    mark_window
    open_settings
    menu = rect("#settings_menu")
    button = rect('button[aria-label="Settings"]')
    expect(button["top"] - menu["bottom"]).to be_within(1).of(8)
    expect(menu["right"]).to be_within(1).of(button["right"])
    expect(menu["top"]).to be >= 0

    find("label", text: "Light").click
    expect(page_background).to eq(color("gray-50"))
    expect_same_window
    expect(overflow).to eq([0, 0, 0])
  end
end
