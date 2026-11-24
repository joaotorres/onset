require "rails_helper"

# SPEC §8 Big screen, Scoreboard: the rail keeps its built sizes at 1920x1080.
RSpec.describe "Big screen rail fit at 1920x1080", type: :system do
  include_context "rail fit"

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
