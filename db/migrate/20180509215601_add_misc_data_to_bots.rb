class AddMiscDataToBots < ActiveRecord::Migration[5.0]
  def change
    add_column :bots, :misc_data, :string
  end
end
