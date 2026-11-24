require "rails_helper"

# Ticket 87: a page restored from the back-forward cache reads the theme
# cookie again, as it is then.
RSpec.describe "Static error pages shown again by Back", type: :system do
  include_context "static error pages"

  # The two theme-color metas as the files ship them, for Match device.
  let(:match_device) { [["#F9FAFB", "(prefers-color-scheme: light)"], ["#030712", nil]] }

  def away_and_back
    mark_window
    visit "data:text/html,<p>away</p>"
    page.go_back
    expect_same_window
  end

  StaticErrorPages::PAGES.each_key do |path|
    describe path do
      before { emulate_color_scheme("dark") }

      it "takes theme=light set while it was open" do
        visit path
        light!
        away_and_back
        expect(data_theme).to eq("light")
        expect_parts(StaticErrorPages::LIGHT_PARTS)
        expect(color_scheme).to eq("light")
        expect(theme_color_metas).to eq([["#F9FAFB", nil]])
      end

      it "follows the device again once the cookie is deleted" do
        visit path
        light!
        visit path
        delete_cookie("theme")
        away_and_back
        expect(data_theme).to be_nil
        expect_parts(StaticErrorPages::DARK_PARTS)
        expect(color_scheme).to eq("dark")
        expect(theme_color_metas).to eq(match_device)
      end
    end
  end

  describe "/404.html from one picked theme to another" do
    before do
      emulate_color_scheme("dark")
      visit "/404.html"
      light!
      visit "/404.html"
    end

    it "takes theme=dark" do
      theme_cookie!("dark")
      away_and_back
      expect(data_theme).to eq("dark")
      expect_parts(StaticErrorPages::DARK_PARTS)
      expect(theme_color_metas).to eq([["#030712", nil]])
    end

    it "follows the device with theme=blue" do
      theme_cookie!("blue")
      away_and_back
      expect(data_theme).to be_nil
      expect_parts(StaticErrorPages::DARK_PARTS)
      expect(theme_color_metas).to eq(match_device)
    end
  end

  it "runs the same inline theme script on all five pages" do
    scripts = StaticErrorPages::PAGES.keys.map do |path|
      File.read(Rails.public_path.join(path.delete_prefix("/")))[%r{<script>.*?</script>}m]
    end
    expect(scripts.first).to be_present
    expect(scripts.uniq.size).to eq(1)
  end
end
