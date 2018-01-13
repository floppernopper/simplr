class Picture < ActiveRecord::Base
  belongs_to :product
  belongs_to :post
  
  mount_uploader :image, ImageUploader
  
  def classify
    if Rails.env.development?
      url = "http://localhost:3000" + self.image_url.to_s
      name = p `classify "#{url}"`
    else
      # when path is not set up
      url = "/home/rails/simplr" + self.image_url.to_s
      name = p `/usr/local/bin/classify "#{url}"`
    end
    # parses output to get name
    name = name.split("\n").last
    # updates picture with name of content
    self.update classifier_name: name
    return self.classifier_name
  end
end
