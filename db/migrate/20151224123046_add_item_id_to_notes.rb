class AddItemIdToNotes < ActiveRecord::Migration
  def change
    add_column :notes, :item_id, :integer
  end
end
