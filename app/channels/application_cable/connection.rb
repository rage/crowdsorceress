# frozen_string_literal: true

module ApplicationCable
  require 'upstream_user'

  class Connection < ActionCable::Connection::Base
    identified_by :current_user, :current_exercise

    def connect
      self.current_user = find_verified_user
      self.current_exercise = find_exercise
    end

    private

    def find_verified_user
      if current_user == UpstreamUser.new(request.params[:oauth_token]).get
        current_user
      else
        reject_unauthorized_connection
      end
    end

    def find_exercise
      Exercise.find(request.params[:exercise_id]
    end
  end
end
