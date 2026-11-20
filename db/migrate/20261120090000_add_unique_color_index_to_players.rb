class AddUniqueColorIndexToPlayers < ActiveRecord::Migration[8.1]
  def change
    add_index :players, [:game_id, :color], unique: true
  end
end
