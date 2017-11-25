class AddGameIdToConnections < ActiveRecord::Migration[5.0]
  def change
    add_column :connections, :game_id, :integer
  end
end
