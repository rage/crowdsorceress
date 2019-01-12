# frozen_string_literal: true

module Api
  module V0
    class UsersController < BaseController
      def progress
        course = Course.find_by(name: params['course'])
        points = current_user.get_points(course)

        render json: { points_by_group: points }
      end
    end
  end
end
