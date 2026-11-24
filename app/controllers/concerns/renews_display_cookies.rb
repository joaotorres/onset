# SPEC §10 Themes and Palette, "Stored per browser": every page the layout
# renders sends the theme and card_colors cookies back with a fresh year while
# they hold a value the server accepts. Safari caps a cookie a script writes at
# 7 days; one the server sends keeps its full year. Only responses that render
# a page renew, so a 204 answered while a pick is made never undoes the pick.
module RenewsDisplayCookies
  extend ActiveSupport::Concern

  included do
    after_action :renew_display_cookies, if: :renders_page?
  end

  private

  def renew_display_cookies
    {theme: helpers.chosen_theme, card_colors: helpers.chosen_card_colors}.each do |name, value|
      next unless value

      # Not HttpOnly: the settings menu still reads and writes it.
      cookies[name] = {value: value, path: "/", expires: 1.year.from_now, same_site: :lax, httponly: false}
    end
  end

  def renders_page? = response.media_type == "text/html" && response.body.present?
end
