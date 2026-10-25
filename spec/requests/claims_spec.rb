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

    def near_tie_lines
      lines = []
      allow(Rails.logger).to receive(:info) { |msg = nil, &blk| lines << (msg || blk&.call).to_s }
      yield
      lines.grep(/near_tie/)
    end

    it "logs a near-tie when the call loses to another player's running claim" do
      other = game.players.create!(name: "Bob", color: "#2ECC71")
      game.try_claim!(other)
      player = sign_in
      lines = near_tie_lines do
        expect { post game_claims_path(game.code) }.not_to change(Claim, :count)
      end
      expect(response).to have_http_status(:no_content)
      expect(lines.size).to eq(1)
      expect(lines.first).to match(/\Anear_tie game=#{game.code} winner=#{other.id} loser=#{player.id} late_ms=-?\d+\z/)
    end

    it "logs no near-tie for a locked-out player while another claim runs" do
      player = sign_in
      player.update!(locked_until: 5.seconds.from_now)
      other = game.players.create!(name: "Bob", color: "#2ECC71")
      game.try_claim!(other)
      lines = near_tie_lines { post game_claims_path(game.code) }
      expect(response).to have_http_status(:no_content)
      expect(lines).to be_empty
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

  describe "POST /games/:code/claims/:id/submit" do
    def submit(claim, ids, as: :json)
      if as == :json
        post submit_game_claim_path(game.code, claim.id), params: {card_ids: ids}, as: :json
      else
        post submit_game_claim_path(game.code, claim.id), params: {card_ids: ids.to_json}
      end
    end

    def non_set_ids
      game.board_cards.combination(3).find { |trio| !Card.valid_set?(*trio) }.map(&:id)
    end

    it "judges three cards that form a Set at once, as expiry does, and answers 204" do
      player = sign_in
      claim = game.try_claim!(player)
      ids = valid_set_ids

      submit(claim, ids)
      expect(response).to have_http_status(:no_content)
      expect(claim.reload).to be_correct
      expect(claim.card_ids).to eq(ids)
      expect(claim.resolved_at).to be_present
      expect(player.reload.score).to eq(1)
      game.reload
      expect(game.board).not_to include(*ids)
      expect(game.board.size).to eq(12)
      expect(game.last_dealt).to eq([12, 13, 14])
      expect(game.claim_player_id).to be_nil
      expect(game.flash_claim_id).to eq(claim.id)
    end

    it "judges three cards that do not form a Set as wrong, with the lockout, and answers 204" do
      player = sign_in
      player.update!(score: 2)
      claim = game.try_claim!(player)

      submit(claim, non_set_ids)
      expect(response).to have_http_status(:no_content)
      expect(claim.reload).to be_wrong
      expect(player.reload.score).to eq(1)
      expect(player.locked_until).to be_within(2.seconds).of(Game::CLAIM_TIMEOUT.seconds.from_now)
      expect(game.reload.claim_player_id).to be_nil
    end

    it "floors the score at 0 on a wrong submit" do
      player = sign_in
      claim = game.try_claim!(player)
      submit(claim, non_set_ids)
      expect(player.reload.score).to eq(0)
    end

    it "judges the submitted selection, not the stored picks" do
      player = sign_in
      claim = game.try_claim!(player)
      ids = valid_set_ids
      claim.pick!((game.board - ids).first(2))

      submit(claim, ids, as: :form)
      expect(claim.reload).to be_correct
      expect(claim.card_ids).to eq(ids)
    end

    it "ignores a selection that is not 3 distinct board cards, still answering 204" do
      player = sign_in
      claim = game.try_claim!(player)
      ids = valid_set_ids

      [ids.first(2), ids + [(game.board - ids).first], [ids[0], ids[0], ids[1]], [ids[0], ids[1], 50], ["x", ids[0], ids[1]], nil].each do |bad|
        submit(claim, bad)
        expect(response).to have_http_status(:no_content)
        expect(claim.reload).to be_pending
      end
      post submit_game_claim_path(game.code, claim.id)
      expect(response).to have_http_status(:no_content)
      expect(claim.reload).to be_pending
      expect(player.reload.score).to eq(0)
    end

    it "ignores a submit once the claim is no longer pending, and the timer no-ops after a submit" do
      player = sign_in
      claim = game.try_claim!(player)
      submit(claim, valid_set_ids)
      before = [claim.reload.attributes, player.reload.score, game.reload.board]

      submit(claim, non_set_ids)
      expect(response).to have_http_status(:no_content)
      ExpireClaimJob.new.perform(claim)
      expect([claim.reload.attributes, player.reload.score, game.reload.board]).to eq(before)
    end

    it "ignores a submit on an expired claim" do
      player = sign_in
      claim = game.try_claim!(player)
      ExpireClaimJob.new.perform(claim)
      submit(claim, valid_set_ids)
      expect(response).to have_http_status(:no_content)
      expect(claim.reload).to be_expired
    end

    it "rejects a submit from a player who does not hold the claim" do
      player = sign_in(name: "Alice")
      claim = game.try_claim!(player)
      sign_in(name: "Bob", color: "#2ECC71")
      submit(claim, valid_set_ids)
      expect(response).to have_http_status(:forbidden)
      expect(claim.reload).to be_pending
      expect(claim.card_ids).to be_nil
      expect(player.reload.score).to eq(0)
    end

    it "holds the game lock while judging" do
      player = sign_in
      claim = game.try_claim!(player)
      ids = valid_set_ids
      expect_any_instance_of(Game).to receive(:with_lock).once.and_call_original
      submit(claim, ids)
      expect(claim.reload).to be_correct
    end

    it "sends the broadcasts a claim judged at expiry sends" do
      targets = ->(streams) { streams.map { |s| s["target"] } }

      player = sign_in
      claim = game.try_claim!(player)
      ids = valid_set_ids
      submitted = capture_turbo_stream_broadcasts("game:#{game.code}") { submit(claim, ids) }

      other_game = Game.create!.tap { |g| g.update!(status: :playing, board: (0..11).to_a, deck: (12..80).to_a, discard: []) }
      other_claim = other_game.try_claim!(other_game.players.create!(name: "Cy", color: "#E74C3C"))
      other_claim.pick!(ids)
      expired = capture_turbo_stream_broadcasts("game:#{other_game.code}") { ExpireClaimJob.new.perform(other_claim) }

      expect(targets.call(submitted)).to eq(targets.call(expired))
    end
  end
end
