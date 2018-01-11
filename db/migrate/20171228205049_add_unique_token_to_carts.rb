class AddUniqueTokenToCarts < ActiveRecord::Migration[5.0]
  def change
    add_column :carts, :unique_token, :string
    add_column :wish_lists, :unique_token, :string
  end
end
