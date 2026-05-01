class ExpireNoSetJob < ApplicationJob
  queue_as :default

  def perform(game)
    game.with_lock do
      return unless game.reload.no_set_active?
      game.resolve_no_set!
    end
  end
end
