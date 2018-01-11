class Cart < ApplicationRecord
  belongs_to :user
  before_create :gen_unique_token
  
  # with self preceeding, only called explicitly
  def self.initialize user
    if user.cart.nil?
      user.cart = new
    end
    unless user.cart.product_token_list.present?
      user.cart.update product_token_list: "[]"
    end
  end
  
  def total
    total = Money.new 0
    for product in products
      total += product.price
    end
    return total
  end
  
  def add product
    unless products.include? product
      new_list = (eval(product_token_list) << product.unique_token).to_s
      update product_token_list: new_list
    end
  end
  
  def remove product
    if products.include? product
      new_list = (eval(product_token_list) - [product.unique_token]).to_s
      update product_token_list: new_list
    end
  end
  
  def products
    # gets tokens and replaces each with its product in array
    eval(product_token_list).map { |t| Product.find_by_unique_token t }
  end
  
  private
  
  def gen_unique_token
    begin
      self.unique_token = $name_generator.next_name[0..5].downcase
      self.unique_token << "_" + SecureRandom.urlsafe_base64.split('').sample(2).join.downcase.gsub("_", "").gsub("-", "")
    end while Cart.exists? unique_token: self.unique_token
  end
end
