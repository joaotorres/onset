class AddNoSetFieldsToGames < ActiveRecord::Migration[8.1]
  def change
    add_column :games, :no_set_caller_id, :integer
    add_column :games, :no_set_started_at, :datetime
    add_column :games, :no_set_voters, :json, default: []
  end
end
