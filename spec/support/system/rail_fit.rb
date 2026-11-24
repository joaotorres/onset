# Shared by spec/system/big_screen_theme/rail_fit_*_spec.rb (SPEC §8 Big screen,
# Scoreboard): with 8 players every row shows in full and the rail ends at least
# 8px above the settings button, under 1000px tall too.
RSpec.shared_context "rail fit" do
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
end
