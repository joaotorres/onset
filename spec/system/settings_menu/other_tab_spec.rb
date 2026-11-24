require "rails_helper"

# SPEC §10 Themes and Palette: every page load, a Turbo link visit and Back
# included, takes the theme and card colors from the cookies as they are then,
# so a pick made in another tab shows on this tab's next page.
RSpec.describe "A pick from another tab on a Turbo visit", type: :system do
  include_context "card colors"

  def html_data(name) = page.evaluate_script("document.documentElement.dataset.#{name} ?? null")

  def to_how_to_play
    mark_window
    click_link "New to Set? How to play →"
    expect(page).to have_current_path(how_to_play_path)
    expect_same_window
  end

  def to_landing
    mark_window
    click_link "Onset", match: :first
    expect(page).to have_current_path(root_path)
    expect_same_window
  end

  it "takes a theme set elsewhere on a link visit, and Match device once it is deleted" do
    emulate_color_scheme("dark")
    visit root_path
    theme_cookie!("light")
    to_how_to_play
    expect(html_data("theme")).to eq("light")
    expect(page_background).to eq(color("gray-50"))
    expect(style("html", "color-scheme")).to eq("light")
    expect(theme_color_in_effect).to eq("#F9FAFB")
    open_settings
    expect(page).to have_checked_field("Light", visible: :all)
    find('button[aria-label="Close settings"]').click

    delete_cookie("theme")
    to_landing
    expect(html_data("theme")).to be_nil
    expect(page_background).to eq(color("gray-950"))
    expect(theme_color_in_effect).to eq("#030712")
    open_settings
    expect(page).to have_checked_field("Match device", visible: :all)
  end

  it "takes card colors set elsewhere on a link visit, and Classic once deleted" do
    visit root_path
    colorblind!
    to_how_to_play
    expect(html_data("cardColors")).to eq("colorblind")
    expect_cards("main", colorblind, marks: true)
    open_settings
    expect(page).to have_checked_field("Color-blind", visible: :all)
    find('button[aria-label="Close settings"]').click

    delete_cookie("card_colors")
    to_landing
    expect(html_data("cardColors")).to be_nil
    expect_cards("main figure", classic, marks: false)
  end

  it "takes the cookies as they are now on Back to a cached page" do
    emulate_color_scheme("dark")
    visit root_path
    to_how_to_play
    theme_cookie!("light")
    colorblind!
    mark_window
    page.go_back
    expect(page).to have_link("New to Set? How to play →")
    expect_same_window
    expect(html_data("theme")).to eq("light")
    expect(page_background).to eq(color("gray-50"))
    expect(theme_color_in_effect).to eq("#F9FAFB")
    expect(html_data("cardColors")).to eq("colorblind")
  end

  it "sets nothing for a cookie value the server would not accept" do
    emulate_color_scheme("dark")
    visit root_path
    theme_cookie!("blue")
    cookie!("card_colors", "x")
    to_how_to_play
    expect(html_data("theme")).to be_nil
    expect(html_data("cardColors")).to be_nil
    expect(page_background).to eq(color("gray-950"))
  end
end
