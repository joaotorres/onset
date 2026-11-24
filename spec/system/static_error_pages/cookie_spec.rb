require "rails_helper"

# Ticket 42: the theme cookie wins over the device, from the first paint.
RSpec.describe "Static error pages and the theme cookie", type: :system do
  include_context "static error pages"

  StaticErrorPages::PAGES.each_key do |path|
    describe path do
      it "is dark with theme=dark on a light device" do
        emulate_color_scheme("light")
        visit path
        theme_cookie!("dark")
        visit path
        expect_parts(StaticErrorPages::DARK_PARTS)
        expect(color_scheme).to eq("dark")
        expect(data_theme).to eq("dark")
      end

      it "is light with theme=light on a dark device" do
        emulate_color_scheme("dark")
        visit path
        light!
        visit path
        expect_parts(StaticErrorPages::LIGHT_PARTS)
        expect(color_scheme).to eq("light")
        expect(data_theme).to eq("light")
      end

      it "follows the device with theme=bogus, and sets no data-theme" do
        emulate_color_scheme("light")
        visit path
        theme_cookie!("bogus")
        visit path
        expect_parts(StaticErrorPages::LIGHT_PARTS)
        expect(data_theme).to be_nil
        expect(theme_cookie[:value]).to eq("bogus")
      end
    end
  end
end
