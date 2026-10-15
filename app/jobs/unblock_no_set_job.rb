# The refusal's block is over (§12): rebroadcast so No Set comes back on every screen.
# The block itself is enforced by no_set_refused_at at call time.
class UnblockNoSetJob < ApplicationJob
  queue_as :default

  def perform(game)
    game.reload.broadcast_game_state
  end
end
