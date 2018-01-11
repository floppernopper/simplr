class Wiki < ApplicationRecord
  belongs_to :user
  
  has_many :wiki_versions
  has_many :pictures, dependent: :destroy
  
  accepts_nested_attributes_for :pictures
  
  def versions
    self.wiki_versions
  end
end
