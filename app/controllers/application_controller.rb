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

  def ensure_signed_in!
    return if current_user
    params[:return_to] = request.url
    render json: { error: 'Please log in.' }
    raise 'User not logged in'
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

  def info_for_paper_trail
    { ip: request.remote_ip }
  end

  private

  def render_error_page(status:, text:)
    render json: { errors: [message: "#{status} #{text}"] }, status: status
  end
end
