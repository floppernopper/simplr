class AddUniqueTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :unique_token, :string
  end
end
