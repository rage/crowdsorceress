# frozen_string_literal: true

module Api
  module V0
    class PeerReviewsController < BaseController
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
    end
  end
end
