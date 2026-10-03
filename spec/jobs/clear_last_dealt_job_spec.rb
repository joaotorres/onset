require "rails_helper"

RSpec.describe ClearLastDealtJob do
  let(:game) { Game.create!.tap { it.update!(status: :playing, last_dealt: [1, 2, 3]) } }

  it "clears the outline for the deal it was scheduled for" do
    described_class.perform_now(game, [1, 2, 3])
    expect(game.reload.last_dealt).to eq([])
  end

  it "leaves a newer deal alone" do
    described_class.perform_now(game, [7, 8, 9])
    expect(game.reload.last_dealt).to eq([1, 2, 3])
  end
end
