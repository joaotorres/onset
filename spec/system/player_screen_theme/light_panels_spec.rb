require "rails_helper"

# DESIGN v6 Shared: Themes (v6): the light tinted status panels and the
# found-set banner. The disabled No Set pills: disabled_pills_spec.rb.
RSpec.describe "Light player screen panels", type: :system do
  include_context "player screen theme"
  include_context "player screen with 8 players and 18 cards", 375, 667

  let(:panel) { "[data-status-slot] [role=status]" }

  it "draws the No Set, locked-out and found-set panels light" do
    light!
    play_state!("No Set countdown")
    visit game_controller_path(game.code)
    expect(page).to have_css(panel, text: "No Set called by")
    expect(style(panel, "background-color")).to eq(color("purple-50"))
    expect(style(panel, "border-top-color")).to eq(color("purple-600"))

    play_state!("locked out, wrong")
    visit game_controller_path(game.code)
    expect(page).to have_css(panel, text: "Wrong!")
    expect(style(panel, "background-color")).to eq(color("red-50"))

    play_state!("found-set banner")
    visit game_controller_path(game.code)
    expect(page).to have_css("[data-found-banner]")
    expect(style("[data-found-banner]", "background-color")).to eq(color("green-50"))

    waiting!
    visit game_controller_path(game.code)
    expect(style("section[aria-label=Invite]", "background-color")).to eq(color("white"))
  end
end
