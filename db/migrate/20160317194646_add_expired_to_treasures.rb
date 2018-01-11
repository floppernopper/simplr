class AddExpiredToTreasures < ActiveRecord::Migration
  def change
    add_column :treasures, :expired, :boolean
  end
end
