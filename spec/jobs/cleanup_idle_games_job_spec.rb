require "rails_helper"

RSpec.describe CleanupIdleGamesJob do
  def game_with_claim
    game = Game.create!
    player = game.players.create!(name: "Alice", color: "#E74C3C")
    game.claims.create!(player: player, started_at: Time.current)
    game
  end

  it "deletes a game idle for over 24 hours with its players and claims" do
    stale = game_with_claim
    stale.update_column(:updated_at, 25.hours.ago)

    described_class.perform_now

    expect(Game.exists?(stale.id)).to be false
    expect(Player.where(game_id: stale.id)).to be_empty
    expect(Claim.where(game_id: stale.id)).to be_empty
  end

  it "keeps a recently active game" do
    recent = game_with_claim
    recent.update_column(:updated_at, 23.hours.ago)

    described_class.perform_now

    expect(Game.exists?(recent.id)).to be true
    expect(recent.players.count).to eq 1
  end
end
