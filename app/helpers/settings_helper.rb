module SettingsHelper
  def setting_titles
    { chrono_feed_on: "Chrono Feed",
      post_txt_fader_on: "Post Text Fader",
      bg_fader_on: "BG Fader", post_bg_fader_on: "Post BG Fader",
      profile_card_bg_fader_on: "Profile Card BG Fader", profile_bg_fader_on: "Profile BG Fader",
      bg_color: "BG", post_bg_color: "Post BG", post_txt_color: "Post Text",
      profile_card_bg_color: "Profile Card BG", profile_bg_color: "Profile BG" }
  end
  
  def rgb_options setting, color
    # initializes options with nil color label
    options = [[color.to_s.upcase, nil]]
    # inserts rgb color range
    (0..255).step(5).each do |n|
      options << n
    end
    # replaces initial element if already set
    if settings[setting.to_sym].present?
      # strips string to just comma separated numbers
      rgb_str = settings[setting.to_sym][4..-2]
      # converts string to array of integers
      rgb_array = rgb_str.split(', ').map{|n| n.to_i}
      # gets relevant number from rgb array
      rgb_n = case color
      when :r
        rgb_array[0]
      when :g
        rgb_array[1]
      when :b
        rgb_array[2]
      end
      options[0] = ["#{color.to_s.upcase}:#{rgb_n}", rgb_n]
    end
    return options
  end
end
