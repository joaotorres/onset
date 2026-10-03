require "rails_helper"

RSpec.describe "EndGames" do
  let(:game) {
    Game.create!.tap { |g| g.update!(status: :playing, board: (0..11).to_a, deck: [], discard: []) }
  }

  def sign_in(name: "Alice", color: "#E74C3C")
    game.update_columns(status: 0)
    post game_players_path(game.code), params: {player: {name: name, color: color}}
    game.update_columns(status: 1)
    game.reload.players.find_by!(name: name)
  end

  describe "POST /games/:code/end_game" do
    it "records the vote and answers 204 so the page is not reloaded" do
      player = sign_in
      game.players.create!(name: "Bob", color: "#2ECC71", last_seen_at: Time.current)
      post game_end_game_path(game.code)
      expect(game.reload.end_game_voters).to eq([player.id])
      expect(response).to have_http_status(:no_content)
    end

    it "marks the voter as seen, so a lone active voter ends the game" do
      player = sign_in
      expect { post game_end_game_path(game.code) }
        .to change { player.reload.last_seen_at }
      expect(game.reload).to be_ended
    end
  end
end
