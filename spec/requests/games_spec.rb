require "rails_helper"

RSpec.describe "Games" do
  describe "POST /games" do
    it "creates a game and redirects to its board" do
      expect { post games_path }.to change(Game, :count).by(1)
      expect(response).to redirect_to(game_path(Game.last.code))
    end

    it "sets the host cookie" do
      post games_path
      expect(cookies[:host_game]).to be_present
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

  describe "POST /games/:code/start" do
    let(:game) { Game.create! }

    context "as the host" do
      before do
        post games_path  # sets host cookie
        @game = Game.last
      end

      it "transitions the game to playing" do
        post start_game_path(@game.code)
        expect(@game.reload).to be_playing
      end

      it "deals 12 cards to the board" do
        post start_game_path(@game.code)
        expect(@game.reload.board.size).to eq(12)
      end

      it "redirects back to the board" do
        post start_game_path(@game.code)
        expect(response).to redirect_to(game_path(@game.code))
      end
    end

    context "as a non-host" do
      it "returns 403" do
        post start_game_path(game.code)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "POST /games/:code/restart" do
    context "as the host" do
      before do
        post games_path
        @game = Game.last
        @game.update!(status: :ended, board: [], deck: [], discard: [])
      end

      it "transitions the game to playing" do
        post restart_game_path(@game.code)
        expect(@game.reload).to be_playing
      end

      it "deals 12 cards to the board" do
        post restart_game_path(@game.code)
        expect(@game.reload.board.size).to eq(12)
      end

      it "redirects back to the board" do
        post restart_game_path(@game.code)
        expect(response).to redirect_to(game_path(@game.code))
      end

      it "resets player scores" do
        player = @game.players.create!(name: "Alice", color: "#648FFF", score: 5)
        post restart_game_path(@game.code)
        expect(player.reload.score).to eq(0)
      end
    end

    context "as a non-host" do
      let(:game) { Game.create! }

      it "returns 403" do
        post restart_game_path(game.code)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
