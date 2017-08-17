# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_before_action :only_admins!

  def index
    redirect_to redirect_target unless current_user.nil?
  end

  def create
    token = oauth_client.password.get_token(params[:login], params[:password])
    session[:oauth_token] = token.token
    if current_user
      unless admin?
        session[:oauth_token] = nil
        return redirect_to sessions_path, alert: 'Not authorized'
      end
      current_user.update!(last_logged_in: Time.zone.now)
      redirect_to redirect_target
    else
      login_failed!
    end
  rescue
    login_failed!
  end

  def destroy
    session[:oauth_token] = nil
    redirect_to sessions_path, notice: 'You are logged out.'
  end

  private

  def login_failed!
    msg = 'Wrong username or password'
    msg += ' Please user your username, not your email address to log in.' if params[:login].include?('@')
    redirect_to sessions_path, alert: msg
  end

  def redirect_target
    target = session[:return_to] || '/'
    session[:return_to] = nil
    target
  end
end
