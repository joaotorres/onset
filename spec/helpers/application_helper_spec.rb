require "rails_helper"

RSpec.describe ApplicationHelper do
  describe "#stream_version" do
    let(:game) { Game.create! }
    let(:player) { game.players.create!(name: "Alice", color: "#648FFF") }

    def micros(time) = (time.to_r * 1_000_000).to_i

    it "is the game's updated_at in integer microseconds" do
      expect(helper.stream_version(game)).to eq(micros(game.updated_at))
      expect(helper.stream_version(game)).to be_an(Integer)
    end

    it "is the newer of the records given, in any order" do
      game.update_columns(updated_at: Time.zone.parse("2026-10-22 10:00:00.123456"))
      player.update_columns(updated_at: Time.zone.parse("2026-10-22 10:00:01.654321"))
      expect(helper.stream_version(game, player)).to eq(micros(player.updated_at))
      expect(helper.stream_version(player, game)).to eq(micros(player.updated_at))
    end
  end
end
