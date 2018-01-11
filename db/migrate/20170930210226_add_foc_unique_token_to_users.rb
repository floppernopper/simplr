class AddFocUniqueTokenToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :foc_unique_token, :string
  end
end
