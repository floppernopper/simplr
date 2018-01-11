class RenameGroupDescriptionToBody < ActiveRecord::Migration
  def change
    rename_column :groups, :description, :body
  end
end
