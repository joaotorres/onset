class AddClaimColumnsToStep8 < ActiveRecord::Migration[8.1]
  def change
    add_column :games, :claim_player_id, :bigint
    add_column :games, :claim_started_at, :datetime

    add_column :players, :score, :integer, default: 0, null: false
    add_column :players, :locked_until, :datetime

    create_table :claims do |t|
      t.references :game, null: false, foreign_key: true
      t.references :player, null: false, foreign_key: true
      t.json :card_ids
      t.integer :result, default: 0, null: false
      t.datetime :started_at, null: false
      t.datetime :resolved_at

      t.timestamps
    end
  end
end
