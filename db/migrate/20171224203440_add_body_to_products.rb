class AddBodyToProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :body, :text
  end
end
