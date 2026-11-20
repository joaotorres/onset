require "rails_helper"

# SPEC §8 Big screen, Scoreboard: with 8 players every row shows in full and the
# rail ends at least 8px above the settings button, under 1000px tall too.
RSpec.describe "Big screen rail fit", type: :system do
  include_context "big screen theme"

  def rows
    page.evaluate_script(<<~JS)
      [...document.querySelectorAll("#scoreboard li")].map(e => {
        const r = e.getBoundingClientRect()
        return {top: r.top, bottom: r.bottom, height: r.height}
      })
    JS
  end

  def score_font_size = style("#scoreboard li:first-child .font-display", "font-size")

  def expect_rail_clear
    expect(page).to have_css("#scoreboard li", count: 8)
    window_height = page.evaluate_script("window.innerHeight")
    button_top = rect('button[aria-label="Settings"]')["top"]
    list = rows
    expect(list.first["top"]).to be >= 0
    expect(list.last["bottom"]).to be <= window_height
    expect(list.last["bottom"]).to be <= button_top - 8
    expect_settings_in_corner
  end

  def start_with_claim_and_lock
    game.start!
    game.update!(board: (0..17).to_a, deck: (18..80).to_a)
    game.players.second.update!(locked_until: 1.hour.from_now)
    game.try_claim!(game.players.first)
    expect(page).to have_content("is calling SET!")
    expect(page).to have_css("#scoreboard li", text: "Locked")
  end

  def gaps = rows.each_cons(2).map { |a, b| b["top"] - a["bottom"] }

  describe "1280x800" do
    before do
      resize(1280, 800)
      add_players(8)
      visit_big_screen
    end

    it "clears the button in waiting" do
      expect_rail_clear
    end

    it "clears the button in play" do
      start_with_claim_and_lock
      expect_rail_clear
    end

    it "clears the button once ended" do
      game.update!(status: :ended)
      expect(page).to have_button("Play again")
      expect_rail_clear
    end

    it "takes the compact row sizes" do
      expect(rows.map { |r| r["height"] }.uniq).to eq([52])
      expect(gaps.uniq).to eq([6])
      expect(score_font_size).to eq("36px")
    end
  end

  it "clears the button in play at 1440x900" do
    resize(1440, 900)
    add_players(8)
    visit_big_screen
    start_with_claim_and_lock
    expect_rail_clear
  end

  it "clears the button in play at 1280x800 in the light theme" do
    resize(1280, 800)
    add_players(8)
    visit_big_screen
    light!
    visit_big_screen
    start_with_claim_and_lock
    expect_rail_clear
    expect(rows.map { |r| r["height"] }.uniq).to eq([52])
  end

  describe "1920x1080" do
    before do
      resize(1920, 1080)
      add_players(8)
      visit_big_screen
    end

    it "keeps the built sizes and clears the button in play" do
      start_with_claim_and_lock
      expect_rail_clear
      expect(rows.map { |r| r["height"] }.uniq).to eq([72])
      expect(gaps.uniq).to eq([8])
    end

    it "clears the button in waiting" do
      expect_rail_clear
    end
  end
end
