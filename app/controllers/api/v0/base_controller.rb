# frozen_string_literal: true

require 'oauth2'
require 'upstream_user'

module Api
  module V0
    class BaseController < ActionController::API
      include ActionController::Helpers

      helper_method :current_user, :admin?

      NotAuthorized = Class.new(StandardError)

      rescue_from NotAuthorized do
        render_error_page(status: 403, text: 'Not authorized.')
      end

      NotLoggedIn = Class.new(StandardError)

      rescue_from NotLoggedIn do
        render_error_page(status: 401, text: 'Please log in.')
      end

      rescue_from ActiveRecord::RecordNotFound do |ex|
        render_error_page(status: 400, text: ex.message)
      end

      rescue_from ActiveSupport::MessageVerifier::InvalidSignature do
        render_error_page(status: 400, text: 'Invalid secret token.')
      end

      NoExerciseError = Class.new(StandardError)

      rescue_from NoExerciseError do
        render_error_page(status: 400, text: 'No exercises found for peer review.')
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
        raise NotAuthorized unless admin?
      end

      def only_user_and_admins!(user)
        raise NotAuthorized unless admin? || current_user == user
      end

      private

      def render_error_page(status:, text:)
        render json: { errors: [message: text] }, status: status
      end
    end
  end
end
