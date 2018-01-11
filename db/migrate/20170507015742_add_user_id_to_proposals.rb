class AddUserIdToProposals < ActiveRecord::Migration[5.0]
  def change
    add_column :proposals, :user_id, :integer
  end
end
