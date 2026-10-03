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
end
