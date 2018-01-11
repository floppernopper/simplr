class AddMemeWarClassToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :meme_war_class, :string
  end
end
