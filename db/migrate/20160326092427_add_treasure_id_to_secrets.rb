class AddTreasureIdToSecrets < ActiveRecord::Migration
  def change
    add_column :secrets, :treasure_id, :integer
  end
end
