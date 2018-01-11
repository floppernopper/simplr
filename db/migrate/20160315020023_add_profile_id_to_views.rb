class AddProfileIdToViews < ActiveRecord::Migration
  def change
    add_column :views, :profile_id, :integer
  end
end
