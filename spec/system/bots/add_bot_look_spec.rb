require "rails_helper"

# DESIGN v8, Components > Add-bot control (big screen tile) and Bot mark:
# spot checks in both themes, and the disabled state of a full room.
RSpec.describe "The add-bot tile and the bot mark on the big screen", type: :system do
  include_context "big screen theme"

  let(:presets) { Player::PRESET_COLORS }

  def tile = "#room_tile [role=group]"
  def easy = find("#{tile} button[aria-label='Add Easy bot']")
  def mark = find("#board li svg[aria-label=bot]", match: :first)

  def fill_room(people)
    people.times { |i| game.players.create!(name: "Player #{i + 1}", color: presets[i]) }
    (game.players.count...8).each { game.add_bot!("easy") }
  end

  it "takes the dark values, 136px tall with 56px buttons" do
    game.add_bot!("easy")
    visit_big_screen
    theme_cookie!("dark")
    visit_big_screen

    expect(style(tile, "background-color")).to eq(color("gray-900"))
    expect(rect(tile)["height"]).to eq(136)
    expect(style_of(easy, "height")).to eq("56px")
    expect(style_of(easy, "background-color")).to eq(color("gray-800"))
    expect(style_of(easy, "border-top-color")).to eq(color("gray-700"))
    expect(style_of(easy, "color")).to eq(color("gray-50"))
    expect(style_of(mark, "color")).to eq(color("gray-400"))
    expect(style_of(mark, "width")).to eq("26px")
  end

  it "takes the light values" do
    game.add_bot!("easy")
    visit_big_screen
    light!
    visit_big_screen

    expect(style(tile, "background-color")).to eq(color("white"))
    expect(shadow(tile)).to include("#{color("gray-200")} 0px 0px 0px 1px inset")
    expect(style_of(easy, "background-color")).to eq(color("gray-100"))
    expect(style_of(easy, "border-top-color")).to eq(color("gray-300"))
    expect(style_of(easy, "color")).to eq(color("gray-900"))
    expect(style_of(mark, "color")).to eq(color("gray-600"))
  end

  it "shows the focus outline on a focused button" do
    visit_big_screen
    find("body").send_keys(:tab) until page.evaluate_script("document.activeElement.getAttribute('aria-label')") == "Add Easy bot"
    expect(style_of(easy, "outline-color")).to eq(color("blue-500"))
    expect(style_of(easy, "outline-width")).to eq("2px")
    expect(style_of(easy, "outline-offset")).to eq("2px")
  end

  it "disables the buttons with Room full once a join takes the last color, without a reload" do
    fill_room(4)
    game.players.last.destroy!
    resize(1280, 800)
    visit_big_screen
    light!
    visit_big_screen
    expect(easy).not_to be_disabled
    height = rect(tile)["height"]
    width = rect("#{tile} button")["width"]

    game.players.create!(name: "Late", color: presets.last)

    expect(page).to have_css("#{tile} button[disabled]", count: 3)
    reason = find("#{tile} p", text: "Room full")
    expect(all("#{tile} button").map { |b| b["aria-describedby"] }).to all(eq(reason["id"]))
    expect(style_of(easy, "background-color")).to eq(color("gray-200"))
    expect(style_of(easy, "border-top-color")).to eq(color("gray-200"))
    expect(style_of(easy, "color")).to eq(color("gray-600"))
    expect(style_of(mark, "width")).to eq("22px")
    # No size moves between states.
    expect(rect(tile)["height"]).to eq(height)
    expect(rect("#{tile} button")["width"]).to eq(width)
    expect_settings_in_corner
  end

  it "takes the dark disabled gray in a full room" do
    fill_room(5)
    visit_big_screen
    theme_cookie!("dark")
    visit_big_screen
    expect(easy).to be_disabled
    expect(style_of(easy, "background-color")).to eq(color("gray-800"))
    expect(style_of(easy, "border-top-color")).to eq(color("gray-800"))
    expect(style_of(easy, "color")).to eq(color("gray-500"))
  end
end
