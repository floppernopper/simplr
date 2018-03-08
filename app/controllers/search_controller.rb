class SearchController < ApplicationController
  before_action :get_results, only: [:dropdown_index, :index]
  before_action :secure_search

  def toggle_dropdown
    @tags = Tag.trending
  end

  def dropdown_index
    @dropdown = true
  end

  def index
    @search_index = true
    @results_shown = true
  end

  private

  def search
    # intializes results list
    @results = [];
    # to display different result types found for each query
    @result_types = { group: 0, user: 0, bot: 0, post: 0, proposal: 0, comment: 0 }
    # loops through each model and through each item in each model
    [Group, User, Bot, Post, Proposal, Comment].each do |_class|
      # accounts for difference in groups for anrcho
      all_items = if anrcho? and _class.eql? Group
        Group.anrcho
      elsif _class.eql? Group
        Group.global
      else
        _class.all
      end
      all_items.reverse.each do |item|
        match = false; match_by_tag = false
        # scans all text for query
        match = true if scan_text item, @query
        # scans all items for matching tags
        if item.respond_to? :tags
          item.tags.each do |tag|
            if @query.eql? tag.tag or "##{@query}".eql? tag.tag
              match_by_tag = true
              match = true
            end
          end
        end
        # scans comments of current item
        if item.respond_to? :comments and not _class.eql? User
          item.comments.each do |comment|
            match = true if scan_text comment, @query
            break if match
          end
        end
        # a case for keywords used
        case @query
        when "posts", "Posts"
          match = true if _class.eql? Post and not item.group
        when "proposals", "Proposals", "motions", "Motions", "motion", "proposal", "Proposal", "Motion"
          match = true if _class.eql? Proposal and not item.group
        when "groups", "Groups"
          match = true if _class.eql? Group
        when "users", "Users"
          match = true if _class.eql? User
        when "groups and users", "users and groups"
          match = true if [Group, User].include? _class
        # first treasure found, first power unlocked
        when "discover"
          if current_user
            treasure = current_user.treasures.new power: 'discover'
            # can now find hidden treasure on the site and unlock powers
            if treasure.save
              @discover = true
              break
            end
          end
        when "what is love", "What is love", "what is love ", "What is love "
          if current_user and not current_user.has_power? 'love'
            treasure = current_user.treasures.new power: 'love'
            # can now love posts
            if treasure.save
              @found_love = true
              break
            end
          end
        end
        if match
          @results << item
          @result_types[item.class.to_s.downcase.to_sym] +=1
          @group_found_by_tag = if item.is_a?(Group) and match_by_tag then true end
        end
      end
      # to prevent duplicate treasures from being created
      break if @discover or @found_love
    end
    # remove duplicates
    @results.uniq!
    # removes any types not found at all, for display to view with/without commas
    @result_types.each { |key, val| @result_types.delete(key) if val.zero?  }
  end

  # scans specific peices of text for match
  def scan_text item, query, match=false
    [:body, :name, :anon_token, :unique_token, :action].each do |sym|
      if item.respond_to? sym and item.send(sym).present?
        match = true if scan item.send(sym), query
      end
    end
    # show all content of a group/user when searched by group/user name
    [:user, :group].each do |sym|
      if item.respond_to? sym and item.send(sym)
        match = true if scan item.send(sym).name, query
      end
    end
    return match
  end

  # scans text word by word for match
  def scan text, query, match=false
    for word in text.split(" ")
      for key_word in query.split(" ")
        if key_word.size > 2
          if word.eql? key_word or word.eql? key_word.downcase or word.eql? key_word.capitalize \
            or word.include? key_word.downcase or word.include? key_word.capitalize
            match = true
          end
        end
      end
    end
    return match
  end

  def get_results
    @query = params[:query].present? ? params[:query] : session[:query]
    session[:query] = @query
    search if @query.present?
  end

  def secure_search
    unless invited? or anrcho?
      redirect_to invite_only_path
    end
  end
end
