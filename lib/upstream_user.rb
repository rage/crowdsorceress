# frozen_string_literal: true
require 'pcrs_client'

class UpstreamUser
  def initialize(user_id)
    @user_id = user_id
    @client = PCRSClient.new()
  end

  def get
    return nil if upstream_user.nil?
    user = User.create_with(new_user_params)
               .find_or_create_by(username: upstream_user['username'])
    user.update(last_logged_in: Time.zone.now) if user.last_logged_in.nil?
    user
  end

  private

  def new_user_params
    {
      email: upstream_user['email'],
      administrator: upstream_user['administrator'],
    }
  end

  def upstream_user
    @upstream_user ||= begin
      if @user_id
	Rails.cache.fetch("upstream_user_#{@user_id}", expires_in: 1.hour) do
          fetch_user
	end
      end
    end
  end

  def fetch_user
    begin
      # request parameters
      params = {'username' => @user_id}
      # request headers
      headers = {'Content-Type' => 'application/json', 'Authorization' => 'Token ' + @client.get_auth_token}
      # make post request
      response = @client.post(@client.get_user_info_uri, params, headers)
    rescue StandardError
      return nil
    end 
    JSON.parse(response.body)
  end
end
