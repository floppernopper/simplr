class AddBlobDataToBots < ActiveRecord::Migration[5.0]
  def change
    add_column :bots, :blob_data, :binary
  end
end
