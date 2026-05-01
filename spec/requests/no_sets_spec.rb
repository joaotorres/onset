require "rails_helper"

RSpec.describe "NoSets" do
  let(:game) {
    Game.create!.tap { |g| g.update!(status: :playing, board: (0..11).to_a, deck: (12..80).to_a, discard: []) }
  }

  def sign_in(name: "Alice", color: "#E74C3C")
    post game_players_path(game.code), params: {player: {name: name, color: color}}
    game.players.find_by!(name: name)
  end

  describe "POST /games/:code/no_set" do
    it "initiates a No-Set countdown and redirects" do
      sign_in
      post game_no_set_path(game.code)
      expect(game.reload.no_set_active?).to be true
      expect(response).to redirect_to(game_controller_path(game.code))
    end

    it "touches last_seen_at so the player counts as active" do
      player = sign_in
      post game_no_set_path(game.code)
      expect(player.reload.last_seen_at).to be_present
    end

    it "joins an existing No-Set call when one is already active" do
      # Charlie is created directly so she's active but the session cookie stays
      # on Alice/Bob — three active players means Bob joining alone won't resolve.
      game.players.create!(name: "Charlie", color: "#DC267F", last_seen_at: Time.current)

      sign_in(name: "Alice")
      post game_no_set_path(game.code)  # Alice calls No Set; her last_seen_at is set.
      alice = game.players.find_by!(name: "Alice")

      sign_in(name: "Bob", color: "#2ECC71")
      post game_no_set_path(game.code)  # Bob joins; his last_seen_at is set.
      bob = game.players.find_by!(name: "Bob")

      # Charlie hasn't voted yet, so the call stays active.
      game.reload
      expect(game.no_set_voters).to include(alice.id, bob.id)
      expect(game.no_set_active?).to be true
    end

    it "resolves immediately when the last active player votes via HTTP" do
      # Regression: last_seen_at was never written by the controller, so
      # all_active_players_voted? always returned false and resolution only
      # happened after the 15-second ExpireNoSetJob fired.
      sign_in(name: "Alice")
      post game_no_set_path(game.code)  # Alice calls No Set; her last_seen_at is now set.

      sign_in(name: "Bob", color: "#2ECC71")
      post game_no_set_path(game.code)  # Bob agrees; his last_seen_at is now set.

      game.reload
      expect(game.no_set_active?).to be false
      expect(game.board.size).to be > 12
    end
  end
end
