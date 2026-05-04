class UnlockBroadcastJob < ApplicationJob
  queue_as :default

  def perform(player)
    player.reload
    player.broadcast_controller_status
  end
end
