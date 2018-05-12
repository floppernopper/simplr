class AddToAnrchoToPortals < ActiveRecord::Migration[5.0]
  def change
    add_column :portals, :to_anrcho, :boolean
  end
end
