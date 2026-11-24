require "rails_helper"

# SPEC §8 Settings menu: picking applies at once with no reload, leaves the
# menu open, writes or deletes the cookie and sends theme_changed.
RSpec.describe "Picking a theme", type: :system do
  include_context "settings menu"

  it "writes the cookie, applies at once and keeps the menu open" do
    emulate_color_scheme("dark")
    visit root_path
    mark_window
    record_tracks
    open_settings
    expect(page).to have_checked_field("Match device", visible: :all)

    choose "Light", allow_label_click: true
    expect(page_background).to eq(color("gray-50"))
    expect(page).to have_css('[role="dialog"]', visible: true)
    expect_same_window
    cookie = theme_cookie
    expect(cookie[:value]).to eq("light")
    expect(cookie[:path]).to eq("/")
    expect(cookie[:same_site]).to eq("Lax")
    expect(cookie[:expires].to_time).to be_within(1.day).of(1.year.from_now)

    choose "Dark", allow_label_click: true
    expect(page_background).to eq(color("gray-950"))
    expect(theme_cookie[:value]).to eq("dark")

    emulate_color_scheme("light")
    choose "Match device", allow_label_click: true
    expect(page_background).to eq(color("gray-50"))
    expect(theme_cookie).to be_nil

    expect(tracks).to eq([["theme_changed", {"theme" => "light"}], ["theme_changed", {"theme" => "dark"}], ["theme_changed", {"theme" => "device"}]])
  end

  it "keeps the choice over a reload" do
    emulate_color_scheme("dark")
    visit root_path
    open_settings
    choose "Light", allow_label_click: true
    expect(theme_cookie[:value]).to eq("light")
    visit root_path
    expect(page_background).to eq(color("gray-50"))
    open_settings
    expect(page).to have_checked_field("Light", visible: :all)
  end

  it "picks with the arrow keys, one event per step, and nothing for the current option" do
    emulate_color_scheme("dark")
    visit root_path
    record_tracks
    open_settings
    find_field("Match device", visible: :all).send_keys(:right)
    expect(page_background).to eq(color("gray-50"))
    find_field("Light", visible: :all).send_keys(:right)
    expect(page_background).to eq(color("gray-950"))
    expect(theme_cookie[:value]).to eq("dark")
    expect(tracks).to eq([["theme_changed", {"theme" => "light"}], ["theme_changed", {"theme" => "dark"}]])

    find("label", text: "Dark").click
    expect(tracks.size).to eq(2)
  end
end
