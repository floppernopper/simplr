class AddLocaleToViews < ActiveRecord::Migration[5.0]
  def change
    add_column :views, :locale, :string
  end
end
