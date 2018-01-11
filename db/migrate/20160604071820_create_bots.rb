class CreateBots < ActiveRecord::Migration
  def change
    create_table :bots do |t|
      t.string :unique_token
      t.string :name
      t.text :body
      t.timestamps null: false
    end
  end
end
