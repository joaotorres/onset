# Shared by the claim model, expire claim job and claims request specs.
# Each host defines `game` (playing, board 0..11) and `player`.

# The room ends with any claim still pending, then restarts on a known board.
RSpec.shared_context "restart with a known board" do
  def restart_with_known_board
    game.update!(status: :ended)
    game.restart!
    game.update!(board: (0..11).to_a, deck: (12..80).to_a)
  end
end

# §6 Key invariants: a claim is acted on only while it is the room's current
# claim. The host also defines `claim` and the shared examples named by
# `examples`, run in each situation, and "<examples> when superseded", run with
# `newer` in the last one.
RSpec.shared_context "a claim that is not the room's current one" do |examples|
  include_context "restart with a known board"

  def state
    game.reload
    [claim.reload.attributes, player.reload.score, player.locked_until,
      game.status, game.board, game.deck, game.discard, game.claim_player_id]
  end

  context "in an ended room" do
    before do
      player.update!(score: 2)
      claim
      game.update!(status: :ended)
    end

    include_examples examples
  end

  context "left from an earlier game" do
    before do
      claim
      restart_with_known_board
      player.update!(score: 2)
    end

    include_examples examples
  end

  context "superseded by its player's newer claim" do
    let!(:newer) do
      claim
      restart_with_known_board
      player.update!(score: 2)
      game.try_claim!(player)
    end

    include_examples examples
    include_examples "#{examples} when superseded"
  end
end
