require "rails_helper"

# SPEC §10 Themes: a pick in the menu leaves the `theme-color` metas a page
# load with that choice renders (ThemesHelper#theme_color_tags).
RSpec.describe "theme-color after a pick in the menu", type: :system do
  include_context "settings menu"

  def metas
    page.evaluate_script(<<~JS)
      [...document.querySelectorAll('head meta[name="theme-color"]')].map(m => [m.content, m.getAttribute("media")])
    JS
  end

  def meta_in_effect
    page.evaluate_script(<<~JS)
      [...document.querySelectorAll('meta[name="theme-color"]')].find(m => !m.media || matchMedia(m.media).matches).content
    JS
  end

  # Picks in the menu, then checks the metas against a fresh load with the cookie.
  def pick(label, expected)
    open_settings
    choose label, allow_label_click: true
    expect(metas).to eq(expected)
    yield
    visit root_path
    expect(metas).to eq(expected)
  end

  it "matches a page load for Light, Dark and Match device" do
    emulate_color_scheme("dark")
    visit root_path

    pick("Light", [["#F9FAFB", nil]]) { expect(meta_in_effect).to eq("#F9FAFB") }
    pick("Dark", [["#030712", nil]]) { expect(meta_in_effect).to eq("#030712") }
    pick("Match device", [["#F9FAFB", "(prefers-color-scheme: light)"], ["#030712", nil]]) do
      expect(meta_in_effect).to eq("#030712")
      emulate_color_scheme("light")
      expect(meta_in_effect).to eq("#F9FAFB")
    end
  end
end
