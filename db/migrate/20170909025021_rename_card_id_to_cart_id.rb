class RenameCardIdToCartId < ActiveRecord::Migration[5.0]
  def change
    rename_column :products, :card_id, :cart_id
  end
end
