class RemoveCurrentlyRunningFromTasks < ActiveRecord::Migration
  def change
    remove_column :bot_tasks, :currently_running
  end
end
