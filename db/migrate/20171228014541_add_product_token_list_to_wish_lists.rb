class AddProductTokenListToWishLists < ActiveRecord::Migration[5.0]
  def change
    add_column :wish_lists, :product_token_list, :string
  end
end
