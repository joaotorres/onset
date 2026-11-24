require "rails_helper"

# SPEC §10 Themes and Palette, "Stored per browser": the server sends each
# accepted cookie back on every page, and that renewal never blocks a later
# pick from the settings menu.
RSpec.describe "Picking after the server renewed the cookies", type: :system do
  include_context "card colors"

  it "takes Dark, then Match device, over a theme the server just renewed" do
    emulate_color_scheme("light")
    visit root_path
    theme_cookie!("light")
    visit root_path
    expect(page_background).to eq(color("gray-50"))

    open_settings
    choose "Dark", allow_label_click: true
    visit root_path
    expect(page_background).to eq(color("gray-950"))
    expect(theme_cookie[:value]).to eq("dark")

    open_settings
    choose "Match device", allow_label_click: true
    visit root_path
    expect(page_background).to eq(color("gray-50"))
    expect(theme_cookie).to be_nil
  end

  it "takes Classic over Color-blind the server just renewed" do
    visit root_path
    colorblind!
    visit how_to_play_path
    expect_cards("main", colorblind, marks: true)

    open_settings
    choose "Classic", allow_label_click: true
    visit how_to_play_path
    expect_cards("main figure", classic, marks: false)
    expect(card_colors_cookie).to be_nil
  end
end
