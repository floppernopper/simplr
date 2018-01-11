class AddAnonTokenToConnections < ActiveRecord::Migration
  def change
    add_column :connections, :anon_token, :string
  end
end
