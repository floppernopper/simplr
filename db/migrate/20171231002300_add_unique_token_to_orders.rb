class AddUniqueTokenToOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :unique_token, :string
  end
end
