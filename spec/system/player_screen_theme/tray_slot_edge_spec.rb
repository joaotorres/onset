require "rails_helper"

# DESIGN v6 Shared: Themes (v6): in the light theme a filled tray slot takes
# the card edge, and an emptied one its dashed border back.
RSpec.describe "Light tray slot card edge", type: :system do
  include_context "player screen theme"
  include_context "player screen with 8 players and 18 cards", 375, 667

  let(:slot) { "[data-tray] [data-card-selection-target=slot]" }

  it "gives a filled slot card-edge and the light edge, and takes them away on unpick" do
    light!
    game.try_claim!(me)
    visit game_controller_path(game.code)
    expect(page).to have_css(bar = "[data-status-slot] [role=status]", text: "Your SET!")
    expect(page).to have_css(slot, count: 3)
    card = find("[data-board] [data-card-id='#{game.board.first}']")

    card.click
    expect(page).to have_css("#{slot}.card-edge", count: 1)
    expect(style(slot, "box-shadow")).to include("rgb(209, 213, 219) 0px 0px 0px 1px")
    expect(style(slot, "border-top-width")).to eq("0px")
    expect(style(slot, "border-top-style")).not_to eq("dashed")

    card.click
    expect(page).to have_no_css("#{slot}.card-edge")
    expect(style(slot, "border-top-style")).to eq("dashed")
    expect(style(slot, "border-top-width")).to eq("2px")
    expect(style(slot, "border-top-color")).to eq(color("gray-400"))
    expect(style(slot, "box-shadow")).to eq("none")
    expect(page).to have_css(bar, text: "Your SET!")
  end
end
