class AddGrantGkAccessToConnections < ActiveRecord::Migration
  def change
    add_column :connections, :grant_gk_access, :boolean
  end
end
