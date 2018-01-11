class CreateTemplateItems < ActiveRecord::Migration[5.0]
  def change
    create_table :template_items do |t|
      t.string :title
      t.text :body
      t.string :image
      t.boolean :photoset
      t.string :video
      t.string :tag
      t.string :unique_token
      t.timestamps
    end
  end
end
