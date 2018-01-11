class AddProductTokenListToCarts < ActiveRecord::Migration[5.0]
  def change
    add_column :carts, :product_token_list, :string
  end
end
