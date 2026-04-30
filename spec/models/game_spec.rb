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
end
