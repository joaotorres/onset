require "rails_helper"

RSpec.describe Claim do
  include ActiveSupport::Testing::TimeHelpers

  let(:game) {
    Game.create!.tap { |g| g.update!(status: :playing, board: (0..11).to_a, deck: (12..80).to_a, discard: []) }
  }
  let(:player) { game.players.create!(name: "Alice", color: "#E74C3C") }
  let(:claim) { game.try_claim!(player) }

  # Find a valid set on the board so tests are deterministic
  def find_set_on_board
    game.board_cards.combination(3).find { |trio| Card.valid_set?(*trio) }.map(&:id)
  end

  def find_non_set_on_board
    game.board_cards.combination(3).find { |trio| !Card.valid_set?(*trio) }.map(&:id)
  end

  # The claim is judged when its time runs out (§11): pick, then expire.
  def judge(ids)
    claim.pick!(ids)
    claim.expire!
  end

  describe "#expire! on three picks that form a Set" do
    it "marks the claim as correct" do
      judge(find_set_on_board)
      expect(claim.reload).to be_correct
    end

    it "increments the player score by 1" do
      expect { judge(find_set_on_board) }
        .to change { player.reload.score }.by(1)
    end

    it "removes the 3 cards from the board" do
      ids = find_set_on_board
      judge(ids)
      expect(game.reload.board).not_to include(*ids)
    end

    it "deals replacement cards so the board stays at 12" do
      judge(find_set_on_board)
      expect(game.reload.board.size).to eq(12)
    end

    it "records the replacement cards as just dealt" do
      judge(find_set_on_board)
      expect(game.reload.last_dealt).to eq([12, 13, 14])
    end

    it "deals nothing new when the board had more than 12 cards" do
      game.update!(board: (0..14).to_a, deck: (15..80).to_a)
      judge(find_set_on_board)
      expect(game.reload.last_dealt).to eq([])
    end

    it "moves submitted cards to discard" do
      ids = find_set_on_board
      judge(ids)
      expect(game.reload.discard).to include(*ids)
    end

    it "releases the claim lock on the game" do
      judge(find_set_on_board)
      expect(game.reload.claim_player_id).to be_nil
    end
  end

  describe "#expire! on three picks that do not form a Set" do
    it "marks the claim as wrong" do
      judge(find_non_set_on_board)
      expect(claim.reload).to be_wrong
    end

    it "decrements the player score by 1" do
      player.update!(score: 3)
      expect { judge(find_non_set_on_board) }
        .to change { player.reload.score }.by(-1)
    end

    it "does not reduce score below zero" do
      player.update!(score: 0)
      judge(find_non_set_on_board)
      expect(player.reload.score).to eq(0)
    end

    it "locks the player out for the claim time" do
      freeze_time
      expect { judge(find_non_set_on_board) }.to have_enqueued_job(UnlockBroadcastJob)
        .with(player).at(Game::CLAIM_TIMEOUT.seconds.from_now)
      expect(player.reload).to be_locked
      expect(player.locked_until).to eq(Game::CLAIM_TIMEOUT.seconds.from_now)
    end

    it "does not change the board" do
      board_before = game.board.dup
      judge(find_non_set_on_board)
      expect(game.reload.board).to eq(board_before)
    end

    it "releases the claim lock on the game" do
      judge(find_non_set_on_board)
      expect(game.reload.claim_player_id).to be_nil
    end
  end

  describe "#expire! on fewer than three picks" do
    it "marks the claim as expired" do
      claim.expire!
      expect(claim.reload).to be_expired
    end

    it "decrements the player score by 1" do
      player.update!(score: 3)
      expect { claim.expire! }.to change { player.reload.score }.by(-1)
    end

    it "does not reduce score below zero" do
      player.update!(score: 0)
      claim.expire!
      expect(player.reload.score).to eq(0)
    end

    it "locks the player out for the claim time" do
      claim
      freeze_time
      expect { claim.expire! }.to have_enqueued_job(UnlockBroadcastJob)
        .with(player).at(Game::CLAIM_TIMEOUT.seconds.from_now)
      expect(player.reload).to be_locked
      expect(player.locked_until).to eq(Game::CLAIM_TIMEOUT.seconds.from_now)
    end

    it "releases the claim lock on the game" do
      claim.expire!
      expect(game.reload.claim_player_id).to be_nil
      expect(game.reload.claim_started_at).to be_nil
    end

    it "does not change the board" do
      board_before = game.board.dup
      claim.expire!
      expect(game.reload.board).to eq(board_before)
    end
  end

  describe "penalty in the announcement" do
    def announcement_for(claim)
      ApplicationController.render(partial: "games/announcement", locals: {game: game.reload, flash_claim: claim.reload})
    end

    it "is not shown for a wrong claim at score 0" do
      player.update!(score: 0)
      judge(find_non_set_on_board)
      expect(claim.reload).not_to be_penalized
      expect(announcement_for(claim)).not_to include("−1")
    end

    it "is shown for a wrong claim at score 2" do
      player.update!(score: 2)
      judge(find_non_set_on_board)
      expect(claim.reload).to be_penalized
      expect(announcement_for(claim)).to include("−1")
    end

    it "is not shown for a timeout at score 0" do
      player.update!(score: 0)
      claim.expire!
      expect(claim.reload).not_to be_penalized
      expect(announcement_for(claim)).not_to include("−1")
    end
  end

  describe "#expire! on a Set in quick mode" do
    let(:game) {
      Game.create!(mode: :quick).tap { |g| g.update!(status: :playing, board: (0..11).to_a, deck: (12..80).to_a, discard: []) }
    }

    it "ends the game when a player reaches 5 points" do
      player.update!(score: 4)
      judge(find_set_on_board)
      expect(game.reload).to be_ended
    end

    it "does not end the game if the player has fewer than 5 points" do
      player.update!(score: 2)
      judge(find_set_on_board)
      expect(game.reload).to be_playing
    end
  end

  describe "#pick!" do
    it "stores one or two picks and leaves the claim pending" do
      claim.pick!([0])
      expect(claim.reload.card_ids).to eq([0])
      claim.pick!([0, 5])
      expect(claim.reload.card_ids).to eq([0, 5])
      expect(claim).to be_pending
    end

    it "stores three picks that form a Set without judging them" do
      ids = find_set_on_board
      expect { claim.pick!(ids) }.not_to change { player.reload.score }
      expect(claim.reload).to be_pending
      expect(claim.card_ids).to eq(ids)
      expect(claim.resolved_at).to be_nil
      expect(game.reload.board).to eq((0..11).to_a)
    end

    it "replaces the picks, so an unpick shrinks them" do
      claim.pick!([0, 1, 2])
      claim.pick!([0, 2])
      expect(claim.reload.card_ids).to eq([0, 2])
    end

    it "ignores a card not on the board" do
      claim.pick!([0])
      expect { claim.pick!([0, 50]) }.not_to change { claim.reload.card_ids }
    end

    it "ignores a duplicate" do
      claim.pick!([0])
      expect { claim.pick!([0, 0]) }.not_to change { claim.reload.card_ids }
    end

    it "ignores more than three cards" do
      claim.pick!([0])
      expect { claim.pick!([0, 1, 2, 3]) }.not_to change { claim.reload.card_ids }
    end

    it "is a no-op on an already-resolved claim" do
      judge(find_set_on_board)
      expect { claim.pick!([3]) }.not_to change { claim.reload.card_ids }
    end
  end

  describe "#expire! judging the picks it finds" do
    it "sets the flash on a correct Set" do
      judge(find_set_on_board)
      expect(game.reload.flash_claim_id).to eq(claim.id)
    end

    it "sets the flash and schedules the unlock broadcast on a wrong Set" do
      expect { judge(find_non_set_on_board) }.to have_enqueued_job(UnlockBroadcastJob)
      expect(game.reload.flash_claim_id).to eq(claim.id)
      expect(player.reload.locked_until).to be_within(1.second).of(Game::CLAIM_TIMEOUT.seconds.from_now)
    end

    it "keeps fewer than three picks on an expired claim" do
      judge([0, 4])
      expect(claim.reload).to be_expired
      expect(claim.card_ids).to eq([0, 4])
    end
  end

  describe "card_ids validation" do
    def claim_with(result, ids)
      game.claims.new(player: player, result: result, card_ids: ids, started_at: Time.current)
    end

    it "accepts one or two picks while pending or expired" do
      expect(claim_with(:pending, [0])).to be_valid
      expect(claim_with(:pending, [0, 1])).to be_valid
      expect(claim_with(:expired, [0, 1])).to be_valid
    end

    it "requires exactly three once correct or wrong" do
      expect(claim_with(:correct, [0, 1])).not_to be_valid
      expect(claim_with(:wrong, [0])).not_to be_valid
      expect(claim_with(:wrong, [0, 1, 3])).to be_valid
    end

    it "rejects duplicates, ids outside 0..80 and more than three" do
      expect(claim_with(:pending, [0, 0])).not_to be_valid
      expect(claim_with(:pending, [81])).not_to be_valid
      expect(claim_with(:pending, [0, 1, 2, 3])).not_to be_valid
    end
  end
end
