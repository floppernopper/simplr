class AddBotIdToBotTasks < ActiveRecord::Migration
  def change
    add_column :bot_tasks, :bot_id, :integer
  end
end
