class Product < ApplicationRecord
  has_many :pictures, dependent: :destroy
end
