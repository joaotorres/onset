require "rails_helper"

RSpec.describe "NoSets" do
  let(:game) {
    Game.create!.tap { |g| g.update!(status: :playing, board: (0..11).to_a, deck: (12..80).to_a, discard: []) }
  }

  def sign_in(name: "Alice", color: "#E74C3C")
    was_playing = game.playing?
    game.update_columns(status: 0) if was_playing
    post game_players_path(game.code), params: {player: {name: name, color: color}}
    game.update_columns(status: 1) if was_playing
    game.reload.players.find_by!(name: name)
  end

  describe "POST /games/:code/no_set" do
    it "initiates a No-Set countdown and answers 204" do
      sign_in
      post game_no_set_path(game.code)
      expect(game.reload.no_set_active?).to be true
      expect(response).to have_http_status(:no_content)
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

  describe "POST /games/:code/no_set/refuse" do
    let!(:caller_player) { game.players.create!(name: "Caller", color: "#648FFF", last_seen_at: Time.current) }

    it "refuses the running call and answers 204" do
      alice = sign_in
      game.call_no_set!(caller_player)
      post refuse_game_no_set_path(game.code)
      expect(response).to have_http_status(:no_content)
      game.reload
      expect(game.no_set_active?).to be false
      expect(game.no_set_refuser_id).to eq(alice.id)
      expect(game.no_set_refused_at).to be_present
    end

    it "answers 204 and changes nothing when no call is active" do
      sign_in
      post refuse_game_no_set_path(game.code)
      expect(response).to have_http_status(:no_content)
      expect(game.reload.no_set_refused_at).to be_nil
    end

    it "answers 204 and changes nothing for the caller" do
      sign_in
      post game_no_set_path(game.code)
      post refuse_game_no_set_path(game.code)
      expect(response).to have_http_status(:no_content)
      expect(game.reload.no_set_active?).to be true
      expect(game.no_set_refused_at).to be_nil
    end

    it "answers 204 and changes nothing for a player who agreed" do
      game.players.create!(name: "Third", color: "#DC267F", last_seen_at: Time.current)
      game.call_no_set!(caller_player)
      sign_in
      post game_no_set_path(game.code)
      post refuse_game_no_set_path(game.code)
      expect(response).to have_http_status(:no_content)
      expect(game.reload.no_set_active?).to be true
      expect(game.no_set_refused_at).to be_nil
    end

    it "answers 204 and changes nothing once this board's refusal is used" do
      sign_in
      used_at = (Game::NO_SET_TIMEOUT + 1).seconds.ago.change(usec: 0)
      game.update!(no_set_refuser_id: caller_player.id, no_set_refused_at: used_at)
      game.call_no_set!(caller_player)
      post refuse_game_no_set_path(game.code)
      expect(response).to have_http_status(:no_content)
      game.reload
      expect(game.no_set_active?).to be true
      expect(game.no_set_refuser_id).to eq(caller_player.id)
    end
  end
end
