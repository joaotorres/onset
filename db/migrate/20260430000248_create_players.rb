class CreatePlayers < ActiveRecord::Migration[8.1]
  def change
    create_table :players do |t|
      t.references :game, null: false, foreign_key: true
      t.bigint :user_id
      t.string :session_token, null: false
      t.string :name, null: false
      t.string :color, null: false
      t.datetime :last_seen_at
      t.datetime :left_at

      t.timestamps
    end

    add_index :players, :session_token, unique: true
  end
end
