require "rails_helper"

# SPEC §8 Settings menu: on the big screen the menu opens above the corner
# button, picking applies at once, broadcasts leave it open with its choice,
# and a tap outside only closes it.
RSpec.describe "Settings menu on the big screen", type: :system do
  include_context "big screen theme"

  before { resize(1280, 800) }

  it "opens above the button and turns the screen light with no reload" do
    emulate_color_scheme("dark")
    add_players(2)
    visit_big_screen
    expect(page_background).to eq(color("gray-950"))
    page.execute_script("window.sameDocument = true")
    open_settings
    menu = rect("#settings_menu")
    width, height = page.evaluate_script("[window.innerWidth, window.innerHeight]")
    expect(width - menu["right"]).to be_within(1).of(40)
    expect(height - menu["bottom"]).to be_within(1).of(108)

    find("label", text: "Light").click
    expect(page_background).to eq(color("gray-50"))
    expect(page.evaluate_script("window.sameDocument")).to be(true)
  end

  it "stays open with its choice through a join, a claim and a deal" do
    alice, = add_players(2)
    visit_big_screen
    open_settings
    find("label", text: "Dark").click

    game.players.create!(name: "Carol", color: PlayersController::PRESET_COLORS[2], last_seen_at: Time.current)
    expect(page).to have_css("#board li", text: "Carol")
    expect(menu_open?).to be(true)

    game.start!
    game.try_claim!(alice)
    expect(page).to have_content("is calling SET!")
    expect(menu_open?).to be(true)

    game.release_claim!
    game.update!(board: (12..23).to_a, last_dealt: [21, 22, 23])
    expect(page).to have_content("Spot a Set?")
    expect(menu_open?).to be(true)
    expect(find_field("Dark", visible: :all)).to be_checked
    expect(settings_button["aria-expanded"]).to eq("true")
  end

  it "closes on a tap on Start game without starting the game" do
    add_players(2)
    visit_big_screen
    open_settings
    tap_on find("button", text: "Start game")
    expect(page).to have_no_css("#settings_menu", visible: true)
    expect(settings_button["aria-expanded"]).to eq("false")
    expect(game.reload).to be_waiting
  end

  it "closes on a tap on Play again without restarting the game" do
    add_players(2)
    game.update!(status: :ended)
    visit_big_screen
    open_settings
    tap_on find("button", text: "Play again")
    expect(page).to have_no_css("#settings_menu", visible: true)
    expect(game.reload).to be_ended
  end
end
