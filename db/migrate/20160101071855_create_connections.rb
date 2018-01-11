class CreateConnections < ActiveRecord::Migration
  def change
    create_table :connections do |t|
      t.integer :user_id
      t.integer :other_user_id
      t.integer :group_id
      t.timestamps null: false
    end
  end
end
