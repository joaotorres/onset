class CleanupIdleGamesJob < ApplicationJob
  IDLE_AFTER = 24.hours

  # Every gameplay action goes through Game#update!, so updated_at tracks activity.
  def perform
    Game.where(updated_at: ...IDLE_AFTER.ago).find_each(&:destroy!)
  end
end
