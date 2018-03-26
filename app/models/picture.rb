class Picture < ActiveRecord::Base
  belongs_to :product
  belongs_to :post

  mount_uploader :image, ImageUploader

  def move_up
    ensure_order
    new_order = order - 1
    # get the image above this one being moved down
    img_above = post.pictures.find_by_order new_order
    # moves the img above down
    img_above.update order: order
    # updates with new position
    update order: new_order
  end

  def move_down
    ensure_order
    new_order = order + 1
    # get the image below this one being moved up
    img_below = post.pictures.find_by_order new_order
    # moves the img below up
    img_below.update order: order
    # updates with new position
    update order: new_order
  end

  # updates all imgs in post with order
  def ensure_order
    if post.pictures.size > 1
      if order.nil?
        i=0; for img in post.pictures
          img.update order: i if img.order.nil?
          i += 1
        end
      end
      return true
    end
    nil
  end

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
