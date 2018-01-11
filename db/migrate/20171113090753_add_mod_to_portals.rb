class AddModToPortals < ActiveRecord::Migration[5.0]
  def change
    add_column :portals, :mod, :boolean
    add_column :portals, :dev, :boolean
    add_column :portals, :admin, :boolean
    add_column :portals, :goddess, :boolean
    add_column :portals, :god, :boolean
    
    add_column :connections, :mod, :boolean
    add_column :connections, :admin, :boolean
  end
end
