class CreateLikes < ActiveRecord::Migration
  def change
    create_table :likes do |t|
      t.integer :user_id
      t.string :anon_token
      t.integer :post_id
      t.integer :comment_id
      t.string :unique_token
      t.timestamps null: false
    end
  end
end
