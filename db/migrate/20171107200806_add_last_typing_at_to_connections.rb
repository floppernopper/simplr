class AddLastTypingAtToConnections < ActiveRecord::Migration[5.0]
  def change
    add_column :connections, :last_typing_at, :datetime
  end
end
