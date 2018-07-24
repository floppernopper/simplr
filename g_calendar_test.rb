require 'google/apis/calendar_v3'

client = Signet::OAuth2::Client.new(client_options)
client.code = params[:code]

response = client.fetch_access_token!

session[:authorization] = response

def client_options
  {
    client_id: ENV['GOOGLE_CALENDAR_CLIENT_ID'],
    client_secret: ENV['GOOGLE_CALENDAR_SECRET'],
    authorization_uri: 'https://accounts.google.com/o/oauth2/auth',
    token_credential_uri: 'https://accounts.google.com/o/oauth2/token',
    scope: Google::Apis::CalendarV3::AUTH_CALENDAR,
    redirect_uri: callback_url
  }
end
