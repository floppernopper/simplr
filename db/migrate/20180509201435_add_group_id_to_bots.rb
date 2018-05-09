class AddGroupIdToBots < ActiveRecord::Migration[5.0]
  def change
    add_column :bots, :group_id, :integer
  end
end
