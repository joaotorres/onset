require "rails_helper"

# SPEC §8 Big screen, Scoreboard: the rail clears the settings button at 1280x800.
RSpec.describe "Big screen rail fit at 1280x800", type: :system do
  include_context "rail fit"

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
