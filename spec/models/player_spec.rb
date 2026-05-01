require "rails_helper"

RSpec.describe Player do
  let(:game) { Game.create! }
  let(:valid_attrs) { {game: game, name: "Alice", color: "#648FFF"} }

  describe "session token generation" do
    it "generates a session token on create" do
      player = Player.create!(valid_attrs)
      expect(player.session_token).to be_present
    end

    it "generates unique session tokens" do
      p1 = Player.create!(valid_attrs)
      p2 = Player.create!(valid_attrs.merge(name: "Bob", color: "#2ECC71"))
      expect(p1.session_token).not_to eq(p2.session_token)
    end
  end

  describe "name validations" do
    it "is invalid without a name" do
      expect(Player.new(valid_attrs.merge(name: ""))).not_to be_valid
    end

    it "is invalid with a name longer than 20 characters" do
      expect(Player.new(valid_attrs.merge(name: "A" * 21))).not_to be_valid
    end

    it "is valid with a name of exactly 20 characters" do
      expect(Player.new(valid_attrs.merge(name: "A" * 20))).to be_valid
    end

    it "rejects a duplicate name in the same game (case-insensitive)" do
      Player.create!(valid_attrs)
      expect(Player.new(valid_attrs.merge(name: "alice"))).not_to be_valid
      expect(Player.new(valid_attrs.merge(name: "ALICE"))).not_to be_valid
    end

    it "allows the same name in different games" do
      Player.create!(valid_attrs)
      other_game = Game.create!
      expect(Player.new(valid_attrs.merge(game: other_game))).to be_valid
    end
  end

  describe "color validations" do
    it "is invalid without a color" do
      expect(Player.new(valid_attrs.merge(color: ""))).not_to be_valid
    end

    it "is invalid with a non-hex color" do
      expect(Player.new(valid_attrs.merge(color: "blue"))).not_to be_valid
      expect(Player.new(valid_attrs.merge(color: "#GGGGGG"))).not_to be_valid
    end

    it "is valid with a lowercase hex color" do
      expect(Player.new(valid_attrs.merge(color: "#fe6100"))).to be_valid
    end

    it "rejects a duplicate color in the same game" do
      Player.create!(valid_attrs)
      expect(Player.new(valid_attrs.merge(name: "Bob"))).not_to be_valid
    end

    it "allows the same color in different games" do
      Player.create!(valid_attrs)
      other_game = Game.create!
      expect(Player.new(valid_attrs.merge(game: other_game))).to be_valid
    end
  end

  describe "#active?" do
    it "returns true when last_seen_at is within 30 seconds" do
      player = Player.new(valid_attrs.merge(last_seen_at: 10.seconds.ago))
      expect(player.active?).to be true
    end

    it "returns false when last_seen_at is older than 30 seconds" do
      player = Player.new(valid_attrs.merge(last_seen_at: 31.seconds.ago))
      expect(player.active?).to be false
    end

    it "returns false when last_seen_at is nil" do
      player = Player.new(valid_attrs)
      expect(player.active?).to be false
    end
  end

  describe "#host?" do
    it "returns true when the player is the game's host" do
      player = Player.create!(valid_attrs)
      game.update!(host_player_id: player.id)
      expect(player.host?).to be true
    end

    it "returns false when the player is not the host" do
      player = Player.create!(valid_attrs)
      other = Player.create!(valid_attrs.merge(name: "Bob", color: "#2ECC71"))
      game.update!(host_player_id: other.id)
      expect(player.host?).to be false
    end
  end
end
