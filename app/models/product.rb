class Product < ApplicationRecord
  belongs_to :user
  
  has_many :pictures, dependent: :destroy
  has_many :comments, dependent: :destroy
  
  before_create :gen_unique_token
  
  private
  
  def gen_unique_token
    begin
      self.unique_token = $name_generator.next_name[0..5].downcase
      self.unique_token << "_" + SecureRandom.urlsafe_base64.split('').sample(2).join.downcase.gsub("_", "").gsub("-", "")
    end while Product.exists? unique_token: self.unique_token
  end
end
