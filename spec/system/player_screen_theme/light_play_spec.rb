require "rails_helper"

# DESIGN v6 Shared: Themes (v6): spot checks of the light player screen
# during play: the page, footer, card edge, claim bar, selected ring and
# arrive outline.
RSpec.describe "Light player screen during play", type: :system do
  include_context "player screen theme"
  include_context "player screen with 8 players and 18 cards", 375, 667

  it "draws the idle board light, then the claim bar, the selected ring and the arrive outline" do
    light!
    visit game_controller_path(game.code)
    expect(page).to have_css("[data-card-id]", count: 18)
    expect(page_background).to eq(color("gray-50"))
    expect(style("main > p", "color")).to eq(color("gray-500"))
    expect(style("[data-board] [data-card-id] .card-edge", "box-shadow")).to include("rgb(209, 213, 219) 0px 0px 0px 1px")
    expect(style('button[aria-label="Settings"]', "color")).to eq(color("gray-500"))

    claim = game.try_claim!(me)
    claim.update!(card_ids: [game.board.first])
    game.update!(last_dealt: [game.board.last])
    visit game_controller_path(game.code)
    bar = "[data-status-slot] [role=status]"
    expect(page).to have_css(bar, text: "Your SET!")
    expect(style(bar, "background-color")).to eq(color("yellow-400"))
    expect(style(bar, "color")).to eq(color("gray-950"))
    expect(style('[data-board] [aria-pressed="true"]', "box-shadow")).to include(color("blue-500"))
    # Held at the animation's start, before the outline fades.
    page.execute_script("document.querySelector('[data-board] .animate-arrive').getAnimations().forEach(a => { a.pause(); a.currentTime = 0 })")
    # The keyframes give it in oklab, as Tailwind's color-mix does.
    expect(style("[data-board] .animate-arrive", "outline-color")).to eq(mix("green-600", 100))
  end
end
