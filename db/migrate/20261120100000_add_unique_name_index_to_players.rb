class AddUniqueNameIndexToPlayers < ActiveRecord::Migration[8.1]
  def change
    add_index :players, "game_id, LOWER(name)", unique: true, name: "index_players_on_game_id_and_lower_name"
  end
end
