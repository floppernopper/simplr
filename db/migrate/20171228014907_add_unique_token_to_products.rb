class AddUniqueTokenToProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :unique_token, :string
  end
end