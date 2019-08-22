# frozen_string_literal: true

class UpstreamUser
  def initialize(user_id)
    @user_id = user_id
  end

  def get
    return nil if upstream_user.nil?
    user = upstream_user
    user.update(last_logged_in: Time.zone.now) if user.last_logged_in.nil?
    user
  end

  private

  def upstream_user
    @upstream_user ||= begin
      if @user_id
        fetch_user
      end
    end
  end

  def fetch_user
    begin
      user = User.find_by(username: @user_id)
    rescue StandardError
      return nil
    end
  end
end
