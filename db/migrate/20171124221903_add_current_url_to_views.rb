class AddCurrentUrlToViews < ActiveRecord::Migration[5.0]
  def change
    add_column :views, :current_url, :string
  end
end
