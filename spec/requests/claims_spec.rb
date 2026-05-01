require "rails_helper"

RSpec.describe "Claims" do
  let(:game) {
    Game.create!.tap { |g| g.update!(status: :playing, board: (0..11).to_a, deck: (12..80).to_a, discard: []) }
  }

  # Sign in a player by going through the real join flow so the encrypted
  # cookie is set correctly in the Rack::Test session.
  def sign_in(name: "Alice", color: "#E74C3C")
    post game_players_path(game.code), params: {player: {name: name, color: color}}
    game.players.find_by!(name: name)
  end

  def valid_set_ids
    game.board_cards.combination(3).find { |trio| Card.valid_set?(*trio) }.map(&:id)
  end

  describe "POST /games/:code/claims" do
    it "acquires a claim and redirects to the controller view" do
      sign_in
      expect { post game_claims_path(game.code) }
        .to change(Claim, :count).by(1)
      expect(response).to redirect_to(game_controller_path(game.code))
    end

    it "returns 409 when a claim is already active" do
      other = game.players.create!(name: "Bob", color: "#2ECC71")
      game.try_claim!(other)
      sign_in
      post game_claims_path(game.code)
      expect(response).to have_http_status(:conflict)
    end

    it "returns 409 when the player is locked out after a wrong claim" do
      player = sign_in
      claim = game.try_claim!(player)
      non_set_ids = game.board_cards.combination(3).find { |trio| !Card.valid_set?(*trio) }.map(&:id)
      claim.submit!(non_set_ids)
      expect(player.reload).to be_locked

      post game_claims_path(game.code)
      expect(response).to have_http_status(:conflict)
    end
  end

  describe "PATCH /games/:code/claims/:id" do
    it "resolves a correct claim and redirects" do
      player = sign_in
      claim = game.try_claim!(player)
      patch game_claim_path(game.code, claim.id), params: {card_ids: valid_set_ids.to_json}
      expect(claim.reload).to be_correct
      expect(response).to redirect_to(game_controller_path(game.code))
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
