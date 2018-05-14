# frozen_string_literal: true

module Api
  module V0
    class AssignmentsController < BaseController
      # GET /assignments/1
      def show
        @assignment = Assignment.find(params[:id])
        @exercise_type = @assignment.exercise_type

        if @exercise_type.testing_type == 'student_written_tests' # TODO: enum
          render json: { assignment: @assignment, tags: Tag.recommended, template: @exercise_type.code_template, test_template: @exercise_type.test_template }
        else
          render json: { assignment: @assignment, tags: Tag.recommended, template: @exercise_type.code_template }
        end
      end
    end
  end
end
