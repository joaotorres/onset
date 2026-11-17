# SPEC.md §10, Themes: the browser's theme lives in the `theme` cookie, read
# here so the layout renders it on <html> before the first paint.
module ThemesHelper
  THEMES = %w[light dark].freeze
  THEME_COLORS = {"light" => "#F9FAFB", "dark" => "#030712"}.freeze

  # "light", "dark", or nil for Match device.
  def chosen_theme
    cookies[:theme].presence_in(THEMES)
  end

  # SPEC §10 Palette: "colorblind", or nil for Classic. Rendered on <html>
  # beside the theme, never in a broadcast.
  def chosen_card_colors
    cookies[:card_colors].presence_in(%w[colorblind])
  end

  # The theme-color metas for a choice ("device", "light", "dark"): with a
  # theme, its one color; with none, the light one under the media query and
  # dark for every other device, no preference included.
  def self.theme_color_metas(choice)
    return [{content: THEME_COLORS[choice]}] if THEMES.include?(choice)

    [{content: THEME_COLORS["light"], media: "(prefers-color-scheme: light)"}, {content: THEME_COLORS["dark"]}]
  end

  def theme_color_tags
    metas = ThemesHelper.theme_color_metas(chosen_theme || "device")
    safe_join(metas.map { |meta| tag.meta(name: "theme-color", **meta) }, "\n    ")
  end

  # Every choice's metas, for the settings controller to apply on a pick.
  def theme_color_values
    %w[device light dark].index_with { |choice| ThemesHelper.theme_color_metas(choice) }.to_json
  end
end
