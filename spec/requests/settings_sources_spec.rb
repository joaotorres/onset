require "rails_helper"

# Ticket 50: the card palette, the card face, the color marks and the theme
# colors each have one source, which the settings menu and the cards read.
RSpec.describe "One source for the palette, the marks and the theme colors" do
  def doc = Nokogiri::HTML(response.body)
  def chips = doc.css('[role="dialog"] fieldset')[1]

  describe "the Card colors chips" do
    before { get how_to_play_path }

    it "carry no hex color and read the per-palette custom properties and the card face" do
      expect(chips.to_html).not_to match(/#\h{6}/)
      classic, colorblind = chips.css("label")
      expect(classic.css("[style]").map { |el| el["style"] }).to eq((0..2).map { |c| "background-color: var(--card-classic-#{c});" })
      expect(colorblind.css("polygon").map { |el| el["style"] }).to eq((0..2).map { |c| "fill: var(--card-colorblind-#{c});" })
      expect(chips.css("span.rounded").map { |el| el["class"] }).to all(include("bg-(--card-face)"))
    end

    it "draws each mark with the points the cards use for that color" do
      expect(chips.css("polygon").map { |el| el["points"] }).to eq(CardsHelper::COLOR_MARKS)
      (0..2).each do |color|
        card = Nokogiri::HTML5.fragment(render_card(Card.new(color * 9)))
        expect(card.css(".color-mark").map { |el| el["points"] }.uniq).to eq([CardsHelper::COLOR_MARKS[color]])
      end
    end
  end

  it "passes the settings controller the theme-color metas for each choice, as theme_color_tags renders them" do
    get root_path
    value = JSON.parse(doc.at_css('[data-controller="settings"]')["data-settings-theme-colors-value"])
    %w[device light dark].each do |choice|
      cookies[:theme] = (choice == "device") ? "" : choice
      get root_path
      rendered = doc.css('head meta[name="theme-color"]').map { |m| {"content" => m["content"], "media" => m["media"]}.compact }
      expect(value[choice]).to eq(rendered), choice
    end
  end

  describe "the sources under app/" do
    def files = Dir["app/**/*"].select { |f| File.file?(f) && !f.start_with?("app/assets/builds/") }
    def where(text) = files.flat_map { |f| [f] * File.read(f).upcase.scan(text.upcase).size }

    it "writes each palette hex once, in application.css" do
      %w[#C1121F #198A1E #5E2CA5 #648FFF #FE6100 #DC267F].each do |hex|
        expect(where(hex)).to eq(["app/assets/tailwind/application.css"]), hex
      end
    end

    it "writes each color mark's points once, in the helper" do
      CardsHelper::COLOR_MARKS.each do |points|
        expect(where(points)).to eq(["app/helpers/cards_helper.rb"]), points
      end
    end

    it "writes the theme colors only in ThemesHelper, the QR code, the manifest and the icon aside" do
      %w[#F9FAFB #030712].each do |hex|
        expect(where(hex) - ["app/views/pwa/manifest.json.erb"]).to eq(["app/helpers/themes_helper.rb"]), hex
      end
      controller = File.read("app/javascript/controllers/settings_controller.js")
      expect(controller).not_to match(/#\h{3,6}\b/)
      expect(controller).not_to include("prefers-color-scheme")
    end
  end

  def render_card(card) = ApplicationController.render(partial: "cards/card", locals: {card: card})
end
