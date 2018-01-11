class AddModToUsers < ActiveRecord::Migration
  def change
    add_column :users, :mod, :boolean
  end
end
