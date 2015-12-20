class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  helper_method :anon_token, :current_user, :mobile?, :browser, :get_location, :page_size, :paginate, :reset_page
  
  def get_location
    address = nil; locale = nil
    ip = request.remote_ip
    geoip = GeoIP.new('GeoLiteCity.dat').city(ip)
    if defined? geoip and geoip
      if geoip.latitude and geoip.longitude
        geocoder = Geocoder.search("#{geoip.latitude}, #{geoip.longitude}").first
        if geocoder and geocoder.formatted_address
          address = geocoder.formatted_address
        end
      end
    end
    locale = if address.present?
      { address: address, lat: geoip.latitude, lon: geoip.longitude }
    else
      {}
    end
    return locale
  end
  
  def paginate items, _page_size=page_size
    return items.
      # drops first several posts if :feed_page
      drop((session[:page] ? session[:page] : 0) * _page_size).
      # only shows first several posts of resulting array
      first(_page_size)
  end

  def page_size
    @page_size = 5
  end
  
  def reset_page
    # resets back to top
    unless session[:more]
      session[:page] = nil
      session[:current_proposal_section] = nil
    end
  end
  
  def anon_token
    if cookies[:token_timestamp].nil? or \
      cookies[:token_timestamp].to_datetime < 1.week.ago
      cookies.permanent[:token] = SecureRandom.urlsafe_base64
      cookies.permanent[:token_timestamp] = DateTime.current
    end
    return cookies[:token].to_s
  end

  def current_user
    @current_user ||= User.find_by_auth_token(cookies[:auth_token]) if cookies[:auth_token]
  end
  
  def mobile?
    browser.mobile? or browser.tablet?
  end
  
  def browser
    Browser.new(:ua => request.env['HTTP_USER_AGENT'].to_s, :accept_language => "en-us")
  end
end
