class Picture < ActiveRecord::Base
  belongs_to :product
  belongs_to :post
  
  mount_uploader :image, ImageUploader
  
  def classify
    # switch between tensorflows
    use_tensorflow_rb = false
    if use_tensorflow_rb
      # uses tensorflow ruby gem
      path = self.image_url.to_s; path[0] = ''
      path = Rails.root + path
      name = classify_image path
    else
      # uses tensorflow python library
      path = "http://localhost:3000" + self.image_url.to_s
      name = p `classify "#{path}"`
      # parses output to get name
      name = name.split("\n").last
    end
    # updates picture with name of content
    self.update classifier_name: name
    return self.classifier_name
  end
end
