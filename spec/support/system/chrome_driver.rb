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

# Chrome 158 refuses the origin "*" Capybara 3.40 clears storage with after each
# example ("invalid argument: * is not a valid URL"), which failed every system
# spec. The same reset, said in a way Chrome takes: every cookie, then the test
# server's own storage.
module ChromeResetWithoutWildcardOrigin
  private

  def execute_cdp(cmd, params = {})
    return super unless cmd == "Storage.clearDataForOrigin" && params[:origin] == "*"

    super("Network.clearBrowserCookies")
    origin = Capybara.current_session.server&.base_url
    super(cmd, params.merge(origin: origin)) if origin
  end
end

Capybara::Selenium::Driver::ChromeDriver.prepend(ChromeResetWithoutWildcardOrigin)

# rspec-rails defines driven_by on each example group itself, so the module is
# prepended: an included one would sit behind it and never run.
RSpec.configure { |config| config.prepend ChromeDriverDefaults, type: :system }

# Capybara 3.40 resets the session between examples with
# `Storage.clearDataForOrigin origin: "*"`, which Chrome 158 refuses ("* is not
# a valid URL"), failing every system example. Clear the cookies for the whole
# browser and the rest for the app server's origin instead. Drop this once a
# Capybara release stops sending "*".
module ChromeStorageResetForAnyOrigin
  def execute_cdp(cmd, params = {})
    return super unless cmd == "Storage.clearDataForOrigin" && params[:origin] == "*"

    types = params[:storageTypes].to_s.split(",")
    super("Storage.clearCookies") if types.delete("cookies")
    server = Capybara.current_session.server
    return if types.empty? || server.nil?

    super(cmd, origin: server.base_url, storageTypes: types.join(","))
  end
end
Capybara::Selenium::Driver::ChromeDriver.prepend ChromeStorageResetForAnyOrigin
