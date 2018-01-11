class AddBotIdToComments < ActiveRecord::Migration
  def change
    add_column :comments, :bot_id, :integer
  end
end
