class CreateSounds < ActiveRecord::Migration[5.0]
  def change
    create_table :sounds do |t|
      t.integer :user_id
      t.integer :group_id
      t.string :name
      t.string :audio
      t.string :unique_token
      t.timestamps
    end
  end
end
