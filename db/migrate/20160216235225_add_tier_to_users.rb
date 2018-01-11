class AddTierToUsers < ActiveRecord::Migration
  def change
    add_column :users, :tier, :integer
    add_column :users, :xp, :integer
  end
end
