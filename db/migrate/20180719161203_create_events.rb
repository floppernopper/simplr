class CreateEvents < ActiveRecord::Migration[5.0]
  def change
    create_table :events do |t|
      t.string :title
      t.text :body
      t.string :image
      t.integer :user_id
      
      t.datetime :start_date
      t.timestamps
    end
  end
end
