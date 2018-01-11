class AddPageToBots < ActiveRecord::Migration
  def change
    add_column :bots, :page, :string
  end
end
