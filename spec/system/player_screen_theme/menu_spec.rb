require "rails_helper"

# SPEC §8 Settings menu: a tap outside only closes the menu, and the game
# carries on under it, a room update leaving it open with its choice.
RSpec.describe "Settings menu on the player screen", type: :system do
  include_context "player screen theme"
  # On a computer, where the open menu leaves SET! and the first card uncovered.
  include_context "player screen with 3 players and 12 cards", 1024, 640

  def menu_open? = page.has_css?("#settings_menu", visible: true, wait: 0)

  before do
    visit game_controller_path(game.code)
    expect(page).to have_css("turbo-cable-stream-source[connected]", count: 2, visible: :all)
  end

  it "closes on a tap on SET! or a board card without making a claim" do
    open_settings
    tap_on find("[data-set-slot] button")
    expect(page).to have_no_css("#settings_menu", visible: true)
    expect(settings_button["aria-expanded"]).to eq("false")

    open_settings
    tap_on all("[data-board] [data-card-id]").first
    expect(page).to have_no_css("#settings_menu", visible: true)
    expect(Claim.count).to eq(0)
    expect(page).to have_button("SET!")
  end

  it "stays open with its choice through room updates" do
    open_settings
    find("label", text: "Dark").click
    expect(page.evaluate_script("document.documentElement.dataset.theme")).to eq("dark")

    game.try_claim!(other)
    expect(page).to have_content("is calling SET!")
    expect(menu_open?).to be(true)

    game.release_claim!
    expect(page).to have_no_content("is calling SET!")
    game.update!(board: (12..23).to_a, last_dealt: [21, 22, 23])
    expect(page).to have_css('[data-card-id="23"]')
    expect(menu_open?).to be(true)
    expect(find_field("Dark", visible: :all)).to be_checked
    expect(settings_button["aria-expanded"]).to eq("true")
  end
end
