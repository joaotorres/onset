require "rails_helper"

RSpec.describe "Games" do
  describe "POST /games/:code/ready" do
    let(:game) { Game.create! }

    def sign_in_player(name: "Alice", color: "#E74C3C")
      post game_players_path(game.code), params: {player: {name: name, color: color}}
      game.players.find_by!(name: name)
    end

    it "records the player's vote without starting the game when others haven't voted" do
      player = sign_in_player
      create_player(game, name: "Bob")
      post ready_game_path(game.code)
      expect(game.reload.start_voters).to include(player.id)
      expect(game.reload).to be_waiting
      expect(response).to have_http_status(:no_content)
    end

    it "starts the game when all players have voted" do
      sign_in_player
      bob = create_player(game, name: "Bob", session_token: SecureRandom.hex)
      post ready_game_path(game.code)  # Alice votes via cookie
      game.vote_start!(bob)            # Bob votes directly
      expect(game.reload).to be_playing
    end

    it "does not start the game when only some players have voted" do
      sign_in_player
      create_player(game, name: "Bob")
      post ready_game_path(game.code)
      expect(game.reload).to be_waiting
    end

    context "once ended" do
      let!(:alice) { sign_in_player }
      let!(:bob) { create_player(game, name: "Bob", last_seen_at: Time.current) }

      before { game.start! && game.update!(status: :ended, deck: []) }

      it "records the vote and answers 204, a repeat changing nothing" do
        post ready_game_path(game.code)
        post ready_game_path(game.code)
        expect(response).to have_http_status(:no_content)
        expect(game.reload.start_voters).to eq([alice.id])
        expect(game).to be_ended
      end

      it "restarts the room once every active player has voted" do
        game.update!(start_voters: [bob.id])
        post ready_game_path(game.code)
        expect(game.reload).to be_playing
        expect(game.start_voters).to be_empty
      end

      it "marks the voter seen, so an idle voter counts for their own vote" do
        alice.update_column(:last_seen_at, 1.minute.ago)
        bob.update_column(:last_seen_at, 1.minute.ago)
        post ready_game_path(game.code)
        expect(alice.reload.last_seen_at).to be > 5.seconds.ago
        expect(game.reload).to be_playing
      end

      it "shows a Play again button on the player screen" do
        get game_controller_path(game.code)
        status = Nokogiri::HTML(response.body).at_css("#controller_status")
        expect(status.at_css("form[action='#{ready_game_path(game.code)}'] button").text).to include("Play again")
        expect(status.text).not_to include("Play again from the big screen")
      end

      it "shows the waiting line after voting, without the button" do
        post ready_game_path(game.code)
        get game_controller_path(game.code)
        status = Nokogiri::HTML(response.body).at_css("#controller_status")
        expect(status.text).to include("Ready ✓ · waiting for 1 more")
        expect(status.at_css("form[action='#{ready_game_path(game.code)}']")).to be_nil
      end
    end

    it "changes nothing while playing" do
      sign_in_player
      create_player(game, name: "Bob")
      game.start!
      post ready_game_path(game.code)
      expect(response).to have_http_status(:no_content)
      expect(game.reload).to be_playing
      expect(game.start_voters).to be_empty
    end

    it "returns 403 without a valid player cookie" do
      post ready_game_path(game.code)
      expect(response).to have_http_status(:forbidden)
    end
  end
end
