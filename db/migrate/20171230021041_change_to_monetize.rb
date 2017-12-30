class ChangeToMonetize < ActiveRecord::Migration[5.0]
  def change
    remove_money :products, :price
    add_monetize :products, :price
  end
end
