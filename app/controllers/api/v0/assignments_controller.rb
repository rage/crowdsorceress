# frozen_string_literal: true

module Api
  module V0
    class AssignmentsController < BaseController
      # GET /assignments/1
      def show
        @assignment = Assignment.find(params[:id])
        @exercise_type = @assignment.exercise_type

        render json: { assignment: @assignment, tags: Tag.recommended, template: @exercise_type.code_template, 
        mandatory_tags: @assignment.mandatory_tags, language: @assignment.course.language }
          .merge(testing_type(@exercise_type))
      end

      def testing_type(exercise_type)
        if exercise_type.testing_type == 'input_output' || exercise_type.testing_type == 'input_output_tests_for_set_up_code'
          { exercise_type: exercise_type.testing_type }
        elsif exercise_type.testing_type == 'student_written_tests' || exercise_type.testing_type == 'whole_test_code_for_set_up_code'
          { test_template: @exercise_type.test_template, exercise_type: if exercise_type.testing_type == 'student_written_tests'
                                                                          then 'unit_tests'
                                                                        else
                                                                          'whole_test_code_for_set_up_code'
                                                                        end }
        elsif exercise_type.testing_type == 'io_and_code' || exercise_type.testing_type == 'tests_for_set_up_code'
          { test_template: @exercise_type.test_method_template, exercise_type: exercise_type.testing_type }
        end
      end
    end
  end
end
