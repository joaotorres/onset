require "rails_helper"

RSpec.describe Claim do
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

  describe "#submit! with a correct Set" do
    it "marks the claim as correct" do
      claim.submit!(find_set_on_board)
      expect(claim.reload).to be_correct
    end

    it "increments the player score by 1" do
      expect { claim.submit!(find_set_on_board) }
        .to change { player.reload.score }.by(1)
    end

    it "removes the 3 cards from the board" do
      ids = find_set_on_board
      claim.submit!(ids)
      expect(game.reload.board).not_to include(*ids)
    end

    it "deals replacement cards so the board stays at 12" do
      claim.submit!(find_set_on_board)
      expect(game.reload.board.size).to eq(12)
    end

    it "moves submitted cards to discard" do
      ids = find_set_on_board
      claim.submit!(ids)
      expect(game.reload.discard).to include(*ids)
    end

    it "releases the claim lock on the game" do
      claim.submit!(find_set_on_board)
      expect(game.reload.claim_player_id).to be_nil
    end
  end

  describe "#submit! with a wrong Set" do
    it "marks the claim as wrong" do
      claim.submit!(find_non_set_on_board)
      expect(claim.reload).to be_wrong
    end

    it "decrements the player score by 1" do
      expect { claim.submit!(find_non_set_on_board) }
        .to change { player.reload.score }.by(-1)
    end

    it "locks the player out for 5 seconds" do
      claim.submit!(find_non_set_on_board)
      expect(player.reload).to be_locked
    end

    it "does not change the board" do
      board_before = game.board.dup
      claim.submit!(find_non_set_on_board)
      expect(game.reload.board).to eq(board_before)
    end

    it "releases the claim lock on the game" do
      claim.submit!(find_non_set_on_board)
      expect(game.reload.claim_player_id).to be_nil
    end
  end

  describe "#submit! with invalid input" do
    it "ignores a submission with the wrong number of cards" do
      expect { claim.submit!([0, 1]) }.not_to change { claim.reload.result }
    end

    it "ignores a submission with cards not on the board" do
      off_board = (0..80).to_a - game.board
      expect { claim.submit!(off_board.first(3)) }.not_to change { claim.reload.result }
    end

    it "is a no-op on an already-resolved claim" do
      ids = find_set_on_board
      claim.submit!(ids)
      expect { claim.submit!(ids) }.not_to change { game.reload.board }
    end
  end
end
