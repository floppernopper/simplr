class AddSaltToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :salt, :string
  end
end
