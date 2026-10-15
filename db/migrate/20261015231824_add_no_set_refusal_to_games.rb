class AddNoSetRefusalToGames < ActiveRecord::Migration[8.1]
  def change
    add_column :games, :no_set_refuser_id, :bigint
    add_column :games, :no_set_refused_at, :datetime
  end
end
