class AddForrestOnlyToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :forrest_only, :boolean
  end
end
