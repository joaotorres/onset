require "rails_helper"

# SPEC §8 Big screen, Fit: the ended podium keeps its built sizes at 1920x1080.
RSpec.describe "Big screen ended fit sizes", type: :system do
  include_context "ended fit"

  it "keeps the built sizes at 1920x1080" do
    resize(1920, 1080)
    visit_big_screen
    expect(font_px("#board h2")).to eq("96px")
    expect(height_of("#board .w-56:nth-child(2) .rounded-t-2xl")).to eq(224)
    expect_ended_fits
  end
end
