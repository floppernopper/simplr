class AddTitleToConnections < ActiveRecord::Migration[5.0]
  def change
    add_column :connections, :title, :string
  end
end
