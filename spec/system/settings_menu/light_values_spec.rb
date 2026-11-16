require "rails_helper"

# DESIGN v6 Shared: Themes (v6): spot checks of the light values on the
# landing, the join page, How to play and the byline footer.
RSpec.describe "Light theme values", type: :system do
  include_context "settings menu"
  include_context "resizable window"

  let(:game) { Game.create! }

  def light!
    visit root_path
    page.driver.browser.manage.add_cookie(name: "theme", value: "light", path: "/")
  end

  def card_edge(selector) = style(selector, "box-shadow")

  it "draws the landing in light" do
    resize(1280, 860)
    light!
    visit root_path
    expect(page_background).to eq(color("gray-50"))
    expect(style("main section", "background-color")).to eq(color("white"))
    expect(style("h1", "color")).to eq(color("gray-900"))
    expect(style("#room_code", "border-top-color")).to eq(color("gray-500"))
    expect(style(".byline", "color")).to eq(color("gray-600"))
    expect(page.evaluate_script("getComputedStyle(document.querySelector('.byline-footer')).getPropertyValue('--wm-red').trim().toUpperCase()")).to eq("#C60B1E")
    expect(card_edge("figure .card-edge")).to include("rgb(209, 213, 219) 0px 0px 0px 1px")

    fill_in "Have a room code?", with: "ZZZZ"
    click_button "Join"
    expect(page).to have_content("Room not found")
    expect(style("#room_code_error", "color")).to eq(color("red-700"))
  end

  it "keeps the landing as built in dark, with no card edge" do
    emulate_color_scheme("dark")
    resize(1280, 860)
    visit root_path
    expect(page_background).to eq(color("gray-950"))
    expect(style("h1", "color")).to eq(color("white"))
    expect(style("#room_code", "border-top-color")).to eq(color("gray-700"))
    expect(style(".byline", "color")).to eq(color("gray-400"))
    expect(card_edge("figure .card-edge")).to eq("none")
  end

  it "draws the join page swatches in light" do
    game.players.create!(name: "Ana", color: PlayersController::PRESET_COLORS.first, session_token: "t1")
    light!
    visit join_game_players_path(game.code)
    taken = find("label[title='Taken by Ana']")
    expect(style("label[title='Taken by Ana']", "background-color")).to eq(page.evaluate_script(<<~JS))
      (() => { const p = document.createElement("div"); p.style.backgroundColor = "color-mix(in srgb, #E74C3C 30%, var(--color-gray-50))"; document.body.append(p); const v = getComputedStyle(p).backgroundColor; p.remove(); return v })()
    JS
    expect(taken.find("span").native.css_value("color")).to eq(color("gray-700"))
    expect(style("fieldset .grid-cols-4 label:has(input:checked)", "box-shadow")).to include(color("gray-900"))
  end

  it "draws How to play's cards with the light edge" do
    light!
    visit how_to_play_path
    expect(page_background).to eq(color("gray-50"))
    expect(card_edge("section .card-edge")).to include("rgb(209, 213, 219) 0px 0px 0px 1px")
    expect(style("h1", "color")).to eq(color("gray-900"))
  end
end
