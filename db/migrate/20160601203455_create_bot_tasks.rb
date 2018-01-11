class CreateBotTasks < ActiveRecord::Migration
  def change
    create_table :bot_tasks do |t|
      t.integer :user_id
      t.string :unique_token
      t.string :name
      t.text :body
      t.timestamps null: false
    end
  end
end
