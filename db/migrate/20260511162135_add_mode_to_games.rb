class AddModeToGames < ActiveRecord::Migration[8.1]
  def change
    add_column :games, :mode, :integer, default: 0, null: false
  end
end
