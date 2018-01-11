class AddUniqueTokenToConnections < ActiveRecord::Migration
  def change
    add_column :connections, :unique_token, :string
  end
end
