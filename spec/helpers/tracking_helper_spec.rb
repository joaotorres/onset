require "rails_helper"

RSpec.describe TrackingHelper do
  let(:game) { Game.create!(mode: :quick) }
  let!(:alice) { game.players.create!(name: "Alice", color: "#E74C3C") }
  let!(:bob) { game.players.create!(name: "Bob", color: "#2ECC71") }

  def props = JSON.parse(helper.game_events_tag(game.reload, alice)[/data-game-events-props-value="([^"]*)"/, 1].gsub("&quot;", '"'))

  it "names the end of a quick game won at #{Game::QUICK_WIN_SCORE} points" do
    alice.update!(score: Game::QUICK_WIN_SCORE)
    game.update!(status: :ended)
    expect(props).to eq("mode" => "quick", "player_count" => 2, "end_reason" => "quick_win", "is_tie" => false)
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
