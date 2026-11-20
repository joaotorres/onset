require "rails_helper"

# DESIGN v7 Shared: Themes (v6) Muted on the big screen: the empty band text,
# the No Set count's "/N", the scoreboard's "No one yet" and a locked entry.
RSpec.describe "Dark muted text on the big screen", type: :system do
  include_context "big screen theme"
  include_context "dark contrast"

  let!(:players) { add_players(2) }

  before { resize(1280, 800) }

  def band_and_scoreboard_html
    page.evaluate_script("document.querySelector('#announcement').outerHTML + document.querySelector('#scoreboard').outerHTML")
  end

  it "draws the empty band text, a locked entry and the No Set count muted in dark" do
    dark_device!
    game.start!
    players.last.update!(locked_until: 10.seconds.from_now)
    visit_big_screen
    expect(style_of(find("#announcement p", text: "Spot a Set?"), "color")).to eq(muted)
    expect(style_of(find("#scoreboard li", text: "Player 2"), "color")).to eq(muted)

    game.call_no_set!(players.first)
    expect(page).to have_content("called No Set")
    expect(style_of(find("#announcement span", text: "/2"), "color")).to eq(muted)
  end

  it "draws No one yet muted in dark" do
    players.each(&:destroy!)
    dark_device!
    visit_big_screen
    expect(style_of(find("#scoreboard li", text: "No one yet"), "color")).to eq(muted)
  end

  it "draws the disabled Start game label gray-500 on gray-800 in dark with one player" do
    players.last.destroy!
    dark_device!
    visit_big_screen
    start = find("button[disabled]", text: "Start game")
    expect(style_of(start, "color")).to eq(color("gray-500"))
    expect(style_of(start, "background-color")).to eq(color("gray-800"))
  end

  it "keeps gray-500 for the No Set count's /N and No one yet in light" do
    game.start!
    game.call_no_set!(players.first)
    visit_big_screen
    light!
    visit_big_screen
    expect(page).to have_content("called No Set")
    expect(style_of(find("#announcement span", text: "/2"), "color")).to eq(color("gray-500"))
    game.update!(no_set_caller_id: nil, no_set_started_at: nil)
    players.each(&:destroy!)
    visit_big_screen
    expect(style_of(find("#scoreboard li", text: "No one yet"), "color")).to eq(color("gray-500"))
  end

  it "keeps gray-500 in light, with the same markup for both themes" do
    game.start!
    players.last.update!(locked_until: 10.seconds.from_now)
    dark_device!
    visit_big_screen
    dark_html = band_and_scoreboard_html
    light!
    visit_big_screen
    expect(style_of(find("#announcement p", text: "Spot a Set?"), "color")).to eq(color("gray-500"))
    expect(style_of(find("#scoreboard li", text: "Player 2"), "color")).to eq(color("gray-500"))
    expect(band_and_scoreboard_html).to eq(dark_html)
  end
end
