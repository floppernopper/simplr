class AddClusterToPortals < ActiveRecord::Migration[5.0]
  def change
    add_column :portals, :cluster, :boolean
    add_column :portals, :cluster_id, :integer
  end
end
