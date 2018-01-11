class CreateWikiVersions < ActiveRecord::Migration[5.0]
  def change
    create_table :wiki_versions do |t|
      t.integer :wiki_id
      t.text :title
      t.text :body
      t.timestamps
    end
  end
end
