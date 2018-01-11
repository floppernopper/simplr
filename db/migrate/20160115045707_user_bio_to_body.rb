class UserBioToBody < ActiveRecord::Migration
  def change
    rename_column :users, :bio, :body
  end
end
