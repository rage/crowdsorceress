# frozen_string_literal: true

module Api
  module V0
    class PeerReviewsController < BaseController
      # POST /peer_reviews
      before_action :set_exercise, only: %i[create]

      def create
        @peer_review = current_user.peer_reviews.find_or_initialize_by(exercise: @exercise, comment: params[:peer_review][:comment])

        add_tags

        PeerReview.transaction do
          if @peer_review.save
            render json: @peer_review, status: :created, location: @peer_review
            create_question_answers
          else
            render json: @peer_review.errors, status: :unprocessable_entity
          end
        end
      end

      private

      def add_tags
        params[:exercise][:tags].each do |tag|
          tag = Tag.find_or_initialize_by(name: tag.strip.delete("\n").gsub(/\s+/, ' ').downcase)
          @peer_review.tags << tag
        end
      end

      def set_exercise
        @exercise = Exercise.find(params[:exercise][:exercise_id])
      end

      def create_question_answers
        reviews = params[:peer_review][:answers]

        questions = @exercise.assignment.exercise_type.peer_review_questions

        questions.each do |q|
          @peer_review.peer_review_question_answers.create!(peer_review_question: q, grade: reviews[q.question])
        end
      end
    end
  end
end
