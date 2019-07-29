# frozen_string_literal: true

class UpstreamUser
  def initialize(oauth_token)
    @oauth_token = oauth_token
  end

  def get
    return nil if upstream_user.nil?
    user = User.create_with(new_user_params)
               .find_or_create_by(username: upstream_user['username'])
    user.update(last_logged_in: Time.zone.now) if user.last_logged_in.nil?
    user
  end

  private

  def oauth_client
    @oauth_client ||= OAuth2::Client.new('', '', site: ENV['OAUTH_SITE'])
  end

  def new_user_params
    {
      email: upstream_user['email'],
      first_name: upstream_user['first_name'],
      last_name: upstream_user['last_name'],
      administrator: upstream_user['administrator']
    }
  end

  def upstream_user
    @upstream_user ||= begin
      if @oauth_token
        Rails.cache.fetch("upstream_user_#{@oauth_token}", expires_in: 1.hour) do
          fetch_user_from_backend!
        end
      end
    end
  end

  def fetch_user_from_backend!
    token = OAuth2::AccessToken.new(oauth_client, @oauth_token)
    begin
      response = token.get('/api/v8/users/current.json')
    rescue StandardError
      return nil
    end
    JSON.parse(response.body)
  end
end
