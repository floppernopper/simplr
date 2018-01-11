class AddHiddenToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :hidden, :boolean
  end
end
