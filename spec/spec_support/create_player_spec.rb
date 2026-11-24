require "rails_helper"

# The spec helper in spec/support/create_player.rb.
RSpec.describe "create_player" do
  let(:game) { Game.create! }
  let(:presets) { Player::PRESET_COLORS }

  it "gives the first player the first preset and names it" do
    player = create_player(game)

    expect([player.color, player.name, player.game]).to eq([presets[0], "Player 1", game])
  end

  it "gives the next player the next preset" do
    create_player(game)

    expect([create_player(game).color, game.players.last.name]).to eq([presets[1], "Player 2"])
  end

  it "skips a taken first preset" do
    game.players.create!(name: "Ana", color: presets[0])

    expect(create_player(game).color).to eq(presets[1])
  end

  it "lets a passed color, name or other attribute win" do
    player = create_player(game, color: presets[3], name: "Bob", score: 4)

    expect([player.color, player.name, player.score]).to eq([presets[3], "Bob", 4])
  end

  it "raises in a full game" do
    presets.size.times { create_player(game) }

    expect { create_player(game) }.to raise_error(ActiveRecord::RecordInvalid)
  end
end
