class AddSenderTokenToNotes < ActiveRecord::Migration
  def change
    add_column :notes, :sender_token, :string
    add_column :messages, :receiver_token, :string
  end
end
