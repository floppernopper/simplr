class CreateGames < ActiveRecord::Migration[5.0]
  def change
    create_table :games do |t|
      t.integer :user_id
      t.integer :folder_id
      t.string :title
      t.string :name
      t.string :body
      t.string :description
      t.string :ability
      t.string :stats
      t.boolean :active
      t.string :item_type
      t.datetime :expires_at
      t.string :unique_token
      t.timestamps
    end
  end
end
