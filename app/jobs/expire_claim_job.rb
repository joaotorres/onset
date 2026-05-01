class ExpireClaimJob < ApplicationJob
  queue_as :default

  def perform(claim)
    claim.game.with_lock do
      return unless claim.reload.pending?
      claim.expire!
    end
  end
end
