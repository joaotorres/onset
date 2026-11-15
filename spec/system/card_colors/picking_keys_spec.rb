require "rails_helper"

# SPEC §8 Settings menu, Card colors: arrow-key picking, and the two options
# kept apart from each other.
RSpec.describe "Picking card colors with the keyboard and beside the theme", type: :system do
  include_context "card colors"

  it "picks with the arrow keys, one event per step, and nothing for the current option" do
    visit root_path
    record_tracks
    open_settings
    find_field("Classic", visible: :all).send_keys(:right)
    expect_cards("main figure", colorblind, marks: true)
    find_field("Color-blind", visible: :all).send_keys(:right)
    expect_cards("main figure", classic, marks: false)
    expect(card_colors_cookie).to be_nil
    expect(tracks).to eq([["card_colors_changed", {"card_colors" => "colorblind"}], ["card_colors_changed", {"card_colors" => "classic"}]])

    find("label", text: "Classic").click
    expect(tracks.size).to eq(2)
  end

  it "leaves the theme alone when picking card colors, and card colors when picking a theme" do
    visit root_path
    record_tracks
    open_settings
    choose "Color-blind", allow_label_click: true
    expect(theme_cookie).to be_nil
    choose "Light", allow_label_click: true
    expect(card_colors_cookie[:value]).to eq("colorblind")
    expect_cards("main figure", colorblind, marks: true)
    expect(tracks).to eq([["card_colors_changed", {"card_colors" => "colorblind"}], ["theme_changed", {"theme" => "light"}]])
  end
end
