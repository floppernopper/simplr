class AddGoddessToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :goddess, :boolean
  end
end
