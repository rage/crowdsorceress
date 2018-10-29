# frozen_string_literal: true

module Api
  module V0
    class AssignmentsController < BaseController
      # GET /assignments/1
      def show
        @assignment = Assignment.find(params[:id])
        @exercise_type = @assignment.exercise_type

        render json: { assignment: @assignment, tags: Tag.recommended, template: @exercise_type.code_template }.merge(testing_type(@exercise_type))
      end

      def testing_type(exercise_type)
        if exercise_type.testing_type == 'input_output'
          { exercise_type: 'input_output' }
        elsif exercise_type.testing_type == 'student_written_tests'
          { test_template: @exercise_type.test_template, exercise_type: 'unit_tests' }
        elsif exercise_type.testing_type == 'io_and_code' || exercise_type.testing_type == 'tests_for_set_up_code'
          { test_template: @exercise_type.test_method_template, exercise_type: exercise_type.testing_type }
        end
      end
    end
  end
end
