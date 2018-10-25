# frozen_string_literal: true

class ExerciseType < ApplicationRecord
  has_many :exercises
  has_many :peer_review_questions

  enum testing_type: %i[input_output student_written_tests io_and_code tests_for_set_up_code]

  def trim_input_and_output_types
    input_type.strip!
    output_type.strip!

    update(input_type: 'String') if input_type == 'string'
    update(output_type: 'String') if output_type == 'string'
  end
end
