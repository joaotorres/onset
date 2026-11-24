require "rails_helper"

# SPEC §8 Big screen, Fit: the waiting hero's sizes at the design and built windows.
RSpec.describe "Big screen waiting fit sizes", type: :system do
  include_context "waiting fit"

  it "takes the design board sizes at 1280x800" do
    resize(1280, 800)
    visit_big_screen
    # The code is capped by its column (17cqi keeps six wide letters off the rail), so 80px is the ceiling.
    expect(font_px("[data-room-code]").to_f).to be_between(64, 80)
    expect(height_of("#start_button button")).to eq(80)
  end

  it "keeps the built sizes at 1920x1080" do
    resize(1920, 1080)
    visit_big_screen
    expect(rect("[data-qr-tile] svg")["width"]).to eq(288)
    expect(font_px("[data-room-code]")).to eq("160px")
    expect(height_of("#start_button button")).to eq(96)
    expect(font_px("[data-join-here]")).to eq("24px")
    expect_waiting_fits
  end

  it "fits at 1280x720 in the light theme" do
    resize(1280, 720)
    visit_big_screen
    light!
    visit_big_screen
    expect_waiting_fits
  end
end
