class DropWiki < ActiveRecord::Migration[5.0]
  def change
    drop_table :wiki_pages
    drop_table :wiki_page_versions
  end
end
