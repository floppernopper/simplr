class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.integer :user_id
      t.integer :receiver_id
      t.integer :group_id
      t.text :body
      t.string :image

      t.timestamps null: false
    end
  end
end
