require "rails_helper"

# Ticket 42: theme-color metas and the header graphic's accessible name.
RSpec.describe "Static error pages' metas and graphic", type: :system do
  include_context "static error pages"

  StaticErrorPages::PAGES.each do |path, label|
    describe path do
      it "gives the Match device theme-color pair with no cookie" do
        visit path
        expect(theme_colors).to eq([["#F9FAFB", "(prefers-color-scheme: light)"], ["#030712", ""]])
      end

      it "leaves one theme-color, #F9FAFB, with theme=light" do
        visit_with_cookie(path, "light")
        expect(theme_colors).to eq([["#F9FAFB", ""]])
      end

      it "leaves one theme-color, #030712, with theme=dark" do
        visit_with_cookie(path, "dark")
        expect(theme_colors).to eq([["#030712", ""]])
      end

      it "names the header graphic by the code and name in the title's brackets" do
        visit path
        expect(page.title).to end_with("(#{label})")
        expect(page).to have_css("header svg[role='img'][aria-label='#{label}']")
      end
    end
  end
end
