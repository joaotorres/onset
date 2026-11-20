require "rails_helper"

# SPEC §8 Big screen, Fit: the ended podium, headline and Play again stay inside the play area.
RSpec.describe "Big screen ended fit", type: :system do
  include_context "play area fit"

  before do
    players = add_players(8)
    players[0].update!(name: "Alexandria Pemberton", score: 9)
    players[1].update!(name: "Samuel Wainwright", score: 7)
    players[2].update!(name: "Priya Ramanathan", score: 5)
    game.update!(status: :ended)
  end

  def expect_ended_fits
    expect(page).to have_button("Play again")
    expect_inside_board("#board > p", "#board h2", "#board .w-56", "#board form")
    headline = page.evaluate_script("(() => { const h = document.querySelector('#board h2'); return [h.scrollWidth, h.clientWidth, getComputedStyle(h).textOverflow, h.textContent]; })()")
    expect(headline[0]).to be <= headline[1]
    expect(headline[2]).not_to eq("ellipsis")
    expect(headline[3]).to include("Alexandria Pemberton")
    expect_settings_in_corner
  end

  FIT_SIZES.each do |w, h|
    it "fits at #{w}x#{h}" do
      resize(w, h)
      visit_big_screen
      expect_ended_fits
    end
  end

  it "keeps the built sizes at 1920x1080" do
    resize(1920, 1080)
    visit_big_screen
    expect(font_px("#board h2")).to eq("96px")
    expect(height_of("#board .w-56:nth-child(2) .rounded-t-2xl")).to eq(224)
    expect_ended_fits
  end
end
