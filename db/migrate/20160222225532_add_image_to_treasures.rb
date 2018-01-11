class AddImageToTreasures < ActiveRecord::Migration
  def change
    add_column :treasures, :image, :string
  end
end
