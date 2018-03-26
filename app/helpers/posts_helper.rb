module PostsHelper
  def original_post_pictures post
    if post.original_id
      original = Post.find_by_id post.original_id
      if original
        # ensures photoset order if its been changed by op
        originals = original.pictures.to_a
        originals.sort_by { |i| i.order } if originals.present? and originals.first.ensure_order
        return originals
      end
    else
      # ensures photoset order if its been changed
      pictures = post.pictures.to_a
      pictures.sort_by! { |i| i.order } if pictures.present? and pictures.first.ensure_order
      return pictures
    end
  end

  def original_post_image post
    if post.original_id
      original = Post.find_by_id post.original_id
      if original
        return original.image
      end
    else
      return post.image
    end
  end
end
