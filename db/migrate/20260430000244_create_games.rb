class CreateGames < ActiveRecord::Migration[8.1]
  def change
    create_table :games do |t|
      t.string :code, limit: 6, null: false
      t.bigint :host_player_id
      t.datetime :last_activity_at
      t.datetime :ended_at

      t.timestamps
    end

    add_index :games, :code, unique: true
  end
end
