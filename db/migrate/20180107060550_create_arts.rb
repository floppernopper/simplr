class CreateArts < ActiveRecord::Migration[5.0]
  def change
    create_table :arts do |t|
      t.integer :user_id
      t.string :unique_token
      t.string :element_id
      t.integer :art_id
      t.float :x_pos
      t.float :y_pos
      t.string :shape
      t.string :color
      t.timestamps
    end
  end
end
