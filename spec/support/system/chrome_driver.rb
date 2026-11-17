# System specs render the same on this Mac and in CI (jt-playbook TOOLCHAIN.md,
# "system specs render the same here and in CI"). Every
# `driven_by :selenium, using: :headless_chrome` gets overlay-free scrollbars,
# a fixed window size and a light color scheme, whatever the host's
# appearance. A spec that needs dark or no preference emulates it itself.
module ChromeDriverDefaults
  WINDOW_SIZE = [1400, 1400].freeze

  def driven_by(driver, using: :chrome, screen_size: WINDOW_SIZE, options: {}, &capabilities)
    return super unless using == :headless_chrome

    super do |chrome_options|
      # macOS scrollbars overlay and take no width; Linux Chrome's take 15 px.
      chrome_options.add_argument("--hide-scrollbars")
      capabilities&.call(chrome_options)
    end
    page.driver.browser.execute_cdp(
      "Emulation.setEmulatedMedia",
      media: "", features: [{name: "prefers-color-scheme", value: "light"}]
    )
  end
end

# rspec-rails defines driven_by on each example group itself, so the module is
# prepended: an included one would sit behind it and never run.
RSpec.configure { |config| config.prepend ChromeDriverDefaults, type: :system }
