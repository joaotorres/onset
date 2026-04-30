class AddGameStateToGames < ActiveRecord::Migration[8.1]
  def change
    add_column :games, :status, :integer, default: 0, null: false
    add_column :games, :deck, :json, default: []
    add_column :games, :board, :json, default: []
    add_column :games, :discard, :json, default: []
  end
end
