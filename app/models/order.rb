class Order < ApplicationRecord
  belongs_to :user
  before_create :gen_unique_token
  monetize :total_cents
  
  def products
    # gets tokens and replaces each with its product in array
    eval(product_token_list).map { |t| Product.find_by_unique_token t }
  end
  
  private
  
  def gen_unique_token
    begin
      self.unique_token = $name_generator.next_name[0..5].downcase
      self.unique_token << "_" + SecureRandom.urlsafe_base64.split('').sample(2).join.downcase.gsub("_", "").gsub("-", "")
    end while Order.exists? unique_token: self.unique_token
  end
end
