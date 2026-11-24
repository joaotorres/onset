require "rails_helper"

# Ticket 42: theme-color metas and the header graphic's accessible name.
RSpec.describe "Static error pages' metas and graphic", type: :system do
  include_context "static error pages"

  light = ThemesHelper::THEME_COLORS["light"]
  dark = ThemesHelper::THEME_COLORS["dark"]

  StaticErrorPages::PAGES.each do |path, page_info|
    label = page_info[:label]

    describe path do
      it "gives the Match device theme-color pair with no cookie" do
        visit path
        expect(theme_color_metas).to eq([[light, "(prefers-color-scheme: light)"], [dark, nil]])
      end

      it "leaves one theme-color, the light one, with theme=light" do
        visit path
        light!
        visit path
        expect(theme_color_metas).to eq([[light, nil]])
      end

      it "leaves one theme-color, the dark one, with theme=dark" do
        visit path
        theme_cookie!("dark")
        visit path
        expect(theme_color_metas).to eq([[dark, nil]])
      end

      it "keeps the scaffold's title and message" do
        visit path
        expect(page.title).to eq(page_info[:title])
        expect(page.evaluate_script("document.querySelector('main article p').innerHTML")).to eq(page_info[:message])
      end

      it "writes hex colors only in custom property declarations" do
        css = File.read(Rails.public_path.join(path.delete_prefix("/")))[%r{<style>(.*?)</style>}m, 1]
        stray = css.lines.select { |l| l.match?(/#\h{6}/) && !l.match?(/\A\s*--[\w-]+:\s*#\h{6};\s*\z/) }
        expect(stray).to be_empty
      end

      it "writes each themed rule once, with one light override block per light condition" do
        css = File.read(Rails.public_path.join(path.delete_prefix("/")))[%r{<style>(.*?)</style>}m, 1]
        %w[body strong #error-id #error-description].each do |selector|
          expect(css.scan(/^\s*#{Regexp.escape(selector)} \{/).size).to eq(1), selector
        end
        expect(css.scan('[data-theme="light"]').size).to eq(1)
        expect(css.scan(":root:not([data-theme])").size).to eq(1)
      end

      it "names the header graphic by the code and name in the title's brackets" do
        visit path
        expect(page.title).to end_with("(#{label})")
        expect(page).to have_css("header svg[role='img'][aria-label='#{label}']")
      end
    end
  end
end
