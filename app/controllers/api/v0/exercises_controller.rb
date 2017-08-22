# frozen_string_literal: true

module Api
  module V0
    class ExercisesController < BaseController
      before_action :set_assignment, only: %i[create]

      # POST /exercises
      def create
        @exercise = current_user.exercises.find_or_initialize_by(assignment: @assignment)
        @exercise.attributes = exercise_params

        if @exercise.in_progress?
          render json: { message: 'Exercise is already in progress.', exercise: @exercise, status: 400 }
          return
        end

        @exercise.reset!

        @exercise.add_tags(params[:exercise][:tags])

        if @exercise.save
          @exercise.saved!
          perform_jobs
          render json: { message: 'Exercise successfully created! :) :3', exercise: @exercise }, status: :created
        else
          render json: @exercise.errors, status: :unprocessable_entity, message: 'Exercise not created. =( :F'
        end
      end

      private

      def perform_jobs
        ExerciseVerifierJob.perform_later @exercise
        MessageBroadcasterJob.perform_now(@exercise)
        TimeoutCheckerJob.set(wait: 1.minute).perform_later(@exercise)
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
        params.require(:exercise).permit(:code, :assignment_id, :tags, testIO: %i[input output]).merge(description: desc_params)
      end
    end
  end
end
