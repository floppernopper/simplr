class AddPageToBotTasks < ActiveRecord::Migration
  def change
    add_column :bot_tasks, :page, :string
  end
end
