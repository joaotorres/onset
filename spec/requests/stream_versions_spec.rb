require "rails_helper"

# SPEC.md §7, Screens ignore broadcasts older than what they show.
RSpec.describe "Stream versions on the hook roots" do
  include ApplicationHelper

  let(:game) { Game.create! }

  def version_of(id)
    Nokogiri::HTML(response.body).at_css("##{id}")&.[]("data-version")
  end

  it "stamps the waiting board, start button and room tile with the room's players' version, the game-only roots with the game's" do
    create_player(game, name: "Alice")
    create_player(game, name: "Bob")
    get game_path(game.code)
    game.reload
    room = stream_version(game, *game.players)
    expect(room).to be > stream_version(game)

    # The waiting room tile holds the add-bot control, which a join can disable.
    %w[board start_button scoreboard room_tile].each do |id|
      expect(version_of(id)).to eq(room.to_s), "##{id}"
    end
    expect(version_of("announcement")).to eq(stream_version(game).to_s)
  end

  it "stamps the playing board and room tile with the game's version even when players were written later" do
    create_player(game, name: "Alice")
    create_player(game, name: "Bob")
    game.start!
    game.players.each(&:touch)
    get game_path(game.code)
    game.reload
    expect(stream_version(game, *game.players)).to be > stream_version(game)

    expect(version_of("board")).to eq(stream_version(game).to_s)
    expect(version_of("room_tile")).to eq(stream_version(game).to_s)
  end

  it "stamps the player screen's controller_status with the room's players' version" do
    post game_players_path(game.code), params: {player: {name: "Alice", color: "#E74C3C"}}
    alice = game.reload.players.find_by!(name: "Alice")
    bob = create_player(game, name: "Bob")
    get game_controller_path(game.code)
    game.reload

    expect(version_of("controller_status")).to eq(stream_version(game, *game.players).to_s)
    expect(version_of("controller_status")).to eq(stream_version(bob).to_s)
    expect(version_of("controller_status").to_i).to be > stream_version(game, alice)
  end
end
