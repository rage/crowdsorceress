module Api
  module V0
    module Exercises
      class ResultsController < BaseController
        # POST /exercises/:id/results
        def create
          if params[:token].include? 'MODEL'
            package_type = 'MODEL'
          elsif params[:token].include? 'STUB'
            package_type = 'STUB'
          end

          exercise = Exercise.find(params[:exercise_id])
          verify_secret_token(params[:token], exercise)
          test_output = JSON.parse(params[:test_output])
          exercise.handle_results(params[:status], test_output, package_type)
        end

        private

        def verify_secret_token(token, exercise)
          secret_token = if params[:token].include? 'MODEL'
                           token.gsub('MODEL', '')
                         else
                           token.gsub('STUB', '')
                         end

          verifier = ActiveSupport::MessageVerifier.new(Rails.application.secrets[:secret_key_base])
          begin verifier.verify(secret_token)
          rescue ActiveSupport::MessageVerifier::InvalidSignature
            exercise.error_messages.push 'Tehtävän lähetys epäonnistui virheellisen avaimen vuoksi'
            exercise.error!
            MessageBroadcasterJob.perform_now(@exercise)
            raise InvalidSignature
          end
        end
      end
    end
  end
end
