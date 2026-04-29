require "rails_helper"

RSpec.describe Card do
  def card(id) = Card.new(id)

  describe ".deck" do
    it "returns 81 cards covering ids 0 through 80" do
      expect(Card.deck.map(&:id)).to eq((0..80).to_a)
    end
  end

  describe "attribute decoding" do
    # id = number*27 + color*9 + shape*3 + shading
    it "decodes all four attributes from id 40 → (1,1,1,1)" do
      c = card(40)
      expect(c.number).to eq(1)
      expect(c.color).to eq(1)
      expect(c.shape).to eq(1)
      expect(c.shading).to eq(1)
    end

    it "extracts number from the most-significant base-3 digit" do
      expect(card(0).number).to eq(0)
      expect(card(27).number).to eq(1)
      expect(card(54).number).to eq(2)
    end

    it "extracts shading from the least-significant base-3 digit" do
      expect(card(0).shading).to eq(0)
      expect(card(1).shading).to eq(1)
      expect(card(2).shading).to eq(2)
    end
  end

  describe ".valid_set?" do
    it "accepts all-same in three attributes, all-different in one" do
      # ids 0,1,2 → (0,0,0,0),(0,0,0,1),(0,0,0,2) — same number/color/shape, all-diff shading
      expect(Card.valid_set?(card(0), card(1), card(2))).to be true
    end

    it "accepts all-different across all four attributes" do
      # ids 0,40,80 → (0,0,0,0),(1,1,1,1),(2,2,2,2)
      expect(Card.valid_set?(card(0), card(40), card(80))).to be true
    end

    it "accepts all-same number, all-different in the remaining attributes" do
      # ids 0,13,26 → (0,0,0,0),(0,1,1,1),(0,2,2,2)
      expect(Card.valid_set?(card(0), card(13), card(26))).to be true
    end

    it "rejects when one attribute has two-same, one-different" do
      # ids 0,1,3 → (0,0,0,0),(0,0,0,1),(0,0,1,0) — shape is 0,0,1: not all-same or all-diff
      expect(Card.valid_set?(card(0), card(1), card(3))).to be false
    end

    it "rejects when one attribute has two-same, one-different (second example)" do
      # ids 0,27,28 → (0,0,0,0),(1,0,0,0),(1,0,0,1) — number is 0,1,1: invalid
      expect(Card.valid_set?(card(0), card(27), card(28))).to be false
    end
  end

  describe "every pair of distinct cards has exactly one completion" do
    it "holds for all C(81,2) = 3240 pairs" do
      deck = Card.deck
      deck.combination(2).each do |a, b|
        completions = deck.count { |c| c.id != a.id && c.id != b.id && Card.valid_set?(a, b, c) }
        expect(completions).to eq(1), "pair (#{a.id}, #{b.id}) has #{completions} completions instead of 1"
      end
    end
  end

  describe ".any_set_on?" do
    it "returns true when the full deck is on the board" do
      expect(Card.any_set_on?(Card.deck)).to be true
    end

    it "returns false for a cap set" do
      # Greedy maximal cap set: add each card (in id order) only if it creates no Set with existing pairs.
      # In AG(4,3) the maximum cap has 20 elements; this greedy finds it deterministically.
      cap_set = Card.deck.each_with_object([]) do |c, cap|
        cap << c unless cap.combination(2).any? { |a, b| Card.valid_set?(a, b, c) }
      end
      expect(Card.any_set_on?(cap_set)).to be false
    end
  end
end
