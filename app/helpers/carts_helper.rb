module CartsHelper
  def in_my_cart? product
    current_user.my_cart.products.include? product
  end
end
