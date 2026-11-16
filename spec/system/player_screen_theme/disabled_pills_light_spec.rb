require "rails_helper"

# DESIGN v6 Shared: Rules added in v6: both disabled No Set pills, while
# someone else claims and blocked after a refusal, follow the v5 rule in
# both themes: the fill tinted, the label at full strength, never faded.
RSpec.describe "Disabled No Set pills on the player screen, light", type: :system do
  include_context "disabled pills"

  it "draws them purple-100 with purple-700 text in light" do
    light!
    ["someone else claiming", "No Set blocked"].each do |name|
      play_state!(name)
      visit game_controller_path(game.code)
      expect(page).to have_css(pill, text: "No Set")
      expect(style(pill, "background-color")).to eq(color("purple-100"))
      expect(style(pill, "color")).to eq(color("purple-700"))
      expect(style(pill, "opacity")).to eq("1")
      expect(style(panel, "background-color")).to eq(color("white"))
    end
  end
end
