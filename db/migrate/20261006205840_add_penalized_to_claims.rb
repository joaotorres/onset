class AddPenalizedToClaims < ActiveRecord::Migration[8.1]
  def change
    add_column :claims, :penalized, :boolean, default: false, null: false
  end
end
