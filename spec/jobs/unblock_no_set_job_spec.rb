require "rails_helper"

RSpec.describe UnblockNoSetJob do
  include ActiveSupport::Testing::Assertions
  include Turbo::Broadcastable::TestHelper

  let(:game) {
    Game.create!.tap { |g| g.update!(status: :playing, board: (0..11).to_a, deck: (12..80).to_a, discard: []) }
  }
  let!(:alice) { game.players.create!(name: "Alice", color: "#648FFF", last_seen_at: Time.current) }
  let!(:bob) { game.players.create!(name: "Bob", color: "#FE6100", last_seen_at: Time.current) }

  describe "#perform" do
    it "broadcasts the announcement to the game and controller_status to each player" do
      game.update!(no_set_refuser_id: bob.id, no_set_refused_at: (Game::NO_SET_TIMEOUT + 1).seconds.ago)
      alice_streams = bob_streams = nil
      game_streams = capture_turbo_stream_broadcasts("game:#{game.code}") do
        alice_streams = capture_turbo_stream_broadcasts("player:#{alice.id}") do
          bob_streams = capture_turbo_stream_broadcasts("player:#{bob.id}") { described_class.new.perform(game) }
        end
      end

      announcement = game_streams.find { |s| s["target"] == "announcement" }
      expect(announcement).to be_present
      expect(announcement.to_html).to include("Spot a Set?")
      [alice_streams, bob_streams].each do |streams|
        expect(streams.map { |s| s["target"] }).to include("controller_status")
      end
    end
  end
end
