class AddLastDealtToGames < ActiveRecord::Migration[8.1]
  def change
    add_column :games, :last_dealt, :json, default: []
  end
end
