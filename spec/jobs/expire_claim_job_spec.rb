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
      claim.pick!(valid_set_ids)
      claim.expire!
      board_after = game.reload.board.dup
      described_class.new.perform(claim)
      expect(claim.reload).to be_correct
      expect(game.reload.board).to eq(board_after)
    end
  end

  describe "judging the picks" do
    def non_set_ids
      game.board_cards.combination(3).find { |trio| !Card.valid_set?(*trio) }.map(&:id)
    end

    it "resolves three picks that form a Set as correct" do
      claim = game.try_claim!(player)
      ids = valid_set_ids
      claim.pick!(ids)
      described_class.new.perform(claim)

      expect(claim.reload).to be_correct
      expect(player.reload.score).to eq(1)
      expect(game.reload.board).not_to include(*ids)
      expect(game.board.size).to eq(12)
      expect(game.last_dealt).to eq([12, 13, 14])
      expect(game.flash_claim_id).to eq(claim.id)
    end

    it "ends a quick game when the Set reaches the winning score" do
      game.update!(mode: :quick)
      player.update!(score: Game::QUICK_WIN_SCORE - 1)
      claim = game.try_claim!(player)
      claim.pick!(valid_set_ids)
      described_class.new.perform(claim)
      expect(game.reload).to be_ended
    end

    it "resolves three picks that do not form a Set as wrong" do
      player.update!(score: 2)
      claim = game.try_claim!(player)
      claim.pick!(non_set_ids)

      expect { described_class.new.perform(claim) }.to have_enqueued_job(UnlockBroadcastJob)
      expect(claim.reload).to be_wrong
      expect(player.reload.score).to eq(1)
      expect(player).to be_locked
      expect(game.reload.flash_claim_id).to eq(claim.id)
    end

    it "expires fewer than three picks and keeps them" do
      player.update!(score: 2)
      claim = game.try_claim!(player)
      claim.pick!([0, 4])
      described_class.new.perform(claim)

      expect(claim.reload).to be_expired
      expect(claim.card_ids).to eq([0, 4])
      expect(player.reload.score).to eq(1)
      expect(player).to be_locked
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
