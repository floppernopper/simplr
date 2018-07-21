class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :anon_token, :current_user, :current_identity, :mobile?, :browser, :get_location,
    :page_size, :paginate, :reset_page, :char_codes, :char_bits, :settings, :dev?, :anrcho?, :invited?,
    :seen?, :seent, :get_site_title, :record_last_visit, :probably_human, :god?, :goddess?, :currently_kristin?,
    :forrest_only_club?, :invited_to_forrest_only_club?, :in_dev?, :is_gatekeeper?, :page_turning, :testing_score?,
    :unique_element_token, :returning_user?, :stale_content?, :user_mentioned?, :low_energy?,
    :returning_user_with_stale_content?, :featured_content

  include SimpleCaptcha::ControllerHelpers

  # redirects to proposals index for anrcho.com
  before_action :anrcho_to_proposals, except: [:index, :on_point, :pricing, :calendar, :semantic_ui, :uikit, :purecss, :sample_blog]

  # redirects to forrest_web_co
  before_action :forrest_web_co_to_forrest_web_co, except: [:index]

  # bots go to 404 for all pages
  before_action :bots_to_404, except: [:index]

  def user_mentioned? item
    if item.respond_to? :body and item.body.present?
      for word in item.body.split(" ")
        if word.include?("@") or User.spaced_name_has_at? item.body
          user = user_spaced = User.spaced_name_has_at?(item.body)[:user]
          user ||= User.find_by_name(word.slice(word.index("@")+1..word.size)) if word.include? "@"
          if user or user_spaced
            msg = case item.class.to_s
            when "Post"
              :user_mention
            when "Comment"
              :user_mention_comment
            when "Proposal"
              :user_mention_proposal
            end
            Note.notify msg, (item.is_a?(Proposal) ? item.unique_token : item),
              user, current_identity unless current_identity.eql? user
            break if user_spaced
          end
        end
      end
    end
    user
  end

  def low_energy?
    false # cookies[:low_energy].present? or in_dev?
  end

  def get_location
    if current_user.geo_coordinates.present?
      coords = eval current_user.geo_coordinates
      geocoder = Geocoder.search("#{coords[0]}, #{coords[1]}").first
      if geocoder and geocoder.formatted_address
        location = geocoder.formatted_address
        current_user.update location: location
      end
    end
    return (location ? location : nil)
  end

  def build_proposal_feed section, group=nil
    Proposal.filter_spam # for recent anrcho spam
    reset_page; session[:current_proposal_section] = section.to_s
    proposals = if group
      group.proposals
    elsif in_dev?
      Proposal.all
    else
      Proposal.globals
    end
    @all_items = proposals.send(section.to_sym) + (group ? group.posts : [])
    @all_items.sort_by! { |item| item.score }
    @char_codes = char_codes @all_items
    @char_bits = char_bits @all_items
    @items = paginate @all_items
    for item in @items
      seent item
    end
  end

  def featured_content
    featured = []
    for item in (Post.where.not(user_id: current_user.id).to_a + Proposal.where.not(user_id: current_user.id).to_a)
      if (item.likes.size + item.comments.size) >= 1
        featured << item
      end
    end
    featured.sort_by {|i| i.created_at}.reverse
  end

  def returning_user_with_stale_content?
    cookies[:returning_user].present? and cookies[:stale_content].present?
  end

  def stale_content?
    # checks content for users and groups followed
    for l in [current_user.following, current_user.my_groups]
      # checks each user or group in above lists for new content
      for i in l
        # checks for new posts and new proposals, less than a month old
        if (i.posts.present? and i.posts.last.created_at > 1.month.ago) \
          or (i.proposals.present? and i.proposals.last.created_at > 1.month.ago)
            cookies[:stale_content] = { value: true, expires_at: 1.day.from_now }
            return true
        end
      end
    end
    nil
  end

  def returning_user?
    # last active longer than a month ago?
    if current_user.last_active_at < 1.month.ago
      cookies[:returning_user] = { value: true, expires_at: 1.day.from_now }
      return true
    end
    nil
  end

  def record_last_visit
    if current_user and (cookies[:last_active_at].nil? or cookies[:last_active_at].to_datetime < 1.hour.ago)
      current_user.update last_active_at: DateTime.current
      cookies[:last_active_at] = DateTime.current
    end
  end

  def get_site_title
    if anrcho?
      'Anrcho'
    elsif request.original_url.include? '/store'
      'Store'
    elsif request.original_url.include? '/keep_it_on_pointe'
      'Keep It On Pointe'
    else
      case request.host
      when 'forrestwebco.com'
        'Forrest Web Company'
      when 'forrestonlyclub.com'
        'Forrest Only Club'
      when 'forrestwilkins.com'
        'Forrest Wilkins'
      else
        'Social Maya'
      end
    end
  end

  def seent item
    # initial update for group activity
    if item.is_a? Group and current_user
      # if current_user is creator of group being seen
      if item.user_id.eql? current_user.id
        item.update total_items_seen: item.items_total
      else # if current_user is just a member of this group
        member = item.members.find_by_user_id current_user.id
        member.update total_items_seen: item.items_total if member
      end
    end
    # continues to normal seent
    views = if item.is_a? User
      View.where profile_id: item.id
    else
      item.views
    end
    if not seen? item
      if current_user
        # unless item is the current user or item is not a user at all and belongs to user
        unless current_user.eql? item
          view = views.new user_id: current_user.id, ip_address: request.remote_ip
          if item.respond_to?(:user) and current_user.eql? item.user
            view.non_visible = true
          end
          view.save unless item.is_a?(Message) and view.non_visible
        end
      else
        # unless the non-user, non-group item was posted by current anon
        unless !item.is_a? User and !item.is_a? Group and anon_token.eql? item.anon_token
          views.create anon_token: anon_token, ip_address: request.remote_ip if probably_human or invited?
        end
      end
    # updates score count of view for posts/proposals already seen by current user
    elsif current_user and (item.is_a? Post or item.is_a? Proposal)
      view = item.views.where(user_id: current_user.id).last
      view.update score_count: view.score_count.to_i + 1
    end

    # also notify for profile views after a certain point or even each view
    if current_user and item.is_a? User and not item.eql? current_user
      Note.notify :profile_view, current_user, item, current_user
    end


    for model in [Post, Proposal]
      # notify users of more than a few views they've received on a post, every week
      if item.is_a? model and item.user and item.views.where.not(user_id: item.user.id)
                                                     .where('created_at >= ?', 1.week.ago)
                                                     .where(anon_token: nil).size >= 5
        Note.notify "#{model.to_s.downcase}_views".to_sym, item, item.user, current_identity \
          unless item.user.notes.where(action: "#{model.to_s.downcase}_views").where('created_at >= ?', 1.week.ago).present?
      end
    end
  end

  def seen? item
    # accounts for profile views
    views = if item.is_a? User
      View.where profile_id: item.id
    else
      item.views
    end
    if current_user
      true if views.where(user_id: current_user.id).present?
    else
      true if views.where(anon_token: anon_token).present?
    end
  end

  def settings user=current_user
    Setting.settings user
  end

  def paginate items, _page_size=page_size
    return items.
      # drops first several posts if :feed_page
      drop((session[:page] ? session[:page] : 0) * _page_size).
      # only shows first several posts of resulting array
      first(_page_size)
  end

  def page_size
    @page_size = 10
  end

  def page_turning relevant_items=nil
    if session[:page].nil? or session[:page] * page_size <= relevant_items.size
      if session[:page]
        session[:page] += 1
      else
        session[:page] = 1
      end
    end
  end

  def reset_page
    # resets back to top
    unless session[:more]
      session[:page] = nil
    end
  end

  def char_bits items
    bits = [];
    for item in items
      item_string = get_correct_char_str item
      for char in item_string.split("")
        for bit in ("%04b" % char.codepoints.first).split("")
          bits << bit.to_i
        end
      end
    end
    return bits
  end

  def char_codes items
    codes = [];
    for item in items
      item_string = get_correct_char_str item
      for char in item_string.split("")
        codes << char.codepoints.first * 0.01
      end
    end
    return codes
  end

  # returns anon_token or current_user
  def current_identity
    if current_user
      return current_user
    else
      return anon_token
    end
  end


  def unique_element_token
    token = if cookies[:element_token].nil?
      cookies.permanent[:element_token] = SecureRandom.urlsafe_base64.gsub(/[^0-9a-z]/i, '')
    else
      cookies[:element_token]
    end
    return token
  end

  def anon_token
    unless current_user # signed up and and logged in
      if cookies[:token_timestamp].nil? or \
        cookies[:token_timestamp].to_datetime < 1.week.ago
        cookies.permanent[:token] = $name_generator.next_name + "_" + SecureRandom.urlsafe_base64
        cookies.permanent[:token_timestamp] = DateTime.current
        cookies.permanent[:simple_captcha_validated] = ""
      end
      token = cookies[:token].to_s
    else
      token = nil
    end
    return token
  end

  # ensures only humans are counted for views
  # mainly used for the first proposals in main feed
  def probably_human
    # set by 'pages/more' since only humans 'want more'
    # a way to see if the user is probably a human
    cookies[:human]
  end

  def testing_score?
    current_user and (ENV['RAILS_ENV'].eql? 'development' or dev?) and current_user.id.eql?(1) and false
  end

  def anrcho?
    request.host.eql? "anrcho.com" or cookies[:at_anrcho].present? or @anrcho
  end

  def forrest_only_club?
    request.host.eql? "forrestonlyclub.com" or cookies[:at_forrest_only_club].present?
  end

  def invited_to_forrest_only_club?
    (cookies[:forrest_only_invite_token].present? and Connection.find_by_unique_token(cookies[:forrest_only_invite_token])) \
      or current_user
  end

  def invited?
    (cookies[:invite_token].present? and Connection.find_by_unique_token(cookies[:invite_token]) \
      and not invited_to_forrest_only_club?) \
      or current_user or User.all.size.zero? or cookies[:zen].present?
  end

  def is_gatekeeper?
    current_user and current_user.gatekeeper and User.where(gatekeeper: true).last.eql? current_user
  end

  def dev?
    current_user and current_user.dev
  end

  def goddess?
    if dev? and current_user.goddess and current_user.kristin?
      return true
    end
  end

  def god?
    dev? and current_user.god and current_user.eql? User.first
  end

  def currently_kristin?
    current_user and current_user.id.eql? 34
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

  def in_dev?
    Rails.env.development?
  end

  private

  def get_correct_char_str item
    # gets correct string to push to glimmer
    item_string = if item.is_a? Note
      item.message
    elsif item.body.present?
      item.body
    # for motions only
    elsif item.image.url
      item.image.to_s
    # for posts only
    elsif item.pictures.present?
      item.pictures.first.image.to_s
    else
      "just in case of error" # incase there's no match for some reason idk yet
    end
    return item_string
  end

  def anrcho_to_proposals
    if request.host.eql? 'anrcho.com' and not cookies[:at_anrcho].present?
      cookies.permanent[:at_anrcho] = true.to_s
      redirect_to proposals_path
    end
  end

  def forrest_web_co_to_forrest_web_co
    if request.host.eql? 'forrestwebco.com' or request.host.eql? 'forrestwilkins.com'
      redirect_to forrest_web_co_path
    end
  end

  def bots_to_404
    redirect_to '/404' if request.bot? and anrcho? # turned on only for anrcho
  end
end
