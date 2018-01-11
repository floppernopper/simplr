class AddGrantDevAccessToConnections < ActiveRecord::Migration
  def change
    add_column :connections, :grant_dev_access, :boolean
  end
end
