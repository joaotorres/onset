class AddEndGameVotersToGames < ActiveRecord::Migration[8.1]
  def change
    add_column :games, :end_game_voters, :json, default: []
  end
end
