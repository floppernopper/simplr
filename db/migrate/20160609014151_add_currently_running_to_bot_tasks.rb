class AddCurrentlyRunningToBotTasks < ActiveRecord::Migration
  def change
    add_column :bot_tasks, :currently_running, :boolean
  end
end
