class AddExpiredToPortals < ActiveRecord::Migration[5.0]
  def change
    add_column :portals, :expired, :boolean
  end
end
