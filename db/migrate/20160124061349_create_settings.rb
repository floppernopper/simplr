class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.integer :user_id
      t.integer :group_id
      t.string :name
      t.boolean :on
      t.string :state

      t.timestamps null: false
    end
  end
end
