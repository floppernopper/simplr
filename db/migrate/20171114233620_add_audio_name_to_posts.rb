class AddAudioNameToPosts < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :audio_name, :string
  end
end
