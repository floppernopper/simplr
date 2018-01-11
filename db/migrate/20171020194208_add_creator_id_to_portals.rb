class AddCreatorIdToPortals < ActiveRecord::Migration[5.0]
  def change
    add_column :portals, :creator_id, :integer
  end
end
