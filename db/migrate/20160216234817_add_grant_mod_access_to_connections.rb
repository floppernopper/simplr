class AddGrantModAccessToConnections < ActiveRecord::Migration
  def change
    add_column :connections, :grant_mod_access, :boolean
  end
end
