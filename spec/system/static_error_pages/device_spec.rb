require "rails_helper"

# Ticket 42: with no theme cookie the static error pages follow the device.
RSpec.describe "Static error pages on the device's setting", type: :system do
  include_context "static error pages"

  StaticErrorPages::PAGES.each_key do |path|
    describe path do
      it "is dark on a dark device" do
        emulate_color_scheme("dark")
        visit path
        expect_parts(StaticErrorPages::DARK_PARTS)
        expect(color_scheme).to eq("dark")
      end

      it "is light on a light device" do
        emulate_color_scheme("light")
        visit path
        expect_parts(StaticErrorPages::LIGHT_PARTS)
        expect(color_scheme).to eq("light")
      end

      it "is dark when the device states no preference" do
        emulate_color_scheme("")
        visit path
        expect_parts(StaticErrorPages::DARK_PARTS)
        expect(color_scheme).to eq("dark")
      end
    end
  end
end
