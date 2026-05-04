class ClearClaimFlashJob < ApplicationJob
  queue_as :default

  def perform(claim)
    game = claim.game
    game.with_lock do
      game.update!(flash_claim_id: nil) if game.flash_claim_id == claim.id
    end
  end
end
