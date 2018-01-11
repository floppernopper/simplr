class CreateTreasures < ActiveRecord::Migration
  def change
    create_table :treasures do |t|
      t.integer :user_id
      t.integer :group_id
      t.integer :treasure_id
      t.string :unique_token
      t.integer :xp
      t.string :loot
      t.string :power
      t.float :chance
      t.timestamps null: false
    end
  end
end
