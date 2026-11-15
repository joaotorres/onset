# SPEC.md §10, Themes: the browser's theme lives in the `theme` cookie, read
# here so the layout renders it on <html> before the first paint.
module ThemesHelper
  THEMES = %w[light dark].freeze
  THEME_COLORS = {"light" => "#F9FAFB", "dark" => "#030712"}.freeze

  # "light", "dark", or nil for Match device.
  def chosen_theme
    cookies[:theme].presence_in(THEMES)
  end

  # With a theme, its one color; with none, the light one under the media
  # query and dark for every other device, no preference included.
  def theme_color_tags
    if chosen_theme
      tag.meta(name: "theme-color", content: THEME_COLORS[chosen_theme])
    else
      safe_join([
        tag.meta(name: "theme-color", content: THEME_COLORS["light"], media: "(prefers-color-scheme: light)"),
        tag.meta(name: "theme-color", content: THEME_COLORS["dark"])
      ], "\n    ")
    end
  end
end
