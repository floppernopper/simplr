module CartsHelper
  def my_cart_total
    products = current_user.my_cart.products
    if products.present?
      total = Money.new 0
      for product in products
        total += product.price
      end
      return total.format
    else
      nil
    end
  end
  
  def in_my_cart? product
    current_user.my_cart.products.include? product
  end
end
