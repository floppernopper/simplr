class AddDevToUsers < ActiveRecord::Migration
  def change
    add_column :users, :dev, :boolean
  end
end
