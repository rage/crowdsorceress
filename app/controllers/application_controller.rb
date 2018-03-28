# frozen_string_literal: true

require 'upstream_user'
require 'kaminari'

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :ensure_signed_in!, :only_admins!
  helper_method :current_user, :admin?

  NotAuthorized = Class.new(StandardError)

  rescue_from NotAuthorized do
    redirect_to sessions_path, alert: 'Not authorized.'
  end

  def current_user
    @current_user ||= begin
      UpstreamUser.new(session[:oauth_token]).get
    end
  end

  def admin?
    current_user ? current_user.administrator : false
  end

  def only_admins!
    raise NotAuthorized unless admin?
  end

  def ensure_signed_in!
    return if current_user
    session[:return_to] = request.url
    redirect_to sessions_path, notice: 'Please log in.'
  end

  def oauth_client
    @oauth_client ||= OAuth2::Client.new(ENV['OAUTH_APPLICATION_ID'], ENV['OAUTH_SECRET'], site: ENV['OAUTH_SITE'])
  end
end
