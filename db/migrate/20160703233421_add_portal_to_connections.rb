class AddPortalToConnections < ActiveRecord::Migration
  def change
    add_column :connections, :portal, :boolean
  end
end
