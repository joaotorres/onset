# Drops the arrive outline once it has faded, so later board re-renders
# don't replay it.
class ClearLastDealtJob < ApplicationJob
  queue_as :default

  def perform(game, dealt_ids)
    game.with_lock do
      game.update!(last_dealt: []) if game.last_dealt == dealt_ids
    end
  end
end
