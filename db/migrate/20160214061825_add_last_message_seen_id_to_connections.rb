class AddLastMessageSeenIdToConnections < ActiveRecord::Migration
  def change
    add_column :connections, :last_message_seen_id, :integer
  end
end
