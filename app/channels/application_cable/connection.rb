# frozen_string_literal: true

module ApplicationCable
  require 'upstream_user'

  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      if current_user = UpstreamUser.new(request.params[:oauth_token]).get
        current_user
      else
        reject_unauthorized_connection
      end
    end
  end
end
