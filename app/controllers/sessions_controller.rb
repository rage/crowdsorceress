# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_before_action :ensure_signed_in!, :only_admins!

  def index
    redirect_to redirect_target unless current_user.nil?
  end

  def create
    fetch_token
    if current_user
      unless admin?
        session[:user_id] = nil
        return redirect_to sessions_path, alert: 'Not authorized.'
      end
      current_user.update!(last_logged_in: Time.zone.now)
      redirect_to redirect_target
    else
      login_failed!
    end
  rescue StandardError
    login_failed!
  end

  def destroy
    session[:user_id] = nil
    redirect_to sessions_path, notice: 'You are logged out.'
  end

  private

  def fetch_token
    session[:user_id] = request.env['utorid']
  end

  def login_failed!
    msg = 'Wrong username or password.'
    msg += ' Please use your username, not your email address to log in.' if params[:login].include?('@')
    redirect_to sessions_path, alert: msg
  end

  def redirect_target
    target = session[:return_to] || '/'
    session[:return_to] = nil
    target
  end
end
