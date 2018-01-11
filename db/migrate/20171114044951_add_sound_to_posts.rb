class AddSoundToPosts < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :sound, :boolean
  end
end
