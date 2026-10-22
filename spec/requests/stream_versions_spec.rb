require "rails_helper"

# SPEC.md §7, Screens ignore broadcasts older than what they show.
RSpec.describe "Stream versions on the hook roots" do
  include ApplicationHelper

  let(:game) { Game.create! }

  def version_of(id)
    Nokogiri::HTML(response.body).at_css("##{id}")&.[]("data-version")
  end

  it "stamps the big screen's roots, the game-only ones with the game's version" do
    game.players.create!(name: "Alice", color: "#648FFF")
    game.players.create!(name: "Bob", color: "#FE6100")
    get game_path(game.code)
    game.reload

    %w[board start_button announcement room_tile].each do |id|
      expect(version_of(id)).to eq(stream_version(game).to_s), "##{id}"
    end
    expect(version_of("scoreboard")).to eq(stream_version(game, *game.players).to_s)
  end

  it "stamps the player screen's controller_status" do
    post game_players_path(game.code), params: {player: {name: "Alice", color: "#648FFF"}}
    player = game.reload.players.find_by!(name: "Alice")
    get game_controller_path(game.code)
    expect(version_of("controller_status")).to eq(stream_version(game, player).to_s)
  end
end
