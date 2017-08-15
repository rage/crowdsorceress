# frozen_string_literal: true

module Api
  module V0
    class PeerReviewsController < ApplicationController
      # POST /peer_reviews
      def create
        @peer_review = current_user.peer_reviews.find_or_initialize_by(exercise: @exercise, comment: params[:peer_review][:comment])

        params[:exercise][:tags].each do |tag|
          @peer_review.tags.find_or_initialize_by(name: tag.downcase)
        end

        PeerReview.transaction do
          if @peer_review.save
            render json: @peer_review, status: :created, location: @peer_review
            create_question_answers
          else
            render json: @peer_review.errors, status: :unprocessable_entity
          end
        end
      end

      # GET /peer_reviews/assignments/assignment_id/request_exercise
      def assign_exercise
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
