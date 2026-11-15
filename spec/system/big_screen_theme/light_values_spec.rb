require "rails_helper"

# SPEC §10 Themes, DESIGN v6 Shared: Themes (v6): spot checks of the big
# screen's light values in each state.
RSpec.describe "Big screen light values", type: :system do
  include_context "big screen theme"

  def style_of(element, property)
    page.evaluate_script("getComputedStyle(arguments[0]).getPropertyValue(#{property.to_json})", element)
  end

  def ring(color_name, width = 2) = "#{color(color_name)} 0px 0px 0px #{width}px inset"

  let!(:players) { add_players(2) }

  before do
    resize(1280, 800)
    visit_big_screen
    light!
  end

  it "takes the light values while waiting" do
    visit_big_screen
    expect(page_background).to eq(color("gray-50"))
    expect(style("[data-qr-tile]", "background-color")).to eq(color("white"))
    expect(shadow("[data-qr-tile]")).to include(ring("gray-200", 1))
    pill = find("#board li", text: "Player 1")
    expect(style_of(pill, "background-color")).to eq(color("white"))
    expect(style_of(pill, "box-shadow")).to include(ring("gray-200", 1))
    start = find("button", text: "Start game")
    expect(style_of(start, "color")).to eq(color("white"))
  end

  it "takes the light values during play" do
    game.start!
    game.try_claim!(players.first)
    players.last.update!(locked_until: 10.seconds.from_now)
    visit_big_screen
    expect(style("#room_tile > div", "background-color")).to eq(color("white"))
    expect(shadow("#room_tile > div")).to include(ring("gray-200", 1))
    expect(style("#announcement > div", "background-color")).to eq(color("yellow-50"))
    expect(shadow("#announcement > div")).to include(ring("yellow-500"))
    locked = find("#scoreboard span", text: "Locked")
    expect(style_of(locked, "background-color")).to eq(color("red-100"))
    expect(style_of(locked, "color")).to eq(color("red-700"))

    game.release_claim!
    game.call_no_set!(players.first)
    expect(page).to have_content("called No Set")
    expect(style("#announcement > div", "background-color")).to eq(color("purple-50"))

    game.update!(deck: [], no_set_caller_id: nil, no_set_started_at: nil)
    pill = find("#board span", text: "Deck is empty")
    expect(style_of(pill, "background-color")).to eq(color("orange-50"))
  end

  it "takes the light values when the game ends" do
    players.first.update!(score: 3)
    game.update!(status: :ended)
    visit_big_screen
    expect(style_of(find("#board span", text: "★"), "color")).to eq(color("yellow-700"))
    expect(style_of(find("button", text: "Play again"), "color")).to eq(color("white"))
  end

  it "renders the dark values with the dark theme" do
    page.driver.browser.manage.add_cookie(name: "theme", value: "dark", path: "/")
    game.start!
    game.try_claim!(players.first)
    visit_big_screen
    expect(page_background).to eq(color("gray-950"))
    expect(style("#room_tile > div", "background-color")).to eq(color("gray-900"))
    expect(shadow("#room_tile > div")).to eq("none")
    expect(style("#announcement > div", "background-color")).to eq(mix("yellow-400", 10))
    expect(shadow("#announcement > div")).to include(ring("yellow-400"))
  end
end
