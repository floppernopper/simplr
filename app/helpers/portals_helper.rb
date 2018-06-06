module PortalsHelper
  # returns current official gatekeeper
  # most recent gatekeeper is the most official one
  def gatekeeper? user
    User.where(gatekeeper: true).last.eql? user
  end

  def to_anrcho_portal_url
    url = root_url; url.gsub 'http', 'https' unless in_dev?
    url.gsub! 'socialmaya', 'anrcho' if url.include?('socialmaya') and @anrcho_is_up; url.slice!(-1)
    url += portal_to_anrcho_path(Portal.to_anrcho(current_user).unique_token) if current_user
    return url
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

  def portal_size
    options = [["Choose number of uses", nil],
      ["5", 5],
      ["10", 10],
      ["25", 25],
      ["50", 50],
      ["75", 75],
      ["100", 100],
      ["150", 150],
      ["250", 250],
      ["500", 500],
      ["1000", 1000]]
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
