class AddTotalItemsSeenToGroups < ActiveRecord::Migration[5.0]
  def change
    add_column :groups, :total_items_seen, :integer
  end
end
