require "rails_helper"

RSpec.describe "Games" do
  describe "POST /games" do
    it "creates a game and redirects to its board" do
      expect { post games_path }.to change(Game, :count).by(1)
      expect(response).to redirect_to(game_path(Game.last.code))
    end
  end

  describe "GET /games/:code" do
    let(:game) { Game.create! }

    it "returns 200 and shows the room code" do
      get game_path(game.code)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(game.code)
    end

    it "returns 404 for an unknown code" do
      get game_path("XXXXXX")
      expect(response).to have_http_status(:not_found)
    end
  end
end
