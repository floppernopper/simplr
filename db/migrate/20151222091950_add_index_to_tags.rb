class AddIndexToTags < ActiveRecord::Migration
  def change
    add_column :tags, :index, :integer
  end
end
