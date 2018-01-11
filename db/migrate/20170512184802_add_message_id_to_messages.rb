class AddMessageIdToMessages < ActiveRecord::Migration[5.0]
  def change
    add_column :messages, :message_id, :integer
  end
end
