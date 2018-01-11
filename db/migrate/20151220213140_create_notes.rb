class CreateNotes < ActiveRecord::Migration
  def change
    create_table :notes do |t|
      t.integer :user_id
      t.integer :sender_id
      t.string :message
      t.string :action
      t.boolean :seen

      t.timestamps null: false
    end
  end
end
