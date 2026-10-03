class UnlockBroadcastJob < ApplicationJob
  queue_as :default

  def perform(player)
    player.reload
    player.broadcast_controller_status
    player.broadcast_replace_to "game:#{player.game.code}",
      target: "scoreboard",
      partial: "games/scoreboard",
      locals: {game: player.game}
  end
end
