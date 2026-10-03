require "rails_helper"

RSpec.describe "Claims" do
  let(:game) {
    Game.create!.tap { |g| g.update!(status: :playing, board: (0..11).to_a, deck: (12..80).to_a, discard: []) }
  }

  def sign_in(name: "Alice", color: "#E74C3C")
    # Temporarily reset to waiting so the join HTTP flow is accepted, then restore
    was_playing = game.playing?
    game.update_columns(status: 0) if was_playing
    post game_players_path(game.code), params: {player: {name: name, color: color}}
    game.update_columns(status: 1) if was_playing
    game.reload.players.find_by!(name: name)
  end

  def valid_set_ids
    game.board_cards.combination(3).find { |trio| Card.valid_set?(*trio) }.map(&:id)
  end

  describe "POST /games/:code/claims" do
    it "acquires a claim and answers 204 so the page is not reloaded" do
      sign_in
      expect { post game_claims_path(game.code) }
        .to change(Claim, :count).by(1)
      expect(response).to have_http_status(:no_content)
    end

    it "ignores a claim while another is active, still answering 204" do
      other = game.players.create!(name: "Bob", color: "#2ECC71")
      game.try_claim!(other)
      sign_in
      expect { post game_claims_path(game.code) }.not_to change(Claim, :count)
      expect(response).to have_http_status(:no_content)
    end

    it "ignores a claim from a locked-out player, still answering 204" do
      player = sign_in
      claim = game.try_claim!(player)
      non_set_ids = game.board_cards.combination(3).find { |trio| !Card.valid_set?(*trio) }.map(&:id)
      claim.submit!(non_set_ids)
      expect(player.reload).to be_locked

      expect { post game_claims_path(game.code) }.not_to change(Claim, :count)
      expect(response).to have_http_status(:no_content)
    end
  end

  describe "PATCH /games/:code/claims/:id" do
    it "resolves a correct claim and answers 204" do
      player = sign_in
      claim = game.try_claim!(player)
      patch game_claim_path(game.code, claim.id), params: {card_ids: valid_set_ids.to_json}
      expect(claim.reload).to be_correct
      expect(response).to have_http_status(:no_content)
    end

    it "rejects a submission from a different player" do
      player = sign_in(name: "Alice")
      claim = game.try_claim!(player)
      sign_in(name: "Bob", color: "#2ECC71")  # switch cookie to Bob
      patch game_claim_path(game.code, claim.id), params: {card_ids: valid_set_ids.to_json}
      expect(response).to have_http_status(:forbidden)
    end
  end
end
