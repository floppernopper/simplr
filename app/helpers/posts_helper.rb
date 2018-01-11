module PostsHelper
  def original_post_pictures post
    if post.original_id
      original = Post.find_by_id post.original_id
      if original
        return original.pictures
      end
    else
      return post.pictures
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
