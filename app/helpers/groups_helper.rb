module GroupsHelper
  def visible_to_anons? group
    true if group and group.open
  end

  def group_structure_options
    options = [["Choose a social structure", nil],
      ["Model of consensus", "consensus"],
      ["Direct democracy", "direct"],
      ["Autocratic (default)", "autocratic"]]
    return options
  end

  def featured_groups
    featured = []
    Group.where.not(image: nil).each do |group|
      # featured unless logged in and already joined
      featured << group unless my_groups.include? group or group.hidden
    end
    return featured.sort_by {|g| g.posts.size}.sample(10).last 4
  end

  def my_group_options editing=nil
    label = if editing
      "Put in a different group"
    else
      "Choose a group"
    end
    options = [[label, nil]]
    for group in my_groups.sort_by {|g| (g.posts.present? ? g.posts.last.created_at : g.created_at) }.reverse
      # inserts group as an invite option unless invitee is already a member or already invited
      unless @user and (@user.my_groups.include? group or @user.invites.find_by_group_id group.id) and not @user_shown
        options << [group.name, group.id]
      end
    end
    return options
  end

  def my_groups
    _my_groups = []
    if current_user
      current_user.my_groups.each { |group| _my_groups << group }
    elsif anon_token
      Group.where(anon_token: anon_token).each { |group| _my_groups << group }
      Connection.where(anon_token: anon_token).where.not(group_id: nil).each do |connection|
        _my_groups << connection.group if connection.group
      end
    end
    return _my_groups
  end

  def group_member_auth group
    if current_user
      if group.members.find_by_user_id current_user.id or current_user.has_power? 'invade_groups'
        true
      end
    end
  end

  def group_auth group
    return true if god? or goddess?
    if current_user
      return current_user.id.eql? group.user_id
    else
      return anon_token.eql? group.anon_token
    end
  end
end
