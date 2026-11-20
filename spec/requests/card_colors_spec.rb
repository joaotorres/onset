require "rails_helper"

# SPEC §10 Palette: the card_colors cookie is rendered on <html> so the first
# paint is right, the settings menu shows the Card colors group, and nothing a
# broadcast carries depends on the viewer's card_colors or theme cookies.
RSpec.describe "Card colors" do
  let(:game) { Game.create! }

  def doc = Nokogiri::HTML(response.body)
  def html_card_colors = doc.at_css("html")["data-card-colors"]
  def normalised(html) = html.gsub(/(stripes-\w+)-\h{8}/, '\1')

  def cookie!(name, value)
    value ? cookies[name] = value : cookies.delete(name)
  end

  {"landing" => -> { root_path }, "How to play" => -> { how_to_play_path }, "join page" => -> { join_game_players_path(game.code) }}.each do |name, path|
    context "on the #{name}" do
      it "renders card_colors on <html> for card_colors=colorblind" do
        cookies[:card_colors] = "colorblind"
        get instance_exec(&path)
        expect(html_card_colors).to eq("colorblind")
      end

      it "renders no card_colors with no cookie or an unknown one" do
        get instance_exec(&path)
        expect(html_card_colors).to be_nil
        cookies[:card_colors] = "rainbow"
        get instance_exec(&path)
        expect(html_card_colors).to be_nil
      end

      it "shows the Card colors group under Theme, Classic checked with no cookie" do
        get instance_exec(&path)
        dialog = doc.at_css('[data-controller="settings"] [role="dialog"]')
        legends = dialog.css("fieldset > legend").map { |l| l.text.strip }
        expect(legends).to eq(["Theme", "Card colors"])
        group = dialog.css("fieldset")[1]
        expect(group.css('input[type="radio"][name="card_colors"]').map { |r| r["value"] }).to eq(%w[classic colorblind])
        expect(group.css("label").map { |l| l.text.strip }).to eq(["Classic", "Color-blind"])
        expect(group.at_css('input[name="card_colors"][checked]')["value"]).to eq("classic")
      end

      it "checks Color-blind with the cookie" do
        cookies[:card_colors] = "colorblind"
        get instance_exec(&path)
        expect(doc.at_css('input[name="card_colors"][checked]')["value"]).to eq("colorblind")
      end
    end
  end

  it "renders the same card markup with and without the cookie, pattern ids aside" do
    cards = -> { normalised(doc.css("main svg").map(&:to_html).join) }
    get how_to_play_path
    classic = cards.call
    expect(classic).to include("color-mark")
    cookies[:card_colors] = "colorblind"
    get how_to_play_path
    expect(cards.call).to eq(classic)
  end

  context "on the player screen" do
    let!(:bob) { game.players.create!(name: "Bob", color: "#2ECC71", last_seen_at: Time.current) }

    before do
      post game_players_path(game.code), params: {player: {name: "Alice", color: "#E74C3C"}}
      game.start!
      game.update!(board: [0, 9, 18, 1, 10, 19, 2, 11, 20, 3, 12, 21])
    end

    def status_with(card_colors, theme)
      cookie!(:card_colors, card_colors)
      cookie!(:theme, theme)
      get game_controller_path(game.code)
      status = doc.at_css("#controller_status")
      status.css('input[name="authenticity_token"]').each(&:remove)
      normalised(status.to_html)
    end

    it "holds the Card colors group in the settings menu" do
      get game_controller_path(game.code)
      expect(doc.css('[role="dialog"] input[name="card_colors"]').map { |r| r["value"] }).to eq(%w[classic colorblind])
    end

    it "renders #controller_status the same whatever the card_colors and theme cookies" do
      none = status_with(nil, nil)
      expect(none).to include("color-mark")
      [["colorblind", nil], ["colorblind", "light"], ["colorblind", "dark"], [nil, "light"]].each do |cc, theme|
        expect(status_with(cc, theme)).to eq(none), "card_colors=#{cc.inspect} theme=#{theme.inspect}"
      end
    end
  end

  context "on the big screen" do
    before do
      game.players.create!(name: "Alice", color: "#E74C3C", last_seen_at: Time.current)
      game.players.create!(name: "Bob", color: "#2ECC71", last_seen_at: Time.current)
      game.start!
    end

    def board_with(card_colors, theme)
      cookie!(:card_colors, card_colors)
      cookie!(:theme, theme)
      get game_path(game.code)
      normalised(doc.at_css("#board").to_html)
    end

    it "holds the Card colors group in the settings menu" do
      get game_path(game.code)
      expect(doc.css('[role="dialog"] input[name="card_colors"]').map { |r| r["value"] }).to eq(%w[classic colorblind])
    end

    it "renders #board the same whatever the card_colors and theme cookies" do
      none = board_with(nil, nil)
      expect(none).to include("color-mark")
      [["colorblind", nil], ["colorblind", "light"], [nil, "dark"]].each do |cc, theme|
        expect(board_with(cc, theme)).to eq(none), "card_colors=#{cc.inspect} theme=#{theme.inspect}"
      end
    end
  end
end
