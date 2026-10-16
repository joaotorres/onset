require "rails_helper"

RSpec.describe "Lobbies", type: :request do
  describe "GET /" do
    it "returns 200" do
      get root_path
      expect(response).to have_http_status(:ok)
    end

    def doc = Nokogiri::HTML(response.body)

    it "has one Start a game form with a Standard / First to 5 toggle, Standard checked" do
      get root_path
      forms = doc.css("form[action='#{games_path}'][method=post]")
      expect(forms.size).to eq(1)
      radios = forms.first.css("input[type=radio][name=mode]")
      expect(radios.map { |r| r["value"] }).to eq(%w[standard quick])
      expect(radios.select { |r| r["checked"] }.map { |r| r["value"] }).to eq(["standard"])
      expect(forms.first.text).to include("Standard", "First to #{Game::QUICK_WIN_SCORE}")
      expect(forms.first.css("button, input[type=submit]").map { |b| b.text.strip.presence || b["value"] })
        .to eq(["Start a game"])
      expect(forms.first.text).to include("Play from this screen, then invite the others")
    end

    it "uses the devices-first copy and no old wording" do
      get root_path
      text = doc.at_css("body").text
      expect(text).to include("Set, played live in the room. Everyone plays on their own screen, and a big screen is optional.")
      expect(text).not_to include("Start quick game")
      expect(text).not_to include("This screen becomes the board")
      expect(text).not_to match(/phone|controller|\bTV\b/i)
      expect(text).to include("New to Set? How to play")
    end

    it "shows Room not found under an empty, red-bordered code field" do
      get join_by_code_path, params: {code: "ZZZZZZ"}
      follow_redirect!
      expect(doc.at_css("p.text-red-400")&.text).to eq("Room not found")
      field = doc.at_css("input#room_code")
      expect(field["value"]).to be_blank
      expect(field["class"]).to include("border-red-500")
    end
  end

  describe "GET /join" do
    let(:game) { Game.create! }

    it "redirects to the room's join page, ignoring case and spaces" do
      get join_by_code_path, params: {code: " #{game.code.downcase} "}
      expect(response).to redirect_to(join_game_players_path(game.code))
    end

    it "sends unknown codes back to the landing page with an alert" do
      get join_by_code_path, params: {code: "ZZZZZZ"}
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("Room not found")
    end
  end

  describe "GET /how-to-play" do
    it "says the lockout lasts the claim time" do
      get how_to_play_path
      expect(response.parsed_body.text.squish).to include("you're locked out for #{Game::CLAIM_TIMEOUT} seconds")
    end

    it "returns 200 and renders the four sections" do
      get how_to_play_path
      expect(response).to have_http_status(:ok)
      ["Every card has four features", "What makes a Set", "Almost, but not a Set", "Playing Onset"].each do |heading|
        expect(response.body).to include(heading)
      end
    end

    it "describes devices-first play with the big screen optional" do
      get how_to_play_path
      text = response.parsed_body.text.squish
      [
        "Onset is the card game Set, played live. Everyone plays on their own phone or computer, sees the same cards and races to spot a Set. A big screen the whole table can see is optional.",
        "Join on your screen",
        "Start a game, or join one with its room code, link or QR, then pick a name and a color.",
        "Twelve cards go up on every player screen, and on the big screen if you use one. Everyone sees the same cards at the same time.",
        "Tap SET! on your screen, then pick the three cards within 15 seconds. Nobody else can call while you pick."
      ].each { |copy| expect(text).to include(copy) }
      ["Join from your phone", "Scan the code on the big screen", "on your phone", "from their phone"].each do |old|
        expect(text).not_to include(old)
      end
    end

    it "links back to the game's player screen when given its code" do
      get how_to_play_path, params: {game: "ABC234"}
      expect(response.body).to include(%(href="/games/ABC234/controller">Back to the game</a>))
    end

    ["https://example.com", "//example.com", "/\\example.com", "example.com/ABC234"].each do |url|
      it "ignores game=#{url} and goes back to the root" do
        get how_to_play_path, params: {game: url}
        expect(response.body).to include(%(href="#{root_path}">← Back</a>))
        expect(response.body).not_to include("Back to the game")
        expect(response.body).not_to include("example.com")
      end
    end
  end
end
