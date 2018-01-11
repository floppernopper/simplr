class AddNonVisibleToViews < ActiveRecord::Migration[5.0]
  def change
    add_column :views, :non_visible, :boolean
  end
end
