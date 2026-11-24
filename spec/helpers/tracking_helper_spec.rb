require "rails_helper"

RSpec.describe TrackingHelper do
  let(:game) { Game.create!(mode: :quick) }
  let!(:alice) { create_player(game, name: "Alice") }
  let!(:bob) { create_player(game, name: "Bob") }

  def props = JSON.parse(helper.game_events_tag(game.reload, alice)[/data-game-events-props-value="([^"]*)"/, 1].gsub("&quot;", '"'))

  it "names the end of a quick game won at #{Game::QUICK_WIN_SCORE} points" do
    alice.update!(score: Game::QUICK_WIN_SCORE)
    game.update!(status: :ended)
    expect(props).to eq("mode" => "quick", "player_count" => 2, "bot_count" => 0, "end_reason" => "quick_win", "is_tie" => false)
  end

  it "counts the bots among the players, waiting, playing and ended" do
    game.add_bot!("easy")
    game.add_bot!("hard")
    expect(props).to eq("mode" => "quick", "player_count" => 4, "bot_count" => 2)
    game.start!
    expect(props).to include("player_count" => 4, "bot_count" => 2)
    game.update!(status: :ended)
    expect(props).to include("player_count" => 4, "bot_count" => 2)
  end

  it "makes the first person the reporter, never a bot first in join order" do
    room = Game.create!
    bot = room.add_bot!("easy")
    carol = room.players.create!(name: "Carol", color: "#2ECC71")
    dave = room.players.create!(name: "Dave", color: "#F1C40F")
    expect(room.standings.first).to eq(bot)
    expect(helper.game_events_tag(room, carol)).to include('data-game-events-reporter-value="true"')
    expect(helper.game_events_tag(room, dave)).to include('data-game-events-reporter-value="false"')
  end

  it "keeps a person the reporter when a bot leads the standings" do
    bot = game.add_bot!("hard")
    bot.update!(score: 3)
    expect(helper.game_events_tag(game, alice)).to include('data-game-events-reporter-value="true"')
  end

  it "names the end every active player voted for" do
    [alice, bob].each(&:seen!)
    game.update!(mode: :standard, status: :ended, end_game_voters: [alice.id, bob.id])
    expect(props).to include("end_reason" => "vote", "is_tie" => true)
  end

  it "names any other end the deck running out" do
    game.update!(mode: :standard, status: :ended, end_game_voters: [alice.id])
    expect(props).to include("end_reason" => "deck_exhausted")
  end

  it "makes only the player at the top of the standings the reporter" do
    bob.update!(score: 2)
    expect(helper.game_events_tag(game, bob)).to include('data-game-events-reporter-value="true"')
    expect(helper.game_events_tag(game, alice)).to include('data-game-events-reporter-value="false"')
  end
end
