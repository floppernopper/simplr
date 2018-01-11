class AddGiverIdToTreasures < ActiveRecord::Migration
  def change
    add_column :treasures, :giver_id, :integer
  end
end
