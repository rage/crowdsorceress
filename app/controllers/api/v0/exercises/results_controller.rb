# frozen_string_literal: true

module Api
  module V0
    module Exercises
      class ResultsController < BaseController
        # POST /exercises/:id/results
        def create
          exercise = Exercise.find(params[:exercise_id])
          return if exercise.finished? || exercise.error?

          remove_tar_files(package_type, exercise)

          verify_secret_token(params[:token], exercise)
          test_output = JSON.parse(params[:test_output])
          exercise.handle_results(params[:status], test_output, package_type)
        end

        private

        def remove_tar_files(package_type, exercise)
          if package_type == 'TEMPLATE'
            package_name = "TemplatePackage_#{exercise.id}.tar"
          elsif package_type == 'MODEL'
            package_name = "ModelSolutionPackage_#{exercise.id}.tar"
          end
          File.open(packages_target_path.join(package_name).to_s, 'r') do |tar_file|
            `rm #{tar_file.path}`
          end
        end

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

        def packages_target_path
          Rails.root.join('submission_generation', 'packages')
        end
      end
    end
  end
end
