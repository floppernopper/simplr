class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.integer :user_id
      t.integer :post_id
      t.integer :group_id
      t.integer :comment_id
      t.string :tag
      t.timestamps null: false
    end
  end
end
