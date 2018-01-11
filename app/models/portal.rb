class Portal < ActiveRecord::Base
  belongs_to :user
  
  before_create :gen_unique_token, :initialize_portal
  before_destroy :destroy_dependent_portals
  
  DEFAULT_REMAINING_USES = 5
  
  scope :loners, -> { where cluster: nil, cluster_id: nil }
  scope :clusters, -> { where cluster: true }
  
  def _cluster
    if self.cluster_id
      Portal.where(cluster: true).find_by_id self.cluster_id
    else
      nil
    end
  end
  
  def portals
    if self.cluster
      Portal.where cluster_id: self.id
    else
      nil
    end
  end
  
  def self.expiration_date
    1.week.from_now.to_datetime
  end
    
  private
  
  def destroy_dependent_portals
    if self.cluster
      for portal in self.portals
        portal.destroy
      end
    end
  end
  
  # defaults to 5 uses and expires a week from now
  def initialize_portal
    self.expires_at ||= Portal.expiration_date
    self.remaining_uses ||= DEFAULT_REMAINING_USES
  end

  def gen_unique_token
    self.unique_token = $name_generator.next_name[0..5].downcase
    if self.cluster
      self.unique_token << "_" + SecureRandom.urlsafe_base64
    else
      self.unique_token << "_" + SecureRandom.urlsafe_base64.split('').sample(2).join.downcase.gsub("_", "").gsub("-", "")
    end
  end
end
