class AddForrestOnlyToConnections < ActiveRecord::Migration[5.0]
  def change
    add_column :connections, :forrest_only, :boolean
  end
end
