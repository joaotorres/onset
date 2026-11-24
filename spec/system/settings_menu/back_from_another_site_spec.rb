require "rails_helper"

# SPEC §10 Themes and Palette: Back or Forward to a page shown before takes the
# theme and card colors from the cookies as they are then, even when the
# browser restores it from its own back-forward cache after another site.
# §8 Settings menu, Closing it: that page shows the menu closed.
RSpec.describe "Back into Onset from another site", type: :system do
  include_context "card colors"

  def meta_theme_color
    page.evaluate_script(<<~JS)
      [...document.querySelectorAll('meta[name="theme-color"]')].find(m => !m.media || matchMedia(m.media).matches).content
    JS
  end

  def html_data(name) = page.evaluate_script("document.documentElement.dataset.#{name} ?? null")

  def set_cookie(name, value) = page.driver.browser.manage.add_cookie(name: name, value: value, path: "/")

  def delete_cookie(name) = page.driver.browser.manage.delete_cookie(name)

  # Leaves for another site and comes back, proving the page was restored
  # from the back-forward cache by a window marker that survives.
  def away_and_back
    page.execute_script("window.__restored = true")
    visit "data:text/html,<p>away</p>"
    expect(page).to have_text("away")
    page.go_back
    expect(page).to have_link("New to Set? How to play →")
    expect(page.evaluate_script("window.__restored")).to be(true)
  end

  def close_settings = find('button[aria-label="Close settings"]').click

  it "shows a theme set meanwhile, and Match device once it is deleted" do
    emulate_color_scheme("dark")
    visit root_path
    theme_cookie!("light")
    away_and_back
    expect(html_data("theme")).to eq("light")
    expect(page_background).to eq(color("gray-50"))
    expect(meta_theme_color).to eq("#F9FAFB")
    open_settings
    expect(page).to have_checked_field("Light", visible: :all)
    close_settings

    delete_cookie("theme")
    away_and_back
    expect(html_data("theme")).to be_nil
    expect(page_background).to eq(color("gray-950"))
    expect(meta_theme_color).to eq("#030712")
    open_settings
    expect(page).to have_checked_field("Match device", visible: :all)
  end

  it "shows card colors set meanwhile, and Classic once deleted" do
    visit root_path
    colorblind!
    away_and_back
    expect(html_data("cardColors")).to eq("colorblind")
    open_settings
    expect(page).to have_checked_field("Color-blind", visible: :all)
    close_settings

    delete_cookie("card_colors")
    away_and_back
    expect(html_data("cardColors")).to be_nil
    open_settings
    expect(page).to have_checked_field("Classic", visible: :all)
  end

  it "sets nothing for a cookie value the server would not accept" do
    visit root_path
    page.execute_script("document.documentElement.dataset.theme = 'light'; document.documentElement.dataset.cardColors = 'colorblind'")
    theme_cookie!("blue")
    set_cookie("card_colors", "x")
    away_and_back
    expect(html_data("theme")).to be_nil
    expect(html_data("cardColors")).to be_nil
  end

  it "shows the settings menu closed" do
    visit root_path
    open_settings
    away_and_back
    expect(find("#settings_menu", visible: :all)[:hidden]).to be_truthy
    expect(find('[data-settings-target="shield"]', visible: :all)[:hidden]).to be_truthy
    expect(find('button[aria-label="Settings"]')["aria-expanded"]).to eq("false")
  end

  it "takes the cookies on connect when <html> disagrees with them" do
    emulate_color_scheme("dark")
    visit root_path
    theme_cookie!("light")
    colorblind!
    page.execute_script(<<~JS)
      const el = document.querySelector('[data-controller="settings"]')
      const parent = el.parentNode, next = el.nextSibling
      el.remove()
      delete document.documentElement.dataset.theme
      delete document.documentElement.dataset.cardColors
      parent.insertBefore(el, next)
    JS
    expect(page).to have_css("html[data-theme='light'][data-card-colors='colorblind']", visible: :all)
    expect(meta_theme_color).to eq("#F9FAFB")
    open_settings
    expect(page).to have_checked_field("Light", visible: :all)
    expect(page).to have_checked_field("Color-blind", visible: :all)
  end
end
