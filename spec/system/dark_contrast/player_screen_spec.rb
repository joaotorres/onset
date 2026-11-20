require "rails_helper"

# DESIGN v7 Shared: Themes (v6) Muted: the player screen's footer, settings
# icon and tray slot numbers.
RSpec.describe "Dark muted text on the player screen", type: :system do
  include_context "player screen theme"
  include_context "dark contrast"
  include_context "player screen with 8 players and 18 cards", 375, 667

  let(:slot) { "[data-tray] [data-card-selection-target=slot]" }

  it "draws the footer, the settings icon and the empty slot numbers muted, with the slot border as built" do
    dark_device!
    game.try_claim!(me)
    visit game_controller_path(game.code)
    expect(page).to have_css(slot, count: 3)
    expect(style("main > p", "color")).to eq(muted)
    expect(style('button[aria-label="Settings"]', "color")).to eq(muted)
    expect(style(slot, "color")).to eq(muted)
    expect(style(slot, "border-top-color")).to eq(color("gray-700"))
    expect(style(slot, "border-top-style")).to eq("dashed")

    card = find("[data-board] [data-card-id='#{game.board.first}']")
    card.click
    expect(page).to have_css("#{slot}.card-edge", count: 1)
    card.click
    expect(page).to have_no_css("#{slot}.card-edge")
    expect(style(slot, "color")).to eq(muted)
    expect(style(slot, "border-top-color")).to eq(color("gray-700"))
  end

  it "draws an empty tray slot's number gray-500 in light" do
    game.try_claim!(me)
    visit game_controller_path(game.code)
    light!
    visit game_controller_path(game.code)
    expect(page).to have_css(slot, count: 3)
    expect(style(slot, "color")).to eq(color("gray-500"))
  end
end
