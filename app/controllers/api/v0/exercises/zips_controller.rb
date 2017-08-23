# frozen_string_literal: true

module Api
  module V0
    module Exercises
      class ZipsController < BaseController
        def model_solution
          exercise = Exercise.find(params[:exercise_id])
          model_filename = Dir.entries(exercise_target_path(exercise)).find { |o| o.start_with?('ModelSolution') && o.end_with?('.zip') }
          send_file template_zip_path(exercise, model_filename)
        end

        def template
          exercise = Exercise.find(params[:exercise_id])
          template_filename = Dir.entries(exercise_target_path(exercise)).find { |o| o.start_with?('Template') && o.end_with?('.zip') }
          send_file template_zip_path(exercise, template_filename)
        end

        private

        def exercise_target_path(exercise)
          Rails.root.join('submission_generation', 'packages', "assignment_#{exercise.assignment.id}", "exercise_#{exercise.id}")
        end

        def template_zip_path(exercise, zip_name)
          exercise_target_path(exercise).join(zip_name)
        end
      end
    end
  end
end
