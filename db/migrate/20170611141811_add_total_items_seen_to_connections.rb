class AddTotalItemsSeenToConnections < ActiveRecord::Migration[5.0]
  def change
    add_column :connections, :total_items_seen, :integer
  end
end
