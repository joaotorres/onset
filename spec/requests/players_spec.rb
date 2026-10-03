require "rails_helper"

RSpec.describe "Players" do
  let(:game) { Game.create! }

  describe "GET /games/:code/players/join" do
    it "returns 200 and shows the join form" do
      get join_game_players_path(game.code)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Joining room")
    end

    it "marks a taken color with the initial of the player who took it" do
      game.players.create!(name: "marta", color: "#1ABC9C")
      get join_game_players_path(game.code)
      expect(response.body).to include('title="Taken by marta"')
      expect(response.body).to match(%r{<span class="text-lg font-bold text-gray-950">M</span>})
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

    it "redirects with an alert when the game has already started" do
      game.update!(status: :playing, board: (0..11).to_a, deck: (12..80).to_a, discard: [])
      post game_players_path(game.code), params: valid_params
      expect(response).to redirect_to(join_game_players_path(game.code))
    end

    it "rejects a duplicate color in the same game" do
      Player.create!(name: "Alice", color: "#E74C3C", game: game)
      post game_players_path(game.code), params: {player: {name: "Bob", color: "#E74C3C"}}
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("has already been taken in this game")
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
