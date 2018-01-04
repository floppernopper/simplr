class Setting < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :name
  
  def self.settings user
    if user
      setting = lambda { |name| user.settings.find_by_name name }
      settings = {}; self.names.each do |category, names|
        for name in names
          settings[name.to_sym] = setting.call(name).send(category)
        end
      end
      return settings
    else
      return {}
    end
  end
  
  def self.initialize_all_settings
    for user in User.all
      user.initialize_settings
    end
  end
  
  def self.names
    { on: ['bg_fader_on', 'post_bg_fader_on', 'post_txt_fader_on',
      'profile_card_bg_fader_on', 'profile_bg_fader_on',
      'chrono_feed_on'],
      
      state: ['bg_color', 'post_bg_color', 'post_txt_color', 'profile_card_bg_color', 'profile_bg_color'] }
  end
end
