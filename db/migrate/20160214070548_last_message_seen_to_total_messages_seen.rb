class LastMessageSeenToTotalMessagesSeen < ActiveRecord::Migration
  def change
    rename_column :connections, :last_message_seen_id, :total_messages_seen
  end
end
