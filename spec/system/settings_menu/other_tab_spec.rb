require "rails_helper"

# SPEC §10 Themes and Palette: every page load, a Turbo link visit and Back
# included, takes the theme and card colors from the cookies as they are then,
# so a pick made in another tab shows on this tab's next page.
RSpec.describe "A pick from another tab on a Turbo visit", type: :system do
  include_context "card colors"

  def meta_theme_color
    page.evaluate_script(<<~JS)
      [...document.querySelectorAll('meta[name="theme-color"]')].find(m => !m.media || matchMedia(m.media).matches).content
    JS
  end

  def html_data(name) = page.evaluate_script("document.documentElement.dataset.#{name} ?? null")

  def mark_window = page.execute_script("window.__noReload = true")

  def expect_no_reload = expect(page.evaluate_script("window.__noReload")).to be(true)

  def set_cookie(name, value) = page.driver.browser.manage.add_cookie(name: name, value: value, path: "/")

  def delete_cookie(name) = page.driver.browser.manage.delete_cookie(name)

  def to_how_to_play
    mark_window
    click_link "New to Set? How to play →"
    expect(page).to have_current_path(how_to_play_path)
    expect_no_reload
  end

  def to_landing
    mark_window
    click_link "Onset", match: :first
    expect(page).to have_current_path(root_path)
    expect_no_reload
  end

  it "takes a theme set elsewhere on a link visit, and Match device once it is deleted" do
    emulate_color_scheme("dark")
    visit root_path
    set_cookie("theme", "light")
    to_how_to_play
    expect(html_data("theme")).to eq("light")
    expect(page_background).to eq(color("gray-50"))
    expect(style("html", "color-scheme")).to eq("light")
    expect(meta_theme_color).to eq("#F9FAFB")
    open_settings
    expect(page).to have_checked_field("Light", visible: :all)
    find('button[aria-label="Close settings"]').click

    delete_cookie("theme")
    to_landing
    expect(html_data("theme")).to be_nil
    expect(page_background).to eq(color("gray-950"))
    expect(meta_theme_color).to eq("#030712")
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
    set_cookie("theme", "light")
    colorblind!
    mark_window
    page.go_back
    expect(page).to have_link("New to Set? How to play →")
    expect_no_reload
    expect(html_data("theme")).to eq("light")
    expect(page_background).to eq(color("gray-50"))
    expect(meta_theme_color).to eq("#F9FAFB")
    expect(html_data("cardColors")).to eq("colorblind")
  end

  it "sets nothing for a cookie value the server would not accept" do
    emulate_color_scheme("dark")
    visit root_path
    set_cookie("theme", "blue")
    set_cookie("card_colors", "x")
    to_how_to_play
    expect(html_data("theme")).to be_nil
    expect(html_data("cardColors")).to be_nil
    expect(page_background).to eq(color("gray-950"))
  end
end
