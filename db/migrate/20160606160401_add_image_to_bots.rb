class AddImageToBots < ActiveRecord::Migration
  def change
    add_column :bots, :image, :string
  end
end
