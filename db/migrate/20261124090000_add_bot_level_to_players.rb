class AddBotLevelToPlayers < ActiveRecord::Migration[8.1]
  def change
    # Nil for a person; easy, medium or hard for a bot (SPEC §4, `Player`).
    add_column :players, :bot_level, :integer
  end
end
