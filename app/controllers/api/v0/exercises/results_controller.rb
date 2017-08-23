# frozen_string_literal: true

module Api
  module V0
    module Exercises
      class ResultsController < BaseController
        # POST /exercises/:id/results
        def create
          exercise = Exercise.find(params[:exercise_id])
          return if exercise.sandbox_timeout?

          verify_secret_token(params[:token], exercise)
          test_output = JSON.parse(params[:test_output])
          exercise.handle_results(params[:status], test_output, package_type)
        end

        private

        def package_type
          params[:token].include?('MODEL') ? 'MODEL' : 'TEMPLATE'
        end

        def verify_secret_token(token, exercise)
          secret_token = if params[:token].include? 'MODEL'
                           token.gsub('MODEL', '')
                         else
                           token.gsub('TEMPLATE', '')
                         end

          verifier = ActiveSupport::MessageVerifier.new(Rails.application.secrets[:secret_key_base])
          begin verifier.verify(secret_token)
          rescue ActiveSupport::MessageVerifier::InvalidSignature
            exercise.error_messages.push(header: 'Tehtävän lähetys epäonnistui virheellisen avaimen vuoksi', 'messages': '')
            exercise.error!
            MessageBroadcasterJob.perform_now(@exercise)
            raise InvalidSignature
          end
        end
      end
    end
  end
end
