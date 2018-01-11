class AddClickToViews < ActiveRecord::Migration[5.0]
  def change
    add_column :views, :click, :boolean
    add_column :views, :x_pos, :integer
    add_column :views, :y_pos, :integer
    add_column :views, :screen_width, :integer
    add_column :views, :screen_height, :integer
    add_column :views, :avail_screen_width, :integer
    add_column :views, :avail_screen_height, :integer
    add_column :views, :device_pixel_ratio, :integer
  end
end
