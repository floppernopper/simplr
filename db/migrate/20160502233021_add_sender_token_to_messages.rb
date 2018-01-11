class AddSenderTokenToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :sender_token, :string
  end
end
