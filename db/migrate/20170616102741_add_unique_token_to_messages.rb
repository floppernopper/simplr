class AddUniqueTokenToMessages < ActiveRecord::Migration[5.0]
  def change
    add_column :messages, :unique_token, :string
  end
end
