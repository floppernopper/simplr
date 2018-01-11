class AddNameToTreasures < ActiveRecord::Migration
  def change
    add_column :treasures, :name, :string
  end
end
