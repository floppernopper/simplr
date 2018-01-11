class AddConnectionIdToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :connection_id, :integer
    add_column :connections, :connection_id, :integer
  end
end
