class AddUserIdToPortals < ActiveRecord::Migration[5.0]
  def change
    add_column :portals, :user_id, :integer
  end
end
