module WishListsHelper
  def in_my_wish_list? product
    current_user.my_wish_list.products.include? product
  end
end
