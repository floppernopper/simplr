class AddMessageIdToTags < ActiveRecord::Migration[5.0]
  def change
    add_column :tags, :message_id, :integer
    remove_column :messages, :message_id
  end
end
