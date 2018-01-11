class CreateWikis < ActiveRecord::Migration[5.0]
  def change
    create_table :wikis do |t|
      t.integer :user_id
      t.text :title
      t.text :body
      t.integer :version
      t.timestamps
    end
  end
end
