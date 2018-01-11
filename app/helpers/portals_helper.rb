module PortalsHelper
  # returns current official gatekeeper
  # most recent gatekeeper is the most official one
  def gatekeeper? user
    User.where(gatekeeper: true).last.eql? user
  end
  
  def portal_qr_code link
    return RQRCode::QRCode.new link, size: 5, level: :h
  end

  def portal_url portal
    link = root_url
    link.slice!(-1)
    link += enter_portal_path(portal.unique_token)
    return link
  end
  
  def portal_cluster_size
    options = [["Generate as a cluster? (multiple)", nil],
      ["5", 5],
      ["10", 10],
      ["25", 25],
      ["50", 50]]
    return options
  end
  
  def portal_life_durations
    options = [["How long should it stay open for?", nil],
      ["1 week (default)", 7],
      ["1 month", 30],
      ["2 months", 60],
      ["3 months", 90]]
    return options
  end
end
