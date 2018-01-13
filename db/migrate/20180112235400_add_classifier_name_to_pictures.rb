class AddClassifierNameToPictures < ActiveRecord::Migration[5.0]
  def change
    add_column :pictures, :classifier_name, :string
  end
end
