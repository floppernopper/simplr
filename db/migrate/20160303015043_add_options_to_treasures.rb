class AddOptionsToTreasures < ActiveRecord::Migration
  def change
    add_column :treasures, :options, :string
  end
end
