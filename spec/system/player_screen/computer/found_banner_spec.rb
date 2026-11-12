require "rails_helper"

RSpec.describe "Player screen during play, computer", type: :system do
  include_context "player screen"

  context "with 8 players and 18 cards" do
    include_context "player screen with 8 players and 18 cards", 1024, 640

    include_examples "fits the computer screen", "found-set banner"

    it "lays the found-set banner over the top of the board area" do
      play_state("found-set banner")
      visit game_controller_path(game.code)
      banner = rect("[data-found-banner]")
      board = rect("[data-board]")
      scores = rect("[data-scoreboard]")
      expect(banner["left"]).to be_within(2).of(board["left"])
      expect(banner["right"]).to be <= scores["left"]
      expect(banner["top"]).to be_within(16).of(board["top"])
    end
  end
end
