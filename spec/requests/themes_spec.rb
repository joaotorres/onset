require "rails_helper"

# SPEC §10 Themes: the layout renders the theme cookie on <html>, so the first
# paint is right before any script runs, and the theme-color meta follows it.
RSpec.describe "Themes" do
  let(:game) { Game.create! }

  def doc = Nokogiri::HTML(response.body)
  def html_theme = doc.at_css("html")["data-theme"]
  def theme_colors = doc.css('meta[name="theme-color"]').map { |m| [m["content"], m["media"]] }

  {"landing" => -> { root_path }, "How to play" => -> { how_to_play_path }, "join page" => -> { join_game_players_path(game.code) }}.each do |name, path|
    context "on the #{name}" do
      it "renders the light theme on <html> for theme=light" do
        cookies[:theme] = "light"
        get instance_exec(&path)
        expect(html_theme).to eq("light")
        expect(theme_colors).to eq([["#F9FAFB", nil]])
      end

      it "renders the dark theme on <html> for theme=dark" do
        cookies[:theme] = "dark"
        get instance_exec(&path)
        expect(html_theme).to eq("dark")
        expect(theme_colors).to eq([["#030712", nil]])
      end

      it "leaves the theme to the device with no cookie" do
        get instance_exec(&path)
        expect(html_theme).to be_nil
        expect(theme_colors).to eq([["#F9FAFB", "(prefers-color-scheme: light)"], ["#030712", nil]])
      end

      it "ignores a cookie that is neither light nor dark" do
        cookies[:theme] = "purple"
        get instance_exec(&path)
        expect(html_theme).to be_nil
      end

      it "shows the settings button and menu outside main's broadcast targets" do
        cookies[:theme] = "light"
        get instance_exec(&path)
        settings = doc.at_css('[data-controller="settings"]')
        expect(settings.at_css('button[aria-label="Settings"][aria-expanded="false"]')).to be_present
        dialog = settings.at_css('[role="dialog"][aria-label="Settings"]')
        expect(dialog.css('input[type="radio"][name="theme"]').map { |r| r["value"] }).to eq(%w[device light dark])
        expect(dialog.at_css('input[name="theme"][checked]')["value"]).to eq("light")
      end
    end
  end

  it "checks Match device with no cookie" do
    get root_path
    expect(doc.at_css('input[name="theme"][checked]')["value"]).to eq("device")
  end
end
