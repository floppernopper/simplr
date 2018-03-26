class AddOrderToPictures < ActiveRecord::Migration[5.0]
  def change
    add_column :pictures, :order, :integer
  end
end
