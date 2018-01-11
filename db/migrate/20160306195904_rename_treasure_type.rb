class RenameTreasureType < ActiveRecord::Migration
  def change
    rename_column :treasures, :type, :treasure_type
  end
end
