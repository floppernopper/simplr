class ChangeToMonetize < ActiveRecord::Migration[5.0]
  def change
    if Rails.env.development?
      remove_money :products, :price
    end
    add_monetize :products, :price
  end
end
