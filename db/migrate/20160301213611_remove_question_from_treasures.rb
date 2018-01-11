class RemoveQuestionFromTreasures < ActiveRecord::Migration
  def change
    remove_column :treasures, :question
    remove_column :treasures, :loot
  end
end
