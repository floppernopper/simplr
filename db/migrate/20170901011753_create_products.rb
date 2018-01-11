class CreateProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :products do |t|
      t.integer :card_id
      t.integer :wish_list_id
      t.string :name
      t.string :description
      t.timestamps
    end
  end
end
