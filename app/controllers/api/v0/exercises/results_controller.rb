# frozen_string_literal: true

module Api
  module V0
    module Exercises
      class ResultsController < BaseController
        # POST /exercises/:id/results
        def create
          exercise = Exercise.find(params[:exercise_id])
          token = verify_secret_token(exercise)

          return if exercise.finished? || exercise.error? || !submit_count_correct(token, exercise)

          exercise.error_messages = []

          TarballRemoverJob.perform_later(package_type(token), exercise)

          test_output = JSON.parse(params[:test_output])
          exercise.handle_results(params[:status], test_output, package_type(token))
        end

        private

        def package_type(token)
          token.include?('MODEL') ? 'MODEL' : 'TEMPLATE'
        end

        def submit_count_correct(token, exercise)
          count = token.split(',').last
          count == exercise.submit_count.to_s
        end

        def verify_secret_token(exercise)
          verifier = ActiveSupport::MessageVerifier.new(Rails.application.secrets[:secret_key_base])

          begin token = verifier.verify(params[:token])
          rescue ActiveSupport::MessageVerifier::InvalidSignature
            exercise.error_messages.push(header: 'Tehtävän lähetys epäonnistui virheellisen avaimen vuoksi', 'messages': '')
            exercise.error!
            MessageBroadcasterJob.perform_now(@exercise)
            raise InvalidSignature
          end

          token
        end

        def packages_target_path
          Rails.root.join('submission_generation', 'packages')
        end
      end
    end
  end
end
