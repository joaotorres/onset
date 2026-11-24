# Generic theme helpers for system specs (SPEC §10 Themes and Palette, §8
# Settings menu): the browser, computed styles and colors, the theme and
# card_colors cookies, the theme-color metas and a no-reload marker.
module ThemeHelpers
  # "#RRGGBB" to the computed "rgb(r, g, b)". Also ThemeHelpers.rgb, for
  # constants built at load time.
  def rgb(hex) = "rgb(#{hex.delete("#").scan(/../).map(&:hex).join(", ")})"
  module_function :rgb
  public :rgb
end

RSpec.shared_context "theme" do
  include ThemeHelpers

  before { driven_by :selenium, using: :headless_chrome }
  # Leave the next spec on the suite's default, light (chrome_driver.rb).
  after { emulate_color_scheme("light") }

  # "light", "dark" or "" (no preference stated).
  def emulate_color_scheme(value)
    page.driver.browser.execute_cdp("Emulation.setEmulatedMedia", media: "", features: [{name: "prefers-color-scheme", value: value}])
  end

  # The computed value of a Tailwind color, through a probe on the page.
  def color(name)
    page.evaluate_script(<<~JS)
      (() => {
        const probe = document.createElement("div")
        probe.style.color = "var(--color-#{name})"
        document.body.append(probe)
        const value = getComputedStyle(probe).color
        probe.remove()
        return value
      })()
    JS
  end

  def style(selector, property)
    page.evaluate_script("getComputedStyle(document.querySelector(#{selector.to_json})).getPropertyValue(#{property.to_json})")
  end

  def style_of(element, property)
    page.evaluate_script("getComputedStyle(arguments[0]).getPropertyValue(#{property.to_json})", element)
  end

  # The computed value of a Tailwind color at an opacity, as Tailwind mixes it.
  def mix(name, percent)
    page.evaluate_script(<<~JS)
      (() => {
        const probe = document.createElement("div")
        probe.style.backgroundColor = "color-mix(in oklab, var(--color-#{name}) #{percent}%, transparent)"
        document.body.append(probe)
        const value = getComputedStyle(probe).backgroundColor
        probe.remove()
        return value
      })()
    JS
  end

  def page_background = style("body > main", "background-color")

  # Cookies; the page must already be on the app's host.
  def cookie!(name, value) = page.driver.browser.manage.add_cookie(name: name, value: value, path: "/")

  def cookie(name) = page.driver.browser.manage.all_cookies.find { |c| c[:name] == name }

  def delete_cookie(name) = page.driver.browser.manage.delete_cookie(name)

  def theme_cookie!(value) = cookie!("theme", value)

  def light! = theme_cookie!("light")

  def colorblind! = cookie!("card_colors", "colorblind")

  def theme_cookie = cookie("theme")

  def card_colors_cookie = cookie("card_colors")

  # Each theme-color meta as [content, media], media nil with no attribute.
  def theme_color_metas
    page.evaluate_script(<<~JS)
      [...document.querySelectorAll('meta[name="theme-color"]')].map(m => [m.content, m.getAttribute("media")])
    JS
  end

  # The content of the theme-color meta in effect: no media, or one that matches.
  def theme_color_in_effect
    page.evaluate_script(<<~JS)
      [...document.querySelectorAll('meta[name="theme-color"]')].find(m => !m.media || matchMedia(m.media).matches).content
    JS
  end

  # Marks the window, so a later check proves the page was not reloaded.
  def mark_window = page.execute_script("window.__sameWindow = true")

  def expect_same_window = expect(page.evaluate_script("window.__sameWindow")).to be(true)
end
