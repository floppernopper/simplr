class RemoveProductPrice < ActiveRecord::Migration[5.0]
  def change
    remove_column :products, :price
    remove_column :products, :price_cents
    remove_column :products, :price_currency
  end
end
