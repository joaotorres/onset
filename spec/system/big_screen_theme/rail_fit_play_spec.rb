require "rails_helper"

# SPEC §8 Big screen, Scoreboard: the rail clears the settings button in play at other windows and in light.
RSpec.describe "Big screen rail fit in play", type: :system do
  include_context "rail fit"

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
end
