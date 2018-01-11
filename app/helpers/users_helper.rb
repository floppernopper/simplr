module UsersHelper
  def kristin? user=nil
    @user = user if user
    if @user.id.eql? 34
      true
    elsif @user.name.eql? "Kristin"
      true
    elsif @user.body.eql? "Let me be that I am and seek not to alter me"
      true
    end
  end
  
  def last_locale user
    locale_and_time_ago = ""
    if god?
      locale_and_time_ago << user.views.last.locale if user.views.present? and user.views.last.locale.present?
      locale_and_time_ago << ", last active " + time_ago(time_ago_in_words(user.last_active_at)) if user.last_active_at
    end
    return locale_and_time_ago
  end
  
  def following_options
    @options = [["Choose a user", nil]]
    if current_user
      for user in current_user.following
        # inserts user as an invite option unless they're already a member of this group or already invited
        inserts_available_following_options user
      end
    else
      for user in User.all
        # inserts user as an invite option unless they're already a member of this group or already invited
        inserts_available_following_options user
      end
    end
    return @options
  end
  
  def featured_users
    featured = []
    User.where.not(image: nil).each do |user|
      # featured unless logged in and already joined
      featured << user unless current_user and (current_user.eql? user or current_user.following.include? user)
    end
    return featured.sample(4)
  end
  
  def user_mentioned word
    User.find_by_name(word.slice(word.index("@")+1..word.size)) if word.include? "@"
  end
  
  def own_item? item
    (anon_token and anon_token.eql? item.anon_token) or (current_user and item.user_id.eql? current_user.id)
  end
  
  def this_user_current? user=nil
    if current_user
      if @user and @user_shown and current_user.id.eql? @user.id
        true
      elsif user and current_user.id.eql? user.id
        true
      end
    end
  end
  
  def avatar_pattern chars
    # pattern based on chars, in following order:
    # pixels chosen, colors chosen
    c_low = 45; c_avg = 86; c_high = 122
    pattern = []; num = 0; for char in chars
      code = char.codepoints.last.to_i
      range = 5
      case code.to_i
      when c_avg-range..c_avg+range
        pattern << [num, awesome_colors(char, chars)[:array]]
      end
    num += 1; end
    return pattern
  end
  
  def awesome_colors char, chars
    multiplier = 2
    # gets the two characters after the current one
    next_char = next_chars(char, chars)[:next_char]
    after_next = next_chars(char, chars)[:after_next]
    # converts to percentages for each
    char_per = char.codepoints.last * 0.01
    next_char_per = next_char.codepoints.last * 0.01
    after_next_per = after_next.codepoints.last * 0.01
    
    # applies multiplier to bring codes in range of color
    char_code = char.codepoints.last * multiplier
    next_char_code = next_char.codepoints.last * multiplier
    after_next_code = after_next.codepoints.last * multiplier
    
    # manipulates for contrast
    char = (char_code * char_per).to_i
    next_char = (next_char_code * next_char_per).to_i
    after_next = (after_next_code * after_next_per).to_i
    
    # returns the string of rgb values for css
    return { string: "#{char}, #{next_char}, #{after_next}",
      array: [char, next_char, after_next] }
  end
  
  private
  
  # for inviting users to a group
  def inserts_available_following_options user
    # inserts user as an invite option unless they're already a member of this group or already invited
    unless @group and (@group.members.find_by_user_id user.id or @group.invites.find_by_user_id user.id)
      @options << [user.name, user.id]
    end
  end
  
  def next_chars char, chars
		next_char = chars[chars.index(char) + 1]
    next_char = chars[chars.index(char) - 1] if next_char.nil?
		after_next = chars[chars.index(next_char) + 1]
    after_next = chars[chars.index(next_char) - 1] if after_next.nil?
    return { next_char: next_char, after_next: after_next }
  end
end
