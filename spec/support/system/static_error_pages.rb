# The five static error pages in public/ (SPEC §10 Themes, DESIGN v7 Screens >
# Static error pages): the pages, their titles' brackets and the computed
# colors of each part in each theme.
module StaticErrorPages
  # Each page: the code and name in the title's brackets, and the Rails
  # scaffold's title and message (the paragraph's inner HTML), which stay as is.
  PAGES = {
    "/400.html" => {
      label: "400 Bad Request",
      title: "The server cannot process the request due to a client error (400 Bad Request)",
      message: "<strong>The server cannot process the request due to a client error.</strong> Please check the request and try again. If you're the application owner check the logs for more information."
    },
    "/404.html" => {
      label: "404 Not found",
      title: "The page you were looking for doesn't exist (404 Not found)",
      message: "<strong>The page you were looking for doesn't exist.</strong> You may have mistyped the address or the page may have moved. If you're the application owner check the logs for more information."
    },
    "/406-unsupported-browser.html" => {
      label: "406 Not Acceptable",
      title: "Your browser is not supported (406 Not Acceptable)",
      message: "<strong>Your browser is not supported.</strong><br> Please upgrade your browser to continue."
    },
    "/422.html" => {
      label: "422 Unprocessable Entity",
      title: "The change you wanted was rejected (422 Unprocessable Entity)",
      message: "<strong>The change you wanted was rejected.</strong> Maybe you tried to change something you didn't have access to. If you're the application owner check the logs for more information."
    },
    "/500.html" => {
      label: "500 Internal Server Error",
      title: "We're sorry, but something went wrong (500 Internal Server Error)",
      message: "<strong>We're sorry, but something went wrong.</strong><br> If you're the application owner check the logs for more information."
    }
  }.freeze

  # "#RRGGBB" to the computed "rgb(r, g, b)".
  def self.rgb(hex)
    "rgb(#{hex.delete("#").scan(/../).map(&:hex).join(", ")})"
  end

  # The page grounds are the app's theme colors; the text and fill shades are
  # the design system's own.
  DARK_PARTS = {
    "body" => rgb(ThemesHelper::THEME_COLORS["dark"]),
    "strong" => "rgb(249, 250, 251)",
    "p" => "rgb(209, 213, 219)",
    "#error-id" => "rgb(31, 41, 55)",
    "#error-description" => "rgb(248, 113, 113)"
  }.freeze

  LIGHT_PARTS = {
    "body" => rgb(ThemesHelper::THEME_COLORS["light"]),
    "strong" => "rgb(17, 24, 39)",
    "p" => "rgb(55, 65, 81)",
    "#error-id" => "rgb(229, 231, 235)",
    "#error-description" => "rgb(185, 28, 28)"
  }.freeze

  def paint(selector)
    property = if selector.start_with?("#")
      "fill"
    elsif selector == "body"
      "background-color"
    else
      "color"
    end
    style(selector, property)
  end

  def expect_parts(parts)
    parts.each { |selector, value| expect(paint(selector)).to eq(value), "#{selector}: #{paint(selector)}" }
  end

  def color_scheme = style(":root", "color-scheme")

  def data_theme = page.evaluate_script("document.documentElement.getAttribute('data-theme')")

  def theme_colors = page.evaluate_script("[...document.querySelectorAll('meta[name=theme-color]')].map(m => [m.content, m.media])")

  # The cookie is set on the app's host, then the page is loaded again.
  def visit_with_cookie(path, value)
    visit path
    page.driver.browser.manage.add_cookie(name: "theme", value: value, path: "/")
    visit path
  end
end

RSpec.shared_context "static error pages" do
  include_context "settings menu"
  include StaticErrorPages
end
