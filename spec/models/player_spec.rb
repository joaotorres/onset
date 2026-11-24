require "rails_helper"

RSpec.describe Player do
  let(:game) { Game.create! }
  let(:valid_attrs) { {game: game, name: "Alice", color: "#E74C3C"} }

  describe "session token generation" do
    it "generates a session token on create" do
      player = create_player(game, name: "Alice")
      expect(player.session_token).to be_present
    end

    it "generates unique session tokens" do
      p1 = create_player(game, name: "Alice")
      p2 = create_player(game, name: "Bob")
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

    it "has the database refuse a case-variant name in one game" do
      Player.create!(valid_attrs)
      twin = Player.new(valid_attrs.merge(name: valid_attrs[:name].swapcase, color: "#2ECC71", session_token: "t2"))
      expect { twin.save!(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it "has the database accept the same name in two games" do
      Player.create!(valid_attrs)
      twin = Player.new(valid_attrs.merge(game: Game.create!, session_token: "t2"))
      expect { twin.save!(validate: false) }.not_to raise_error
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

    it "holds the 8 presets in order" do
      expect(Player::PRESET_COLORS).to eq(%w[#E74C3C #2ECC71 #F1C40F #9B59B6 #1ABC9C #E91E63 #00BCD4 #8BC34A])
    end

    it "refuses a well-formed color that is not a preset on create" do
      player = Player.new(valid_attrs.merge(color: "#FE6100"))
      expect(player).not_to be_valid
      expect(player.errors[:color]).to be_present
    end

    it "still saves an update to an existing row with a non-preset color" do
      player = Player.create!(valid_attrs)
      player.update_column(:color, "#FE6100")
      player = Player.find(player.id)
      expect(player.update(score: 3, locked_until: 5.seconds.from_now, last_seen_at: Time.current)).to be true
      expect(player.reload.score).to eq(3)
    end

    it "has the database refuse a second player with one color in a game" do
      Player.create!(valid_attrs)
      twin = Player.new(valid_attrs.merge(name: "Bob", session_token: "t2"))
      expect { twin.save!(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
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
      player = create_player(game, name: "Alice")
      game.update!(host_player_id: player.id)
      expect(player.host?).to be true
    end

    it "returns false when the player is not the host" do
      player = create_player(game, name: "Alice")
      other = create_player(game, name: "Bob")
      game.update!(host_player_id: other.id)
      expect(player.host?).to be false
    end
  end

  describe "#seen!" do
    let(:game) { Game.create! }
    let(:player) { create_player(game, name: "Alice") }

    it "records last_seen_at without broadcasting the controller" do
      player
      expect(player).not_to receive(:broadcast_controller_status)
      player.seen!
      expect(player.reload.last_seen_at).to be_within(2.seconds).of(Time.current)
    end
  end

  describe "#lockout_reason" do
    let(:game) { Game.create!.tap(&:start!) }
    let(:player) { create_player(game, name: "Alice") }

    it "is nil without a failed claim" do
      expect(player.lockout_reason).to be_nil
    end

    it "reports the most recent failed claim" do
      game.claims.create!(player: player, started_at: 2.minutes.ago, resolved_at: 2.minutes.ago, result: :wrong)
      game.claims.create!(player: player, started_at: 1.minute.ago, resolved_at: 1.minute.ago, result: :expired)
      expect(player.lockout_reason).to eq("expired")
    end
  end

  describe "broadcast versions (§7, Screens ignore broadcasts older than what they show)" do
    include ActiveSupport::Testing::Assertions
    include Turbo::Broadcastable::TestHelper

    def version(stream) = stream.to_html[/data-version="(\d+)"/, 1].to_i
    def micros(time) = (time.to_r * 1_000_000).to_i

    it "stamps a lockout's controller_status with the player's time, and the room's scoreboard after it" do
      game.update!(status: :playing, board: (0..11).to_a, deck: (12..80).to_a, discard: [])
      player = create_player(game, name: "Alice")
      game_version = micros(game.reload.updated_at)

      streams = capture_turbo_stream_broadcasts("player:#{player.id}") do
        player.update!(locked_until: 15.seconds.from_now)
      end
      status = streams.find { |s| s["target"] == "controller_status" }
      expect(micros(game.reload.updated_at)).to eq(game_version)
      expect(version(status)).to be > game_version

      scoreboard = capture_turbo_stream_broadcasts("game:#{game.code}") { game.broadcast_game_state }
        .find { |s| s["target"] == "scoreboard" }
      expect(version(scoreboard)).to eq(version(status))
    end
  end
end
