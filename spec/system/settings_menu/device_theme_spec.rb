require "rails_helper"

# SPEC §10 Themes: with no cookie the page follows the device, live, and a
# device with no preference gets dark. A cookie wins over the device.
RSpec.describe "Theme from the device and the cookie", type: :system do
  include_context "settings menu"

  let(:game) { Game.create! }

  def color_scheme = style("html", "color-scheme")

  it "follows the device with no cookie, live, and gets dark with no preference" do
    emulate_color_scheme("light")
    visit root_path
    expect(page_background).to eq(color("gray-50"))
    expect(color_scheme).to eq("light")
    expect(theme_color_in_effect).to eq("#F9FAFB")

    emulate_color_scheme("dark")
    expect(page_background).to eq(color("gray-950"))
    expect(color_scheme).to eq("dark")
    expect(theme_color_in_effect).to eq("#030712")

    emulate_color_scheme("")
    visit root_path
    expect(page_background).to eq(color("gray-950"))
    expect(color_scheme).to eq("dark")
  end

  it "takes the cookie over the device on every page" do
    emulate_color_scheme("dark")
    visit root_path
    theme_cookie!("light")
    [root_path, how_to_play_path, join_game_players_path(game.code)].each do |path|
      visit path
      expect(page_background).to eq(color("gray-50"))
      expect(color_scheme).to eq("light")
      expect(theme_color_in_effect).to eq("#F9FAFB")
    end

    emulate_color_scheme("light")
    theme_cookie!("dark")
    [root_path, how_to_play_path, join_game_players_path(game.code)].each do |path|
      visit path
      expect(page_background).to eq(color("gray-950"))
      expect(color_scheme).to eq("dark")
      expect(theme_color_in_effect).to eq("#030712")
    end
  end
end
