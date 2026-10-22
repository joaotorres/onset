require "rails_helper"

RSpec.describe UnlockBroadcastJob do
  include ActiveSupport::Testing::Assertions
  include Turbo::Broadcastable::TestHelper

  let(:game) {
    Game.create!.tap { |g| g.update!(status: :playing, board: (0..11).to_a, deck: (12..80).to_a, discard: []) }
  }
  let!(:alice) { game.players.create!(name: "Alice", color: "#648FFF", last_seen_at: Time.current) }
  let!(:bob) { game.players.create!(name: "Bob", color: "#FE6100", last_seen_at: Time.current) }

  def version(html) = html[/data-version="(\d+)"/, 1]

  describe "#perform" do
    # §7: the job rebroadcasts because time passed, with no write, so its version equals the page's and renders.
    it "broadcasts scoreboard and controller_status at the version the page already shows" do
      alice.update!(locked_until: 1.second.ago)
      game.reload
      page_scoreboard = ApplicationController.render(partial: "games/scoreboard", locals: {game: game})
      page_status = ApplicationController.render(partial: "players/controller_status", locals: {player: alice.reload, game: game})

      status_streams = nil
      game_streams = capture_turbo_stream_broadcasts("game:#{game.code}") do
        status_streams = capture_turbo_stream_broadcasts("player:#{alice.id}") { described_class.new.perform(alice) }
      end

      scoreboard = game_streams.find { |s| s["target"] == "scoreboard" }
      status = status_streams.find { |s| s["target"] == "controller_status" }
      expect(version(page_scoreboard)).to be_present
      expect(version(scoreboard.to_html)).to eq(version(page_scoreboard))
      expect(version(status.to_html)).to eq(version(page_status))
    end
  end
end
