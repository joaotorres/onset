# The five static error pages in public/ (SPEC §10 Themes, DESIGN v7 Screens >
# Static error pages): the pages, their titles' brackets and the computed
# colors of each part in each theme.
module StaticErrorPages
  PAGES = {
    "/400.html" => "400 Bad Request",
    "/404.html" => "404 Not found",
    "/406-unsupported-browser.html" => "406 Not Acceptable",
    "/422.html" => "422 Unprocessable Entity",
    "/500.html" => "500 Internal Server Error"
  }.freeze

  DARK_PARTS = {
    "body" => "rgb(3, 7, 18)",
    "strong" => "rgb(249, 250, 251)",
    "p" => "rgb(209, 213, 219)",
    "#error-id" => "rgb(31, 41, 55)",
    "#error-description" => "rgb(248, 113, 113)"
  }.freeze

  LIGHT_PARTS = {
    "body" => "rgb(249, 250, 251)",
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
