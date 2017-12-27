class Picture < ActiveRecord::Base
  belongs_to :product
  belongs_to :post
  
  mount_uploader :image, ImageUploader
end
