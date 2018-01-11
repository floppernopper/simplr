module CartsHelper
  def my_cart_total
    if current_user.my_cart.products.present?
      current_user.my_cart.total.format
    else
      nil
    end
  end
  
  def in_my_cart? product
    current_user.my_cart.products.include? product
  end
end
