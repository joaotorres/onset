require "rails_helper"

# DESIGN v6 Shared: Rules added in v6, see disabled_pills_light_spec.rb.
RSpec.describe "Disabled No Set pills on the player screen, dark", type: :system do
  include_context "disabled pills"

  it "draws them at 35% fill with full-strength purple-200 text in dark" do
    emulate_color_scheme("dark")
    ["someone else claiming", "No Set blocked"].each do |name|
      play_state!(name)
      visit game_controller_path(game.code)
      expect(page).to have_css(pill, text: "No Set")
      expect(style(pill, "background-color")).to eq(mix("purple-700", 35))
      expect(style(pill, "color")).to eq(color("purple-200"))
      expect(style(pill, "opacity")).to eq("1")
    end
  end
end
