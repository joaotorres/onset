# Theme and settings menu helpers (SPEC §8 Settings menu, §10 Themes).
RSpec.shared_context "settings menu" do
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

  def page_background = style("body > main", "background-color")

  def theme_cookie
    page.driver.browser.manage.all_cookies.find { |c| c[:name] == "theme" }
  end

  def record_tracks
    page.execute_script("window.tracks = []; window.jtTrack = (name, props) => window.tracks.push([name, props])")
  end

  def tracks = page.evaluate_script("window.tracks")

  # A real pointer tap at the element's centre, whatever lies on top of it.
  def tap_on(element)
    r = page.evaluate_script("(el => { const r = el.getBoundingClientRect(); return [r.left + r.width / 2, r.top + r.height / 2] })(arguments[0])", element)
    page.driver.browser.action.move_to_location(r[0].round, r[1].round).click.perform
  end

  def open_settings
    find('button[aria-label="Settings"]').click
    expect(page).to have_css('[role="dialog"][aria-label="Settings"]', visible: true)
  end
end
