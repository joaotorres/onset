require "rails_helper"

RSpec.describe "Players" do
  let(:game) { Game.create! }

  describe "GET /games/:code/players/join" do
    it "returns 200 and shows the join form" do
      get join_game_players_path(game.code)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Join Game")
    end
  end

  describe "POST /games/:code/players" do
    let(:valid_params) { {player: {name: "Alice", color: "#E74C3C"}} }

    it "creates a player and redirects to the controller view" do
      expect { post game_players_path(game.code), params: valid_params }
        .to change(Player, :count).by(1)
      expect(response).to redirect_to(game_controller_path(game.code))
    end

    it "sets the player token cookie" do
      post game_players_path(game.code), params: valid_params
      expect(cookies[:player_token]).to be_present
    end

    it "re-renders the form on invalid params" do
      post game_players_path(game.code), params: {player: {name: "", color: "#E74C3C"}}
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "GET /games/:code/controller" do
    it "shows the controller view after joining" do
      post game_players_path(game.code), params: {player: {name: "Alice", color: "#E74C3C"}}
      follow_redirect!
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Alice")
    end

    it "returns 404 with no valid cookie" do
      get game_controller_path(game.code)
      expect(response).to have_http_status(:not_found)
    end
  end
end
