class AddRequestToConnections < ActiveRecord::Migration
  def change
    add_column :connections, :invite, :boolean
    add_column :connections, :request, :boolean
  end
end
