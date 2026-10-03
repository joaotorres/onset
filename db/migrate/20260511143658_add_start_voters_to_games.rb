class AddStartVotersToGames < ActiveRecord::Migration[8.1]
  def change
    add_column :games, :start_voters, :json, default: []
  end
end
