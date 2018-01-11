class AddBodyToTreasures < ActiveRecord::Migration
  def change
    add_column :treasures, :body, :text
  end
end
