require "rails_helper"

RSpec.describe "Claims" do
  include Turbo::Broadcastable::TestHelper

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
      claim.pick!(non_set_ids)
      claim.expire!
      expect(player.reload).to be_locked

      expect { post game_claims_path(game.code) }.not_to change(Claim, :count)
      expect(response).to have_http_status(:no_content)
    end
  end

  describe "PATCH /games/:code/claims/:id" do
    def pick(claim, ids, as: :json)
      if as == :json
        patch game_claim_path(game.code, claim.id), params: {card_ids: ids}, as: :json
      else
        patch game_claim_path(game.code, claim.id), params: {card_ids: ids.to_json}
      end
    end

    it "stores one or two picks, answers 204 and leaves the game alone" do
      player = sign_in
      claim = game.try_claim!(player)
      game_before = game.reload.attributes

      pick(claim, [0])
      expect(response).to have_http_status(:no_content)
      expect(claim.reload.card_ids).to eq([0])

      pick(claim, [0, 5])
      expect(claim.reload.card_ids).to eq([0, 5])
      expect(claim).to be_pending
      expect(game.reload.attributes.except("updated_at")).to eq(game_before.except("updated_at"))
    end

    it "broadcasts nothing" do
      player = sign_in
      claim = game.try_claim!(player)
      player_streams = nil
      game_streams = capture_turbo_stream_broadcasts("game:#{game.code}") do
        player_streams = capture_turbo_stream_broadcasts("player:#{player.id}") { pick(claim, [0, 5]) }
      end
      expect(game_streams).to be_empty
      expect(player_streams).to be_empty
    end

    it "stores three picks that form a Set without judging them" do
      player = sign_in
      claim = game.try_claim!(player)
      ids = valid_set_ids

      pick(claim, ids)
      expect(response).to have_http_status(:no_content)
      expect(claim.reload).to be_pending
      expect(claim.card_ids).to eq(ids)
      expect(claim.resolved_at).to be_nil
      expect(player.reload.score).to eq(0)
    end

    it "accepts the picks as a JSON string param too" do
      player = sign_in
      claim = game.try_claim!(player)
      pick(claim, [0, 5], as: :form)
      expect(claim.reload.card_ids).to eq([0, 5])
    end

    it "ignores a card off the board, a duplicate or more than three cards" do
      player = sign_in
      claim = game.try_claim!(player)
      pick(claim, [0])

      [[0, 50], [0, 0], [0, 1, 2, 3]].each do |ids|
        pick(claim, ids)
        expect(response).to have_http_status(:no_content)
        expect(claim.reload.card_ids).to eq([0])
      end
    end

    it "rejects picks from a player who does not hold the claim" do
      player = sign_in(name: "Alice")
      claim = game.try_claim!(player)
      sign_in(name: "Bob", color: "#2ECC71")  # switch cookie to Bob
      pick(claim, valid_set_ids)
      expect(response).to have_http_status(:forbidden)
      expect(claim.reload.card_ids).to be_nil
      expect(claim).to be_pending
    end
  end
end
