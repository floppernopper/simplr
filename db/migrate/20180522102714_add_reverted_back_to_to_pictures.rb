class AddRevertedBackToToPictures < ActiveRecord::Migration[5.0]
  def change
    add_column :pictures, :reverted_back_to, :boolean
  end
end
