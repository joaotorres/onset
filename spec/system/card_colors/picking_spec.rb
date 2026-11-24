require "rails_helper"

# SPEC §8 Settings menu, Card colors: picking applies at once with no reload,
# leaves the menu open, writes or deletes the card_colors cookie and sends
# card_colors_changed.
RSpec.describe "Picking card colors", type: :system do
  include_context "card colors"

  it "writes the cookie, turns every card and How to play's words at once, keeps the menu open, and deletes it for Classic" do
    visit how_to_play_path
    mark_window
    record_tracks
    open_settings
    expect(page).to have_checked_field("Classic", visible: :all)

    choose "Color-blind", allow_label_click: true
    expect_cards("main", colorblind, marks: true)
    expect(page).to have_text("two blue, one orange")
    expect(page).to have_css('[role="dialog"]', visible: true)
    expect_same_window
    cookie = card_colors_cookie
    expect(cookie[:value]).to eq("colorblind")
    expect(cookie[:path]).to eq("/")
    expect(cookie[:same_site]).to eq("Lax")
    expect(cookie[:expires].to_time).to be_within(1.day).of(1.year.from_now)

    choose "Classic", allow_label_click: true
    expect_cards("main", classic, marks: false)
    expect(page).to have_text("two red, one green")
    expect(card_colors_cookie).to be_nil

    expect(tracks).to eq([["card_colors_changed", {"card_colors" => "colorblind"}], ["card_colors_changed", {"card_colors" => "classic"}]])
  end

  it "keeps the choice over a reload" do
    visit root_path
    open_settings
    choose "Color-blind", allow_label_click: true
    expect(card_colors_cookie[:value]).to eq("colorblind")
    visit root_path
    expect_cards("main figure", colorblind, marks: true)
    open_settings
    expect(page).to have_checked_field("Color-blind", visible: :all)
  end
end
