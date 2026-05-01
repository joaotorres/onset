require "rails_helper"

RSpec.describe ExpireNoSetJob do
  let(:game) {
    Game.create!.tap { |g| g.update!(status: :playing, board: (0..11).to_a, deck: (12..80).to_a, discard: []) }
  }
  let(:player) { game.players.create!(name: "Alice", color: "#648FFF", last_seen_at: Time.current) }

  describe "#perform" do
    it "deals 3 cards and clears no_set fields" do
      game.call_no_set!(player)
      described_class.new.perform(game)
      game.reload
      expect(game.board.size).to eq(15)
      expect(game.no_set_active?).to be false
    end

    it "is a no-op when no_set is no longer active" do
      game.call_no_set!(player)
      game.cancel_no_set!
      board_before = game.reload.board.dup
      described_class.new.perform(game)
      expect(game.reload.board).to eq(board_before)
    end
  end

  describe "job enqueuing" do
    it "enqueues ExpireNoSetJob with 15s delay when No-Set is called" do
      expect { game.call_no_set!(player) }
        .to have_enqueued_job(ExpireNoSetJob)
        .with(game)
    end
  end
end
