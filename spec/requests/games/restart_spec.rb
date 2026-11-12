require "rails_helper"

RSpec.describe "Games" do
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

      it "answers 204 so the board is not reloaded" do
        post restart_game_path(@game.code)
        expect(response).to have_http_status(:no_content)
      end

      it "restarts at once with votes pending and clears them" do
        @game.update!(start_voters: [123])
        post restart_game_path(@game.code)
        expect(@game.reload).to be_playing
        expect(@game.start_voters).to be_empty
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
