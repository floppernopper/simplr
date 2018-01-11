class CreateSecrets < ActiveRecord::Migration
  def change
    create_table :secrets do |t|
      t.integer :user_id
      t.integer :group_id
      t.integer :secret_id
      t.string :unique_token
      t.string :name
      t.text :body
      t.string :image
      t.integer :xp
      t.string :node_type
      t.timestamps null: false
    end
  end
end
