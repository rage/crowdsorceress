# frozen_string_literal: true

module Api
  module V0
    class AssignmentsController < BaseController
      # GET /assignments/1
      def show
        @assignment = Assignment.find(params[:id])
        @exercise_type = @assignment.exercise_type

        if @exercise_type.testing_type == 'input_output'
          render json: { assignment: @assignment, tags: Tag.recommended, template: @exercise_type.code_template, exercise_type: 'input_output' }
        elsif @exercise_type.testing_type == 'student_written_tests'
          render json: { assignment: @assignment, tags: Tag.recommended, template: @exercise_type.code_template,
                         test_template: @exercise_type.test_template, exercise_type: 'unit_tests' }
        elsif @exercise_type.testing_type == 'io_and_code'
          render json: { assignment: @assignment, tags: Tag.recommended, template: @exercise_type.code_template,
                         test_template: @exercise_type.test_method_template, exercise_type: 'io_and_code' }
        end
      end
    end
  end
end
