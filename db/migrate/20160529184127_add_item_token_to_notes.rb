class AddItemTokenToNotes < ActiveRecord::Migration
  def change
    add_column :notes, :item_token, :string
  end
end
