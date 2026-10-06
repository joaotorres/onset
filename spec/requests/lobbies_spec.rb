require "rails_helper"

RSpec.describe "Lobbies", type: :request do
  describe "GET /" do
    it "returns 200" do
      get root_path
      expect(response).to have_http_status(:ok)
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
      expect(flash[:alert]).to match(/Room not found/)
    end
  end

  describe "GET /how-to-play" do
    it "returns 200 and renders the four sections" do
      get how_to_play_path
      expect(response).to have_http_status(:ok)
      ["Every card has four features", "What makes a Set", "Almost, but not a Set", "Playing Onset"].each do |heading|
        expect(response.body).to include(heading)
      end
    end

    it "links back to the game when return_to is a same-site path" do
      get how_to_play_path, params: {return_to: "/games/ABC123/controller"}
      expect(response.body).to include(%(href="/games/ABC123/controller">Back to the game</a>))
    end

    ["https://example.com", "//example.com"].each do |url|
      it "ignores return_to=#{url} and goes back to the root" do
        get how_to_play_path, params: {return_to: url}
        expect(response.body).to include(%(href="#{root_path}">← Back</a>))
        expect(response.body).not_to include("Back to the game")
        expect(response.body).not_to include("example.com")
      end
    end
  end
end
