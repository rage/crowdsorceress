# frozen_string_literal: true

require 'upstream_user'

class ApplicationController < ActionController::Base
  # protect_from_forgery with: :exception
  before_action :only_admins!
  helper_method :current_user, :admin?

  NotAuthorized = Class.new(StandardError)

  rescue_from NotAuthorized do
    redirect_to sessions_path, alert: 'Not authorized'
  end

  NotLoggedIn = Class.new(StandardError)

  rescue_from NotLoggedIn do
    redirect_to sessions_path, alert: 'Please log in'
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

  def oauth_client
    @oauth_client ||= OAuth2::Client.new(ENV['OAUTH_APPLICATION_ID'], ENV['OAUTH_SECRET'], site: ENV['OAUTH_SITE'])
  end
end
