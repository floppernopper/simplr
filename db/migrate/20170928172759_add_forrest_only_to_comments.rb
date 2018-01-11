class AddForrestOnlyToComments < ActiveRecord::Migration[5.0]
  def change
    add_column :comments, :forrest_only, :boolean
  end
end
