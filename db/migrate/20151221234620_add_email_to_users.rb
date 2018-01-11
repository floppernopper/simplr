class AddEmailToUsers < ActiveRecord::Migration
  def change
    add_column :users, :bio, :text
    add_column :users, :email, :string
    add_column :users, :password, :string
    add_column :users, :password_salt, :string
  end
end
