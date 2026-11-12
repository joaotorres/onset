require "rails_helper"

RSpec.describe "Players" do
  include_context "players"

  describe "GET /games/:code/players/new" do
    it "selects the first free color" do
      game.players.create!(name: "a", color: presets[0])
      get new_game_player_path(game.code)
      expect(checked_colors).to eq([presets[1]])
    end
  end
end
