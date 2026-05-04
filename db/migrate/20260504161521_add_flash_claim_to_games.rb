class AddFlashClaimToGames < ActiveRecord::Migration[8.1]
  def change
    add_column :games, :flash_claim_id, :bigint
  end
end
