# frozen_string_literal: true

module Api
  module V0
    module Assignments
      class PeerReviewExerciseController < BaseController
        before_action :ensure_signed_in!, only: :index

        def index
          assignment = Assignment.find(params[:assignment_id])
          cnt = params[:count].to_i

          exercises = PeerReview.new.draw_exercises(assignment, current_user, cnt)

          raise NoExerciseError if exercises.empty? || exercises.first.nil?

          pr_questions = exercises.first.assignment.exercise_type.peer_review_questions
          render json: { exercises: exercises, peer_review_questions: pr_questions,
                         tags: Tag.recommended, testing_type: testing_type(assignment.exercise_type) }
        end

        def testing_type(exercise_type)
          if exercise_type.testing_type == 'input_output'
            'input_output'
          elsif exercise_type.testing_type == 'student_written_tests'
            'unit_tests'
          elsif exercise_type.testing_type == 'io_and_code'
            'io_and_code'
          end
        end
      end
    end
  end
end
