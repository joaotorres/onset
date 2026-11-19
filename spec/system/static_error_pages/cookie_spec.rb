require "rails_helper"

# Ticket 42: the theme cookie wins over the device, from the first paint.
RSpec.describe "Static error pages and the theme cookie", type: :system do
  include_context "static error pages"

  StaticErrorPages::PAGES.each_key do |path|
    describe path do
      it "is dark with theme=dark on a light device" do
        emulate_color_scheme("light")
        visit_with_cookie(path, "dark")
        expect_parts(StaticErrorPages::DARK_PARTS)
        expect(color_scheme).to eq("dark")
        expect(data_theme).to eq("dark")
      end

      it "is light with theme=light on a dark device" do
        emulate_color_scheme("dark")
        visit_with_cookie(path, "light")
        expect_parts(StaticErrorPages::LIGHT_PARTS)
        expect(color_scheme).to eq("light")
        expect(data_theme).to eq("light")
      end

      it "follows the device with theme=bogus, and sets no data-theme" do
        emulate_color_scheme("light")
        visit_with_cookie(path, "bogus")
        expect_parts(StaticErrorPages::LIGHT_PARTS)
        expect(data_theme).to be_nil
        expect(page.driver.browser.manage.all_cookies.find { |c| c[:name] == "theme" }[:value]).to eq("bogus")
      end
    end
  end
end
