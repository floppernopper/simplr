class AddTypeToTreasures < ActiveRecord::Migration
  def change
    add_column :treasures, :type, :string
    add_column :treasures, :question, :text
    add_column :treasures, :answer, :string
  end
end
