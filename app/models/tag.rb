class Tag < ActiveRecord::Base
  belongs_to :user
  belongs_to :post
  belongs_to :comment
  belongs_to :message
  belongs_to :group
  
  def self.trending
    _trending = []
    for tag in self.all
      # gets all trending hashtags and prevents any duplicates from being returned
      _trending << tag if tag.trending? and not _trending.detect { |_tag| _tag.tag.eql? tag.tag }
    end
    # sorts by the number of occurances a tags been used
    _trending.sort_by! { |tag| self.where(tag: tag.tag).size }
    # returns all trending, ascending by occurance
    return _trending.reverse
  end
  
  def trending?
    matches = Tag.where tag: self.tag
    recent_matches = matches.select do |tag|
      tag.created_at < 1.week.ago
    end
    return (recent_matches.size > Tag.all.size / 10)
  end
  
  def self.extract item
    text = item.body
    text.split(' ').each do |word|
      if word.include? '#' and word.size > 1
        tag = item.tags.find_by_tag word
        # creates any new tags found in text
        if tag.nil?
          item.tags.create(tag: word, index: text.index(word))
        # repositions any tags moved in text
        elsif not tag.index.eql? text.index(word)
          tag.update index: text.index(word)
        end
      end
    end
    # deletes any tags removed from text
    for tag in item.tags
      unless item.body.include? tag.tag
        tag.destroy unless tag.index.nil?
      end
    end
  end
  
  def self.add_from text, item
    text.split(' ').each do |tag|
      next unless tag.size > 1
      tag = '#' + tag unless tag.include? '#'
      tag.slice!(',') if tag.include? ','
      item.tags.create(tag: tag) unless item.tags.find_by_tag tag
    end
  end
end
