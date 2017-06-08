require 'oauth2'

class ApplicationController < ActionController::API
  include ActionController::Helpers

  helper_method :current_user, :admin?

  NotAuthorized = Class.new(StandardError)

  rescue_from ApplicationController::NotAuthorized do
    render_error_page(status: 403, text: 'Forbidden')
  end

  def ensure_signed_in!
    return if current_user
    params[:return_to] = request.url
    render json: { error: 'Please log in.' }
  end

  def current_user
    return nil unless upstream_user
    @current_user ||= begin
      user = User.create_with(email: upstream_user['email'], first_name: upstream_user['first_name'],
                              last_name: upstream_user['last_name'], administrator: upstream_user['administrator'])
                 .find_or_create_by(username: upstream_user['username'])
      user.update(last_logged_in: Time.zone.now) if user.last_logged_in.nil?
      user
    end
  end

  def admin?
    current_user ? current_user.administrator : false
  end

  def only_admins!
    raise ApplicationController::NotAuthorized unless admin?
  end

  def only_user_and_admins!(user)
    raise ApplicationController::NotAuthorized unless admin? || current_user == user
  end

  def oauth_client
    @oauth_client ||= OAuth2::Client.new(ENV['OAUTH_APPLICATION_ID'], ENV['OAUTH_SECRET'], site: ENV['OAUTH_SITE'])
  end

  def info_for_paper_trail
    { ip: request.remote_ip }
  end

  private

  def render_error_page(status:, text:)
    render json: { errors: [message: "#{status} #{text}"] }, status: status
  end

  def upstream_user
    @upstream_user ||= begin
      if params[:oauth_token]
        Rails.cache.fetch("upstream_user_#{params[:oauth_token]}", expires_in: 1.hour) do
          fetch_user_from_backend!
        end
      end
    end
  end

  def fetch_user_from_backend!
    token = OAuth2::AccessToken.new(oauth_client, params[:oauth_token])
    response = token.get('/api/v8/users/current.json')
    return nil unless response.status == 200
    JSON.parse(response.body)
  end
end
