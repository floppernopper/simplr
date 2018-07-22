class TemplatesController < ApplicationController
  before_action :set_templating, only: [:semantic_ui, :uikit, :purecss, :sample_blog]
  before_action :set_on_point, only: [:calendar, :on_point, :pricing, :admin, :example_stuff]
  
  layout :resolve_layout

  def index
    @forrest_web_co = true
  end

  def semantic_ui
    @semantic_ui = @forrest_web_co = true
  end
  
  # authenticate with google
  def redirect
    client = Signet::OAuth2::Client.new(client_options)
    
    redirect_to client.authorization_uri.to_s
  end
  
  def callback
    client = Signet::OAuth2::Client.new(client_options)
    client.code = params[:code]

    response = client.fetch_access_token!

    session[:authorization] = response

    redirect_to on_point_calendar_path
  end

  private
  
  def client_options
    {
      client_id: ENV['GOOGLE_CALENDAR_CLIENT_ID'],
      client_secret: ENV['GOOGLE_CALENDAR_SECRET'],
      authorization_uri: 'https://accounts.google.com/o/oauth2/auth',
      token_credential_uri: 'https://accounts.google.com/o/oauth2/token',
      scope: Google::Apis::CalendarV3::AUTH_CALENDAR,
      redirect_uri: callback_path
    }
  end
  
  def resolve_layout
    case action_name.to_sym
    when :on_point, :calendar, :pricing, :admin, :example_stuff
      "on_point"
    else
      "application"
    end
  end
  
  def set_on_point
    @on_point = true
  end

  def set_templating
    @templating = true
  end
end
