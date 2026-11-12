# Headless Chrome with a window the spec can resize, put back to the default after.
RSpec.shared_context "resizable window" do
  before { driven_by :selenium, using: :headless_chrome }
  # Later specs expect the default window size.
  after { page.driver.browser.manage.window.resize_to(1400, 1400) }

  def resize(width, height)
    page.driver.browser.manage.window.resize_to(width, height)
    # Headless Chrome sizes the window, not the viewport: pad until the viewport matches.
    inner = page.evaluate_script("[window.innerWidth, window.innerHeight]")
    page.driver.browser.manage.window.resize_to(2 * width - inner[0], 2 * height - inner[1])
  end

  def rect(selector)
    page.evaluate_script("(() => { const r = document.querySelector(#{selector.to_json}).getBoundingClientRect(); return {left: r.left, right: r.right, top: r.top, bottom: r.bottom, width: r.width, height: r.height}; })()")
  end

  def page_scroll
    page.evaluate_script("[document.documentElement.scrollHeight, window.innerHeight, document.documentElement.scrollWidth, window.innerWidth]")
  end
end
