class AddWikiIdToImages < ActiveRecord::Migration[5.0]
  def change
    add_column :pictures, :wiki_id, :integer
  end
end
