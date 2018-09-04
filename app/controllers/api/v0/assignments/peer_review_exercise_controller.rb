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
          render json: { exercises: exercises, peer_review_questions: pr_questions, tags: Tag.recommended }
        end
      end
    end
  end
end
