class CreatePortals < ActiveRecord::Migration
  def change
    create_table :portals do |t|
      t.string :unique_token
      t.datetime :expires_at
      t.integer :remaining_uses
      t.timestamps null: false
    end
  end
end
