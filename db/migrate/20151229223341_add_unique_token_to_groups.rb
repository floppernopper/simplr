class AddUniqueTokenToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :unique_token, :string
  end
end
