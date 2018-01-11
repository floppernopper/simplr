class AddZodiacToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :zodiac, :string
    
    add_column :users, :energy_points, :integer
  end
end
