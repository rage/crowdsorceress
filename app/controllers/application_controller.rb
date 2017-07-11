# frozen_string_literal: true

require 'oauth2'
require 'upstream_user'

class ApplicationController < ActionController::API
  include ActionController::Helpers

  helper_method :current_user, :admin?

  NotAuthorized = Class.new(StandardError)

  rescue_from ApplicationController::NotAuthorized do
    render_error_page(status: 403, text: 'Forbidden')
  end

  NotLoggedIn = Class.new(StandardError)

  rescue_from ApplicationController::NotLoggedIn do
    render_error_page(status: 401, text: 'Please log in')
  end

  rescue_from ActiveRecord::RecordNotFound do |ex|
    render_error_page(status: 400, text: ex.message)
  end

  def ensure_signed_in!
    return if current_user

    raise NotLoggedIn
  end

  def current_user
    @current_user ||= begin
      UpstreamUser.new(params[:oauth_token]).get
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

  private

  def render_error_page(status:, text:)
    render json: { errors: [message: "#{status} #{text}"] }, status: status
  end
end
