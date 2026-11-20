require "rails_helper"

RSpec.describe "Games" do
  describe "POST /games/:code/start" do
    let(:game) { Game.create! }

    context "as the host" do
      before do
        post games_path  # sets host cookie
        @game = Game.last
        @game.players.create!(name: "Alice", color: "#E74C3C", session_token: SecureRandom.hex)
        @game.players.create!(name: "Bob", color: "#2ECC71", session_token: SecureRandom.hex)
      end

      it "transitions the game to playing" do
        post start_game_path(@game.code)
        expect(@game.reload).to be_playing
      end

      it "deals 12 cards to the board" do
        post start_game_path(@game.code)
        expect(@game.reload.board.size).to eq(12)
      end

      it "answers 204 so the board is not reloaded" do
        post start_game_path(@game.code)
        expect(response).to have_http_status(:no_content)
      end

      it "ignores a start while playing, still 204, board and scores unchanged" do
        @game.start!
        @game.players.first.update!(score: 2)
        board = @game.reload.board
        post start_game_path(@game.code)
        expect(response).to have_http_status(:no_content)
        expect(@game.reload.board).to eq(board)
        expect(@game.players.first.score).to eq(2)
      end
    end

    context "as a non-host" do
      it "returns 403" do
        post start_game_path(game.code)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
