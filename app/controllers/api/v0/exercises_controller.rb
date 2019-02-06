# frozen_string_literal: true

require 'tarballer'

module Api
  module V0
    class ExercisesController < BaseController
      before_action :set_assignment, only: %i[create]

      # POST /exercises
      def create
        @exercise = current_user.exercises.find_or_initialize_by(assignment: @assignment)
        @exercise.attributes = exercise_params

        return if in_progress

        @exercise.reset!

        @exercise.add_tags(params[:exercise][:tags])

        if @exercise.save
          @exercise.saved!
          send_submission
          render json: { message: 'Exercise successfully created! :) :3', exercise: @exercise }, status: :created
        else
          render json: @exercise.errors, status: :unprocessable_entity, message: 'Exercise not created. =( :F'
        end
      end

      private

      def in_progress
        if @exercise.in_progress? && (Time.zone.now - 10.minutes) < @exercise.updated_at && @exercise.show_results_to_user
          render json: { message: 'Exercise is already in progress.', exercise: @exercise, status: 400 }
          return true
        end
        false
      end

      def send_submission
        MessageBroadcasterJob.perform_now(@exercise)
        Tarballer.new.create_tar_files(@exercise)
        SandboxPosterJob.perform_async(@exercise.id)
      end

      # Use callbacks to share common setup or constraints between actions.
      def set_exercise
        @exercise = Exercise.find(params[:id])
      end

      def set_assignment
        @assignment = Assignment.find(params[:exercise][:assignment_id])
      end

      def exercise_params
        # Allow any slate state for now...
        desc_params = params['exercise']['description'].permit!
        params.require(:exercise).permit(:code, :assignment_id, :tags, unit_tests: %i[test_name assertion_type test_code], testIO: %i[input output])
              .merge(description: desc_params)
      end
    end
  end
end
