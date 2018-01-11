class AddControllerNameToViews < ActiveRecord::Migration[5.0]
  def change
    add_column :views, :controller_name, :string
    add_column :views, :action_name, :string
  end
end
