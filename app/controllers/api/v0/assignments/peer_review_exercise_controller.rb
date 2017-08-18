# frozen_string_literal: true

module Api
  module V0
    module Assignments
      class PeerReviewExerciseController < BaseController
        def index
          assignment = Assignment.find(params[:assignment_id])
          exercise = PeerReview.new.draw_exercise(assignment)

          raise NoExerciseError if exercise.nil?
          pr_questions = exercise.assignment.exercise_type.peer_review_questions
          render json: { exercise: exercise, peer_review_questions: pr_questions, tags: Tag.recommended,
                         model_solution: exercise.model_solution, template: exercise.template }
        end
      end
    end
  end
end
