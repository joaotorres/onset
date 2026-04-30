require "rails_helper"

RSpec.describe Game do
  describe "code generation" do
    it "generates a code on create" do
      game = Game.create!
      expect(game.code).to be_present
    end

    it "generates a code matching the allowed format" do
      game = Game.create!
      expect(game.code).to match(Game::CODE_FORMAT)
    end

    it "generates a 6-character code" do
      game = Game.create!
      expect(game.code.length).to eq(6)
    end

    it "never generates a code with confusable glyphs (0, O, 1, I)" do
      50.times do
        game = Game.create!
        expect(game.code).not_to match(/[01OI]/)
      end
    end

    it "does not overwrite a code that was explicitly set" do
      game = Game.create!(code: "ABC234")
      expect(game.code).to eq("ABC234")
    end
  end

  describe "validations" do
    it "is invalid without a code" do
      game = Game.create!
      game.code = nil
      expect(game).not_to be_valid
    end

    it "is invalid with a duplicate code" do
      Game.create!(code: "AAA222")
      duplicate = Game.new(code: "AAA222")
      expect(duplicate).not_to be_valid
    end

    it "is invalid when code contains a confusable glyph" do
      expect(Game.new(code: "AAAA01")).not_to be_valid
      expect(Game.new(code: "AAAOOI")).not_to be_valid
    end

    it "is invalid when code is not 6 characters" do
      expect(Game.new(code: "AAA22")).not_to be_valid
      expect(Game.new(code: "AAA2222")).not_to be_valid
    end
  end

  describe "uniqueness by construction" do
    it "generates distinct codes for concurrent creates" do
      games = 10.times.map { Game.create! }
      expect(games.map(&:code).uniq.size).to eq(10)
    end
  end

  describe "#start!" do
    let(:game) { Game.create! }

    it "sets status to playing" do
      game.start!
      expect(game.reload).to be_playing
    end

    it "puts 12 cards on the board" do
      game.start!
      expect(game.reload.board.size).to eq(12)
    end

    it "puts the remaining 69 cards in the deck" do
      game.start!
      expect(game.reload.deck.size).to eq(69)
    end

    it "uses all 81 unique card ids across board and deck" do
      game.start!
      game.reload
      expect((game.board + game.deck).sort).to eq((0..80).to_a)
    end

    it "sets discard to empty" do
      game.start!
      expect(game.reload.discard).to be_empty
    end

    it "shuffles differently each time" do
      game.start!
      first_board = game.board.dup
      game2 = Game.create!
      game2.start!
      expect(game2.board).not_to eq(first_board)
    end
  end

  describe "#board_cards" do
    it "returns Card objects for each board id" do
      game = Game.create!
      game.start!
      cards = game.board_cards
      expect(cards.size).to eq(12)
      expect(cards).to all(be_a(Card))
      expect(cards.map(&:id)).to eq(game.board)
    end
  end
end
