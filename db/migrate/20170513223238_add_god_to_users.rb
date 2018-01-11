class AddGodToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :god, :boolean
  end
end
