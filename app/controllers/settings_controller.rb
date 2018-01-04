class SettingsController < ApplicationController
  before_action :dev_only, only: [:dev_panel]
  
  def update_all_user_settings
    Setting.initialize_all_settings
    redirect_to :back
  end
  
  def dev_panel
    @dev_panel_shown = true
    @char_bits = char_bits Post.last 10
    # creates the invite link to be copied and shared
    if params[:invite_token]
      @invite = Connection.find_by_unique_token params[:invite_token]
      if @invite
        @invite_link = root_url; @invite_link.slice!(-1)
        @invite_link +=redeem_invite_path(@invite.unique_token)
      end
    # creates the portal link to be copied and shared
    elsif params[:portal_token]
      @portal = Portal.find_by_unique_token params[:portal_token]
      if @portal
        @portal_link = root_url; @portal_link.slice!(-1)
        @portal_link +=enter_portal_path(@portal.unique_token)
      end
    end
  end
  
  def index
  end

  def update
    Setting.names.each do |category, names|
      for name in names
        setting = current_user.settings.find_by_name(name)
        # makes sure not to reset color values unless user restores defaults and accounts for on/off setting params
        if params[:restore_defaults]
          setting.update category => (category.eql?(:on) ? false : "")
        elsif category.eql? :state
          state_params = params[name.to_sym]
          if state_params.any? {|key,val| val.present?}
            setting.update category => \
              "rgb(#{state_params[:r].to_i}, #{state_params[:g].to_i}, #{state_params[:b].to_i})"
          end
        elsif category.eql? :on
          setting.update category => params[name.to_sym]
        end
      end
    end
    redirect_to :back
  end
  
  private
  
  def dev_only
    dev?
  end
end
