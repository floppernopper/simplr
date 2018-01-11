module OrdersHelper
  def order_img order
    for product in order.products
      for picture in product.pictures
        return picture.image
      end
    end
    nil
  end
end
