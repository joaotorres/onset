require "rails_helper"

RSpec.describe "Player screen during play, computer", type: :system do
  include_context "player screen"

  context "with 8 players and 18 cards" do
    include_context "player screen with 8 players and 18 cards", 1024, 640

    include_examples "fits the computer screen", "idle", "deck empty"

    it "shows the 108px SET! while idle" do
      visit game_controller_path(game.code)
      button = rect("[data-set-slot] button")
      expect(button["width"]).to be_within(1).of(108)
    end
  end
end
