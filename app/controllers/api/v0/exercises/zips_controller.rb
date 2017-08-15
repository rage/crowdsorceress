# frozen_string_literal: true

module Api
  module V0
    module Exercises
      class ZipsController < BaseController
        def model_solution
          exercise = Exercise.find(params[:id])
          model_filename = Dir.entries(exercise_target_path(exercise)).find { |o| o.start_with?('ModelSolution') && o.end_with?('.zip') }
          send_file template_zip_path(exercise, model_filename)
        end

        def template
          exercise = Exercise.find(params[:id])
          stub_filename = Dir.entries(exercise_target_path(exercise)).find { |o| o.start_with?('Stub') && o.end_with?('.zip') }
          send_file template_zip_path(exercise, stub_filename)
        end
      end
    end
  end
end
