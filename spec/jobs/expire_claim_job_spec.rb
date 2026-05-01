require "rails_helper"

RSpec.describe ExpireClaimJob do
  let(:game) {
    Game.create!.tap { |g| g.update!(status: :playing, board: (0..11).to_a, deck: (12..80).to_a, discard: []) }
  }
  let(:player) { game.players.create!(name: "Alice", color: "#E74C3C") }

  def valid_set_ids
    game.board_cards.combination(3).find { |trio| Card.valid_set?(*trio) }.map(&:id)
  end

  describe "#perform" do
    it "expires a pending claim" do
      claim = game.try_claim!(player)
      described_class.new.perform(claim)
      expect(claim.reload).to be_expired
    end

    it "releases the claim lock on the game" do
      claim = game.try_claim!(player)
      described_class.new.perform(claim)
      expect(game.reload.claim_player_id).to be_nil
      expect(game.reload.claim_started_at).to be_nil
    end

    it "is a no-op on an already-resolved claim" do
      claim = game.try_claim!(player)
      claim.submit!(valid_set_ids)
      board_after = game.reload.board.dup
      described_class.new.perform(claim)
      expect(claim.reload).to be_correct
      expect(game.reload.board).to eq(board_after)
    end
  end

  describe "job enqueuing" do
    it "enqueues ExpireClaimJob with 5s delay when a claim is created" do
      expect { game.try_claim!(player) }
        .to have_enqueued_job(ExpireClaimJob)
        .with(be_a(Claim))
    end
  end
end
