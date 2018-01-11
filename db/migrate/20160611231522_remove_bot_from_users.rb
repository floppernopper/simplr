class RemoveBotFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :bot
  end
end
