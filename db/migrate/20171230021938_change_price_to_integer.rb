class ChangePriceToInteger < ActiveRecord::Migration[5.0]
  def change
    remove_money :products, :price
    add_column :products, :price, :integer
  end
end
