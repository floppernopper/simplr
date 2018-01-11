class CreateOrders < ActiveRecord::Migration[5.0]
  def change
    create_table :orders do |t|
      t.integer :user_id
      t.string :product_token_list
      t.integer :total
      t.string :address
      t.timestamps
    end
  end
end
